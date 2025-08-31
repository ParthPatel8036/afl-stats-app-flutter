import 'package:afl/controller/home_vc.dart';
import 'package:afl/controller/live_score.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart'; // The next screen after starting

enum PickerField { team1, team2 }

class MatchDetailsVC extends StatefulWidget {
  final AFLMatch? resumeMatchObj;

  const MatchDetailsVC({super.key, this.resumeMatchObj});

  @override
  MatchDetailsVCState createState() => MatchDetailsVCState();
}

class MatchDetailsVCState extends State<MatchDetailsVC> {
  final FirestoreManager firestoreManager = FirestoreManager();

  final TextEditingController team1Field = TextEditingController();
  final TextEditingController team2Field = TextEditingController();
  final TextEditingController venueField = TextEditingController();
  final TextEditingController dateField = TextEditingController();

  List<Team> teamsArray = [];
  List<Team> pickerTeamsArray = [];
  PickerField pickerOpenedFor = PickerField.team1;

  String selectedTeam1Doc = '';
  String selectedTeam2Doc = '';

  Team? selectedTeam1Obj;
  Team? selectedTeam2Obj;

  DateTime? selectedDate;

  bool isLoading = false;
  bool isInteractionDisabled = false;

  @override
  void initState() {
    super.initState();
    fetchTeams();
    initializeFields();
  }

  void initializeFields() {
    if (widget.resumeMatchObj != null) {
      final m = widget.resumeMatchObj!;
      team1Field.text = m.team1Name;
      team2Field.text = m.team2Name;
      venueField.text = m.venue;
      selectedDate = m.date;
      dateField.text = '${m.date.day}-${m.date.month}-${m.date.year}';
      selectedTeam1Doc = m.team1Doc;
      selectedTeam2Doc = m.team2Doc;
      isInteractionDisabled = true;
    }
  }

  void showLoader() => setState(() => isLoading = true);
  void hideLoader() => setState(() => isLoading = false);

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          action: SnackBarAction(label: 'OK', onPressed: () {})),
    );
  }

  Future<void> fetchTeams() async {
    showLoader();
    try {
      final teams = await firestoreManager.fetchAllTeams();
      setState(() {
        teamsArray = teams.reversed.toList();
      });
    } catch (e) {
      showSnackBar('Error fetching teams: $e');
    } finally {
      hideLoader();
    }
  }

  void showPicker() {
    // Exclude the already-selected other team
    if (pickerOpenedFor == PickerField.team1) {
      pickerTeamsArray =
          teamsArray.where((t) => t.documentID != selectedTeam2Doc).toList();
    } else {
      pickerTeamsArray =
          teamsArray.where((t) => t.documentID != selectedTeam1Doc).toList();
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView.builder(
          itemCount: pickerTeamsArray.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(pickerTeamsArray[i].name ?? ''),
            onTap: () => handlePickerItemSelected(i),
          ),
        ),
      ),
    );
  }

  void handlePickerItemSelected(int index) {
    Navigator.pop(context);
    setState(() {
      final team = pickerTeamsArray[index];
      if (pickerOpenedFor == PickerField.team1) {
        selectedTeam1Doc = team.documentID ?? '';
        selectedTeam1Obj = team;
        team1Field.text = team.name ?? '';
      } else {
        selectedTeam2Doc = team.documentID ?? '';
        selectedTeam2Obj = team;
        team2Field.text = team.name ?? '';
      }
    });
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateField.text = '${picked.day}-${picked.month}-${picked.year}';
      });
    }
  }

  void goToScoreboard(AFLMatch match) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LiveMatchVC(matchObj: match),
    ));
  }

  Future<void> addMatch() async {
    showLoader();
    try {
      final match = AFLMatch(
        team1Name: team1Field.text,
        team2Name: team2Field.text,
        team1Doc: selectedTeam1Doc,
        team2Doc: selectedTeam2Doc,
        venue: venueField.text,
        date: selectedDate ?? DateTime.now(),
      );

      final docId = await firestoreManager.addMatch(match);
      match.documentID = docId;
      showSnackBar('Match created! Starting scoreboard…');
      goToScoreboard(match);
    } catch (e) {
      showSnackBar('Error adding match: $e');
    } finally {
      hideLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        leading: isInteractionDisabled
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Team 1 picker
                  TextField(
                    controller: team1Field,
                    readOnly: true,
                    onTap: isInteractionDisabled
                        ? null
                        : () {
                            pickerOpenedFor = PickerField.team1;
                            showPicker();
                          },
                    decoration: const InputDecoration(
                      labelText: 'Team 1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Team 2 picker
                  TextField(
                    controller: team2Field,
                    readOnly: true,
                    onTap: isInteractionDisabled
                        ? null
                        : () {
                            pickerOpenedFor = PickerField.team2;
                            showPicker();
                          },
                    decoration: const InputDecoration(
                      labelText: 'Team 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  TextField(
                    controller: dateField,
                    readOnly: true,
                    onTap: isInteractionDisabled ? null : pickDate,
                    decoration: const InputDecoration(
                      labelText: 'Match Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Venue entry
                  TextField(
                    controller: venueField,
                    readOnly: isInteractionDisabled,
                    decoration: const InputDecoration(
                      labelText: 'Venue',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AFLButtonWidget(
                    title: widget.resumeMatchObj != null
                        ? 'Resume Match'
                        : 'Start Match',
                    onTap: () {
                      if (team1Field.text.isEmpty) {
                        showSnackBar('Please select Team 1');
                      } else if (team2Field.text.isEmpty) {
                        showSnackBar('Please select Team 2');
                      } else if (dateField.text.isEmpty) {
                        showSnackBar('Please pick a match date');
                      } else if (venueField.text.isEmpty) {
                        showSnackBar('Please enter a venue');
                      } else {
                        if (widget.resumeMatchObj != null) {
                          goToScoreboard(widget.resumeMatchObj!);
                        } else {
                          addMatch();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
