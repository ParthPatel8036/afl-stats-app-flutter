import 'package:afl/controller/home_vc.dart';
import 'package:afl/controller/overlay_dialog.dart';
import 'package:afl/controller/view_add_player.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart';

class TeamsVC extends StatefulWidget {
  const TeamsVC({super.key});

  @override
  TeamsVCState createState() => TeamsVCState();
}

class TeamsVCState extends State<TeamsVC> {
  FirestoreManager firestoreManager = FirestoreManager();
  List<Team> teamsArr = [];
  Team? tappedTeam;
  String teamDialogTitle = "Add New Team";
  int indexTapped = -1;
  bool isLoading = false;
  bool isNoData = false;
  bool isOverlayVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAddTeamOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    fetchTeams(showLoader: true);
  }

  Future<void> fetchTeams({required bool showLoader}) async {
    if (showLoader) {
      setState(() => isLoading = true);
    }
    try {
      List<Team> teams = await firestoreManager.fetchAllTeams();
      setState(() {
        isLoading = false;
        teamsArr = teams.reversed.toList();
        isNoData = teamsArr.isEmpty;
      });
    } catch (error) {
      setState(() => isLoading = false);
      _showSnackBar("Error fetching teams: $error");
    }
  }

  // UI Components
  Widget buildTeamOptionsOverlay() {
    return GestureDetector(
      onTap: hideOptions,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 300,
            height: 288,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 53),
                    const Text(
                      'Team Options',
                      style: TextStyle(
                        fontSize: 23.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: hideOptions,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AFLButtonWidget(
                    title: 'Edit Team Name',
                    onTap: () {
                      hideOptions();
                      teamDialogTitle = 'Edit Team';
                      showAddTeamOverlay();
                    }),
                const SizedBox(height: 10),
                AFLButtonWidget(
                    title: 'Delete',
                    isDestructive: true,
                    onTap: showDeleteConfirmation),
                const SizedBox(height: 10),
                AFLButtonWidget(
                    title: 'Manage Players', onTap: navigateToPlayerManagement)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation
  void navigateToPlayerManagement() {
    setState(() => hideOptions());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAddPlayerVC(
          existingTeamObj: tappedTeam,
          onTeamUpdated: () => fetchTeams(showLoader: false),
        ),
      ),
    );
  }

  // Team Operations
  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text("Delete ${tappedTeam?.name ?? "this team"} permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (tappedTeam != null) {
                hideOptions();
                deleteTeam(tappedTeam!);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTeam(Team team) async {
    showLoader();
    try {
      await firestoreManager.deleteTeam(team.documentID ?? "", (error) {
        if (error != null) {
          throw error;
        } else {
          fetchTeams(showLoader: true);
        }
      });
      setState(
          () => teamsArr.removeWhere((t) => t.documentID == team.documentID));
      hideLoader();
    } catch (error) {
      hideLoader();
      _showSnackBar("Error deleting team: $error");
    }
  }

  Future<void> updateTeam(Team team, String newName) async {
    showLoader();
    try {
      await firestoreManager.updateTeamName(team.documentID ?? "", newName,
          (error) {
        if (error != null) {
          hideLoader();
          _showSnackBar("Error updating team name: $error");
        } else {
          setState(() {
            int index =
                teamsArr.indexWhere((t) => t.documentID == team.documentID);
            if (index != -1) {
              teamsArr[index].name = newName;
              fetchTeams(showLoader: false);
            }
          });
          hideLoader();
        }
      });
    } catch (error) {
      hideLoader();
      _showSnackBar("Error updating team: $error");
    }
  }

  // Helper Methods
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showLoader() => setState(() => isLoading = true);
  void hideLoader() => setState(() => isLoading = false);
  void hideOptions() => setState(() => isOverlayVisible = false);
  void showOptions() => setState(() => isOverlayVisible = true);
  void hideAddTeamOverlay() => setState(() => isAddTeamOverlayVisible = false);
  void showAddTeamOverlay() => setState(() => isAddTeamOverlayVisible = true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'AFL Teams',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: isNoData
                      ? const Center(
                          child: Text(
                          'No teams found',
                          style: TextStyle(fontSize: 18),
                        ))
                      : RefreshIndicator(
                          onRefresh: () => fetchTeams(showLoader: false),
                          child: ListView.separated(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: teamsArr.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) => ListTile(
                              title: Text(
                                teamsArr[index].name ?? "",
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  setState(() {
                                    tappedTeam = teamsArr[index];
                                    showOptions();
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  tappedTeam = teamsArr[index];
                                  showOptions();
                                });
                              },
                            ),
                          ),
                        ),
                ),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AFLButtonWidget(
                        title: 'Create New Team',
                        onTap: () {
                          teamDialogTitle = 'Add New Team';
                          tappedTeam = null;
                          showAddTeamOverlay();
                        })),
              ],
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (isOverlayVisible) buildTeamOptionsOverlay(),
            if (isAddTeamOverlayVisible)
              OverlayDialog(
                title: teamDialogTitle,
                teamObj: tappedTeam,
                onSave: (teamName, oldTeamObj) {
                  if (oldTeamObj != null) {
                    updateTeam(oldTeamObj, teamName);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAddPlayerVC(
                          newTeamObj: Team(name: teamName, players: []),
                          onTeamUpdated: () => fetchTeams(showLoader: false),
                        ),
                      ),
                    );
                  }
                  hideAddTeamOverlay();
                },
                onCancel: hideAddTeamOverlay,
              ),
          ],
        ),
      ),
    );
  }
}
