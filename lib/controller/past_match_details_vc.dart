import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart';

class PastMatchDetailsVC extends StatefulWidget {
  final AFLMatch match;

  const PastMatchDetailsVC({super.key, required this.match});

  @override
  PastMatchDetailsVCState createState() => PastMatchDetailsVCState();
}

class PastMatchDetailsVCState extends State<PastMatchDetailsVC> {
  final FirestoreManager _firestore = FirestoreManager();

  bool _isLoading = true;
  Team? _team1;
  Team? _team2;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final allTeams = await _firestore.fetchAllTeams();
    setState(() {
      _team1 = allTeams.firstWhere(
            (t) => t.documentID == widget.match.team1Doc,
             orElse: () => Team(
                documentID: widget.match.team1Doc,
                name: widget.match.team1Name,
                players: [],
             ),
      );
      _team2 = allTeams.firstWhere(
            (t) => t.documentID == widget.match.team2Doc,
            orElse: () => Team(
              documentID: widget.match.team2Doc,
              name: widget.match.team2Name,
              players: [],
            ),
      );
      _isLoading = false;
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  String get _winner {
    final a = widget.match.team1Goals;
    final b = widget.match.team2Goals;
    if (a > b) return widget.match.team1Name;
    if (b > a) return widget.match.team2Name;
    return 'Draw';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final t1 = widget.match.team1Goals * 6 + widget.match.team1Behinds;
    final t2 = widget.match.team2Goals * 6 + widget.match.team2Behinds;
    return Scaffold(
      appBar: AppBar(
        title: Text('${m.team1Name} vs ${m.team2Name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(m.date)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Venue: ${m.venue}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              'Final Score: '
                  '${widget.match.team1Goals}.${widget.match.team1Behinds}.$t1'
                  '  –  '
                  '${widget.match.team2Goals}.${widget.match.team2Behinds}.$t2',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),
            Text('Winner: $_winner',
                style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            if (_team1 != null) ...[
              Text('${m.team1Name} Players',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._team1!.players.map(_buildPlayerTile),
              const Divider(height: 32),
            ],
            if (_team2 != null) ...[
              Text('${m.team2Name} Players',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._team2!.players.map(_buildPlayerTile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Player p) {
    final stats = [
      '${p.kicks} K',
      '${p.handballs} HB',
      '${p.goals} G',
      '${p.behinds} B',
      '${p.marks} M',
      '${p.tackles} T',
    ].join(' · ');
    return ListTile(
      title: Text(p.name ?? ''),
      subtitle: Text(stats),
    );
  }
}
