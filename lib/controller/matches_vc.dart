import 'package:afl/controller/past_match_details_vc.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MatchesVC extends StatefulWidget {
  const MatchesVC({super.key});

  @override
  MatchesVCState createState() => MatchesVCState();
}

class MatchesVCState extends State<MatchesVC> {
  List<AFLMatch> matchesArr = [];
  final FirestoreManager firestoreManager = FirestoreManager();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMatches(showLoader: true);
  }

  void fetchMatches({required bool showLoader}) {
    if (showLoader) setState(() => isLoading = true);

    firestoreManager.fetchAllMatches().then((matches) {
      setState(() {
        matchesArr = matches;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() => isLoading = false);
      if (kDebugMode) print('Error fetching matches: $error');
    });
  }

  Future<void> refresh() async {
    fetchMatches(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refresh,
            child: matchesArr.isEmpty && !isLoading
                ? const Center(child: Text('No matches available'))
                : ListView.builder(
                    itemCount: matchesArr.length,
                    itemBuilder: (context, index) {
                      return MatchCell(match: matchesArr[index]);
                    },
                  ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class MatchCell extends StatelessWidget {
  final AFLMatch match;

  const MatchCell({super.key, required this.match});

  String _resultText(AFLMatch m) {
    final a = m.team1Goals;
    final b = m.team2Goals;
    if (a > b) {
      return '${m.team1Name} won by ${a - b} goal${a - b > 1 ? 's' : ''}';
    } else if (b > a) {
      return '${m.team2Name} won by ${b - a} goal${b - a > 1 ? 's' : ''}';
    } else {
      return 'Draw';
    }
  }


  String _formatDate(DateTime date) {
    const monthNames = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${date.day}-${monthNames[date.month - 1]}-${date.year}';
  }


  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(match.date);
    final t1 = match.team1Goals * 6 + match.team1Behinds;
    final t2 = match.team2Goals * 6 + match.team2Behinds;
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      title: Text(
        '${match.team1Name} vs ${match.team2Name}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
              'Score: ${match.team1Goals}.${match.team1Behinds}.$t1  –  '
              '${match.team2Goals}.${match.team2Behinds}.$t2',
          ),
          Text(_resultText(match)),
          Text('Venue: ${match.venue} · $formattedDate',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PastMatchDetailsVC(match: match),
        ));
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Match'),
              content: Text(
                  'Are you sure you want to delete ${match.team1Name} vs ${match.team2Name}?'
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')
                ),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red)
                    )
                ),
              ],
            ),
          );
          if (ok == true) {
            try {
              await FirestoreManager().deleteMatch(match.documentID!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match deleted')),
              );
              final parentState = context
                  .findAncestorStateOfType<MatchesVCState>();
              parentState?.fetchMatches(showLoader: true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delete failed: $e')),
              );
            }
          }
        },
      ),

    );
  }
}
