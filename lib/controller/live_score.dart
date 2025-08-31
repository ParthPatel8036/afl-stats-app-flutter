import 'dart:developer';
import 'package:afl/controller/home_vc.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'package:afl/services/notification_service.dart';


enum StatEvent { goal, behind, kick, handball, mark, tackle }

extension StatEventExtension on StatEvent {
  String get name => toString().split('.').last.capitalize();
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

class MatchAction {
  final String playerName;
  final String actionName;
  final bool isTeam1;
  final DateTime timestamp;
  final int quarter;

  MatchAction(this.playerName, this.actionName, this.isTeam1, this.timestamp, this.quarter);
}

class LiveMatchVC extends StatefulWidget {
  final AFLMatch matchObj;

  const LiveMatchVC({super.key, required this.matchObj});

  @override
  LiveMatchVCState createState() => LiveMatchVCState();
}

class LiveMatchVCState extends State<LiveMatchVC> {
  final FirestoreManager firestoreManager = FirestoreManager();

  bool isEventOverlayVisible = false;
  StatEvent? selectedEvent;
  bool eventForTeam1 = true;
  List<Player> currentPlayers = [];
  Team? team1Obj;
  Team? team2Obj;
  List<MatchAction> matchActions = [];
  Map<String, StatEvent?> lastPlayerActions = {};
  Map<String, StatEvent?> lastTeamActions = {};
  late DateTime _quarterStartTime;
  Timer? _quarterTimer;


  @override
  void initState() {
    super.initState();
    _quarterStartTime = DateTime.now();
    team1Obj = Team(
        documentID: widget.matchObj.team1Doc,
        name: widget.matchObj.team1Name,
        players: []);
    team2Obj = Team(
        documentID: widget.matchObj.team2Doc,
        name: widget.matchObj.team2Name,
        players: []);
    loadTeamsPlayers();
    _quarterTimer = Timer(const Duration(minutes:20), nextQuarter);

  }

  Future<void> loadTeamsPlayers() async {
    final allTeams = await firestoreManager.fetchAllTeams();
    setState(() {
      team1Obj = allTeams.firstWhere(
              (t) => t.documentID == widget.matchObj.team1Doc,
          orElse: () => team1Obj!);
      team2Obj = allTeams.firstWhere(
              (t) => t.documentID == widget.matchObj.team2Doc,
          orElse: () => team2Obj!);
    });
  }

  void showEventOverlay(StatEvent event, bool forTeam1) {
    setState(() {
      selectedEvent = event;
      eventForTeam1 = forTeam1;
      currentPlayers = forTeam1 ? team1Obj!.players : team2Obj!.players;
      isEventOverlayVisible = true;
    });
  }

  void hideEventOverlay() {
    setState(() => isEventOverlayVisible = false);
  }

  void recordEvent(Player player) {
    NotificationService.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '${selectedEvent!.name} by ${player.name}',
      body: '${eventForTeam1 ? widget.matchObj.team1Name : widget.matchObj.team2Name} ${selectedEvent == StatEvent.goal ? "scored ${player.goals * 6 + player.behinds}" : selectedEvent == StatEvent.behind ? "scored a behind" : ""}',
    );
    final m = widget.matchObj;
    final teamId = eventForTeam1
        ? team1Obj!.documentID!
        : team2Obj!.documentID!;
    final lastAction = lastTeamActions[teamId];
    if (selectedEvent == StatEvent.goal && lastAction != StatEvent.kick) {
      _showSnackBar("Goal can only follow a Kick.");
      return;
    }
    if (selectedEvent == StatEvent.behind &&
        !(lastAction == StatEvent.kick || lastAction == StatEvent.handball)) {
      _showSnackBar("Behind can only follow a Kick or Handball.");
      return;
    }
    switch (selectedEvent!) {
      case StatEvent.goal:
        if (eventForTeam1) {
          m.team1Goals++;
          player.goals++;
        } else {
          m.team2Goals++;
          player.goals++;
        }
        break;
      case StatEvent.behind:
        if (eventForTeam1) {
          m.team1Behinds++;
          player.behinds++;
        } else {
          m.team2Behinds++;
          player.behinds++;
        }
        break;
      case StatEvent.kick:
        player.kicks++;
        break;
      case StatEvent.handball:
        player.handballs++;
        break;
      case StatEvent.mark:
        player.marks++;
        break;
      case StatEvent.tackle:
        player.tackles++;
        break;
    }
    lastTeamActions[teamId] = selectedEvent;
    matchActions.add(
        MatchAction(
            player.name ?? '',
            selectedEvent!.name,
            eventForTeam1,
            DateTime.now(),
            widget.matchObj.quarter
        )
    );
    firestoreManager.updatePlayerInTeam(
      teamId,
      player.documentID!,
      player,
          (error) {
        if (error != null && kDebugMode) {
          log('Failed to update player stat: $error');
        }
      },
    );
    firestoreManager.updateMatchDetails(m, (error) {
      if (error != null) _showSnackBar("Error updating match");
    });

    hideEventOverlay();
    setState(() {});
  }

