import 'package:flutter/material.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';

enum CompareType { player, team }

class CompareVC extends StatefulWidget {
  const CompareVC({super.key});

  @override
  _CompareVCState createState() => _CompareVCState();
}

class _CompareVCState extends State<CompareVC> {
  final fm = FirestoreManager();
  CompareType _type = CompareType.player;

  List<Player> _allPlayers = [];
  List<Team>   _allTeams   = [];

  Player? _firstPlayer;
  Player? _secondPlayer;

  Team? _firstTeam;
  Team? _secondTeam;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final teams   = await fm.fetchAllTeams();
    final players = teams.expand((t) => t.players).toList();
    setState(() {
      _allTeams   = teams;
      _allPlayers = players;
    });
  }

  Widget _picker<T>({
    required String label,
    required List<T> items,
    required T? selected,
    required String Function(T) display,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label),
      initialValue: selected,
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(display(i))))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildComparisonTable() {
    if (_type == CompareType.player) {
      if (_firstPlayer == null || _secondPlayer == null) {
        return const Center(child: Text('Pick two players'));
      }
      return _buildSideBySideStats(
        leftName:  _firstPlayer!.name!,
        rightName: _secondPlayer!.name!,
        leftStats:  _firstPlayer!.statsMap(),
        rightStats: _secondPlayer!.statsMap(),
      );
    } else {
      if (_firstTeam == null || _secondTeam == null) {
        return const Center(child: Text('Pick two teams'));
      }
      return _buildSideBySideStats(
        leftName:  _firstTeam!.name!,
        rightName: _secondTeam!.name!,
        leftStats:  _firstTeam!.aggregateStats(),
        rightStats: _secondTeam!.aggregateStats(),
      );
    }
  }

  Widget _buildSideBySideStats({
    required String leftName,
    required String rightName,
    required Map<String,int> leftStats,
    required Map<String,int> rightStats,
  }) {
    final keys = leftStats.keys.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columns: [
          DataColumn(label: Text(leftName, style: const TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(label: Text('Stat')),
          DataColumn(label: Text(rightName, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: keys.map((k) {
          return DataRow(cells: [
            DataCell(Text('${leftStats[k]}')),
            DataCell(Text(k)),
            DataCell(Text('${rightStats[k]}')),
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Player'),
                selected: _type == CompareType.player,
                onSelected: (_) => setState(() {
                  _type = CompareType.player;
                  _firstTeam = _secondTeam = null;
                }),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Team'),
                selected: _type == CompareType.team,
                onSelected: (_) => setState(() {
                  _type = CompareType.team;
                  _firstPlayer = _secondPlayer = null;
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _type == CompareType.player
                ? Column(
              children: [
                _picker<Player>(
                  label: 'First Player',
                  items: _allPlayers,
                  selected: _firstPlayer,
                  display: (p) => p.name!,
                  onChanged: (p) => setState(() => _firstPlayer = p),
                ),
                _picker<Player>(
                  label: 'Second Player',
                  items: _allPlayers.where((p) => p != _firstPlayer).toList(),
                  selected: _secondPlayer,
                  display: (p) => p.name!,
                  onChanged: (p) => setState(() => _secondPlayer = p),
                ),
              ],
            )
                : Column(
              children: [
                _picker<Team>(
                  label: 'First Team',
                  items: _allTeams,
                  selected: _firstTeam,
                  display: (t) => t.name!,
                  onChanged: (t) => setState(() => _firstTeam = t),
                ),
                _picker<Team>(
                  label: 'Second Team',
                  items: _allTeams.where((t) => t != _firstTeam).toList(),
                  selected: _secondTeam,
                  display: (t) => t.name!,
                  onChanged: (t) => setState(() => _secondTeam = t),
                ),
              ],
            ),
          ),

          const Divider(),
          Expanded(child: _buildComparisonTable()),
        ],
      ),
    );
  }
}