  void nextQuarter() {
    final m = widget.matchObj;
    _quarterTimer?.cancel();
    if (m.quarter < 4) {
      setState(() {
        m.quarter++;
        _quarterStartTime = DateTime.now();
      });
      NotificationService.show(
        id: m.quarter,
        title: 'Quarter ${m.quarter} Started',
        body: '${widget.matchObj.team1Name} vs ${widget.matchObj.team2Name}',
      );

      firestoreManager.updateMatchDetails(m, (error) {
        if (error != null) {
          _showSnackBar("Error updating quarter");
        } else {
          _showSnackBar("Quarter ${m.quarter} started");
        }
      });
      _quarterTimer = Timer(const Duration(minutes:20), nextQuarter);
    } else {
      setState(() => m.status = MatchStatus.completed);
      firestoreManager.updateMatchStatus(MatchStatus.completed, m);

      final team1Total = m.team1Goals * 6 + m.team1Behinds;
      final team2Total = m.team2Goals * 6 + m.team2Behinds;
      String result;
      if (team1Total > team2Total) {
        result =
        '${m.team1Name} win ${m.team1Goals}.${m.team1Behinds} ($team1Total) to ${m.team2Goals}.${m.team2Behinds} ($team2Total)';
      } else if (team2Total > team1Total) {
        result =
        '${m.team2Name} win ${m.team2Goals}.${m.team2Behinds} ($team2Total) to ${m.team1Goals}.${m.team1Behinds} ($team1Total)';
      } else {
        result =
        'Draw: ${m.team1Goals}.${m.team1Behinds} each ($team1Total all)';
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Match Completed'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _shareMatchSummary() {
    final summary = _generateMatchSummary();
    SharePlus.instance.share(ShareParams(text: summary));
  }

  String _generateMatchSummary() {
    final m = widget.matchObj;
    final team1Score = '${m.team1Goals}.${m.team1Behinds}';
    final team2Score = '${m.team2Goals}.${m.team2Behinds}';
    final buffer = StringBuffer()
      ..writeln('Match Summary')
      ..writeln('${m.team1Name} [$team1Score] vs ${m.team2Name} [$team2Score]')
      ..writeln('Quarter: ${m.quarter}')
      ..writeln('Actions:');

    for (var action in matchActions) {
      buffer.writeln(
          '${action.playerName} - ${action.actionName} at ${_formatTimestamp(action.timestamp)}');
    }
    return buffer.toString();
  }

  String _formatTimestamp(DateTime dt) {
    final elapsed = dt.difference(_quarterStartTime);
    final mm = elapsed.inMinutes.remainder(60).toString().padLeft(2,'0');
    final ss = elapsed.inSeconds.remainder(60).toString().padLeft(2,'0');
    return '$mm:$ss';
  }


  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {

    final m = widget.matchObj;
    int runningTeam1 = 0;
    int runningTeam2 = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${m.team1Name} vs ${m.team2Name}  (Q${m.quarter})  ${_formatTimestamp(DateTime.now())}'
        ),        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareMatchSummary,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildTeamScore('Team 1(${m.team1Name})', m.team1Goals,
                          m.team1Behinds),
                      buildTeamScore('Team 2(${m.team2Name})', m.team2Goals,
                          m.team2Behinds),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 12,
                  children: StatEvent.values.map((e) {
                    return PopupMenuButton<bool>(
                      onSelected: (forTeam1) => showEventOverlay(e, forTeam1),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: true, child: Text('Team 1: ${e.name}')),
                        PopupMenuItem(
                            value: false, child: Text('Team 2: ${e.name}')),
                      ],
                      child:
                      ElevatedButton(onPressed: null, child: Text(e.name)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Live Match History',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: matchActions.length,
                    itemBuilder: (context, index) {
                      final action = matchActions[index];
                      if (action.actionName == 'Goal') {
                        if (action.isTeam1) {
                          runningTeam1 += 6;
                        } else {
                          runningTeam2 += 6;
                        }
                      } else if (action.actionName == 'Behind') {
                        if (action.isTeam1) {
                          runningTeam1 += 1;
                        } else {
                          runningTeam2 += 1;
                        }
                      }
                      return ListTile(
                        title: Text('${action.playerName} - ${action.actionName}'),
                        subtitle: Text(
                            '${_formatTimestamp(action.timestamp)}  •  Score: $runningTeam1–$runningTeam2'
                        ),
                        leading: const Icon(Icons.sports_football),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: AFLButtonWidget(
                    title: m.quarter < 4 ? 'Next Quarter' : 'End Match',
                    onTap: nextQuarter,
                  ),
                ),
              ],
            ),
            if (isEventOverlayVisible)
              GestureDetector(
                onTap: hideEventOverlay,
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Container(
                    width: 300,
                    height: 400,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Select Player for ${selectedEvent!.name}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentPlayers.length,
                            itemBuilder: (_, i) {
                              final p = currentPlayers[i];
                              return ListTile(
                                title: Text(p.name ?? ''),
                                onTap: () => recordEvent(p),
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: hideEventOverlay,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTeamScore(String name, int goals, int behinds) {
    final total = goals * 6 + behinds;
    return Column(
      children: [
        Text(name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$goals·$behinds.$total',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
