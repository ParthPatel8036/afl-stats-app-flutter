import 'dart:developer';

import 'package:afl/constants/constants.dart';
import 'package:afl/controller/home_vc.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart';

import 'add_player_vc.dart';

class ViewAddPlayerVC extends StatefulWidget {
  final Team? newTeamObj;
  final Team? existingTeamObj;
  final VoidCallback? onTeamUpdated;

  const ViewAddPlayerVC({
    super.key,
    this.newTeamObj,
    this.existingTeamObj,
    this.onTeamUpdated,
  });

  @override
  ViewAddPlayerVCState createState() => ViewAddPlayerVCState();
}

class ViewAddPlayerVCState extends State<ViewAddPlayerVC> {
  final FirestoreManager firestoreManager = FirestoreManager();
  bool isLoading = false;
  bool isNoData = false;
  List<Player> players = [];
  List<Player> newOrUpdatedPlayers = [];
  Player? tappedPlayer;
  int indexTapped = -1;
  late String teamName;
  bool isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    players =
        widget.existingTeamObj?.players ?? widget.newTeamObj?.players ?? [];
    teamName =
        widget.existingTeamObj?.name ?? widget.newTeamObj?.name ?? 'Team';
    isNoData = players.isEmpty;
  }

  void showLoader() => setState(() => isLoading = true);
  void hideLoader() => setState(() => isLoading = false);

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  Future<void> deletePlayer(Player player) async {
    showLoader();
    try {
      // You’ll need a matching deletePlayer(teamId, playerId) in your FirestoreManager
      await firestoreManager.deletePlayer(
          widget.existingTeamObj?.documentID ?? '', player.documentID ?? '',
          (error) {
        if (error != null) {
          throw error;
        }
      });
      setState(
          () => players.removeWhere((p) => p.documentID == player.documentID));
      widget.onTeamUpdated?.call();
    } catch (error) {
      showSnackBar('Error deleting player: $error');
    } finally {
      hideLoader();
    }
  }

  Future<void> changeCaptainStatus(
      String teamId, String playerId, bool status) async {
    // You’ll need updateSpecificPlayerCaptainStatus(teamId, playerId, status) in FirestoreManager
    await firestoreManager.updateSpecificPlayerCaptainStatus(
      teamId,
      playerId,
      status,
      (error) {
        if (error != null) {
          showSnackBar("Something went wrong please Try again later");
        } else {
          log("Player captain status updated successfully!");
        }
      },
    );
  }

  void updateCaptain() async {
    final teamId = widget.existingTeamObj?.documentID ??
        widget.newTeamObj?.documentID ??
        '';
    if (teamId.isEmpty || tappedPlayer == null) return;

    // Clear old captain
    for (var p in players) {
      if (p.isCaptain) {
        p.isCaptain = false;
        if (widget.existingTeamObj != null) {
          await changeCaptainStatus(teamId, p.documentID!, false);
        }
        break;
      }
    }

    // Set new captain
    tappedPlayer!.isCaptain = true;
    if (widget.existingTeamObj != null) {
      await changeCaptainStatus(teamId, tappedPlayer!.documentID!, true);
    }

    widget.onTeamUpdated?.call();
    setState(() => isOverlayVisible = false);
    showSnackBar('Captain updated');
  }

  void updateTeamButton() async {
    if (widget.existingTeamObj != null) {
      // Existing team: update or add players
      showLoader();
      final teamId = widget.existingTeamObj!.documentID!;
      try {
        final futures = <Future>[];
        for (var p in newOrUpdatedPlayers) {
          if (p.documentID != null) {
            futures.add(firestoreManager
                .updatePlayerInTeam(teamId, p.documentID!, p, (error) {
              if (error != null) {
                // Handle the error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error updating player')),
                );
              } else {
                // Handle success
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player updated successfully')),
                );
              }
            }));
          } else {
            futures.add(firestoreManager.addPlayerToTeam(teamId, p));
          }
        }
        await Future.wait(futures);
        showSnackBar('Team updated successfully');
        widget.onTeamUpdated?.call();
      } catch (error) {
        showSnackBar('Error updating team: $error');
      } finally {
        hideLoader();
      }
    } else {
      // New team: must have 2 players
      if ((players.length) < 2) {
        showSnackBar('Please add atleast two (2) players to the team');
        return;
      }
      widget.newTeamObj!.players = players;
      if (!widget.newTeamObj!.players.any((p) => p.isCaptain)) {
        widget.newTeamObj!.players.first.isCaptain = true;
      }
      showLoader();
      try {
        await firestoreManager.addNewTeam(widget.newTeamObj!);
        widget.onTeamUpdated?.call();
        showSnackBar('Team added successfully');
        Navigator.pop(context);
      } catch (error) {
        showSnackBar('Error adding team: $error');
      } finally {
        hideLoader();
      }
    }
  }

  void showCustomAlert({
    required String title,
    required String message,
    required String confirmButtonTitle,
    required VoidCallback onConfirm,
    bool showCancel = true,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showCancel)
            TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(ctx)),
          TextButton(
            child: Text(confirmButtonTitle,
                style: const TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  void hideOptionsView() => setState(() => isOverlayVisible = false);
  void showOptionsView() => setState(() => isOverlayVisible = true);

  void limitExceedError() {
    showSnackBar('Cannot add more than eighteen (18) players in a team');
  }

  void goToAddPlayer() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlayerVC(
        title: 'Add Player',
        onSave: (player) {
          setState(() {
            players.add(player);
            newOrUpdatedPlayers.add(player);
            widget.newTeamObj?.players = players;
            isNoData = false;
          });
        },
      ),
    ));
  }

  void goToEditPlayer() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlayerVC(
        title: 'Edit Player',
        existingPlayer: tappedPlayer,
        onSave: (player) {
          setState(() {
            players[indexTapped] = player;
            final idx = newOrUpdatedPlayers
                .indexWhere((p) => p.documentID == player.documentID);
            if (idx != -1) {
              newOrUpdatedPlayers[idx] = player;
            } else {
              newOrUpdatedPlayers.add(player);
            }
          });
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team Profile',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 45,
                color: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  '$teamName Players',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Player list or empty state
              Expanded(
                child: isNoData
                    ? const Center(child: Text('No data available'))
                    : ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (ctx, i) {
                          final p = players[i];
                          return PlayerCell(
                            player: p,
                            onTap: () {
                              setState(() {
                                tappedPlayer = p;
                                indexTapped = i;
                                showOptionsView();
                              });
                            },
                          );
                        },
                      ),
              ),

              // Add / Update buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 40),
                child: Column(
                  children: [
                    AFLButtonWidget(
                        title: 'Add New Player',
                        onTap: players.length < 18
                            ? goToAddPlayer
                            : limitExceedError),
                    const SizedBox(height: 10),
                    AFLButtonWidget(
                        title: widget.existingTeamObj != null
                            ? 'Update Team'
                            : 'Add Team',
                        onTap: updateTeamButton),
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Options overlay
          if (isOverlayVisible && tappedPlayer != null)
            GestureDetector(
              onTap: hideOptionsView,
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          const Text(
                            'Player Options',
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: hideOptionsView,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AFLButtonWidget(
                          title: 'Edit Player',
                          onTap: () {
                            hideOptionsView();
                            goToEditPlayer();
                          }),
                      const SizedBox(height: 10),
                      AFLButtonWidget(
                          title: 'Delete',
                          isDestructive: true,
                          onTap: () {
                            showCustomAlert(
                              title: 'Delete Player',
                              message: 'Delete ${tappedPlayer!.name}? ',
                              confirmButtonTitle: 'Confirm',
                              onConfirm: () {
                                deletePlayer(tappedPlayer!);
                                hideOptionsView();
                              },
                            );
                          }),
                      const SizedBox(height: 10),
                      AFLButtonWidget(
                          title: 'Make Captain',
                          onTap: () {
                            updateCaptain();
                          }),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PlayerCell extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const PlayerCell({
    super.key,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Local image or placeholder
            ClipOval(
              child: player.image != null
                  ? Image.file(player.image!,
                      width: 53, height: 53, fit: BoxFit.cover)
                  : Image.asset('assets/userIcon.png',
                      width: 53, height: 53, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),

            // Name + captain badge
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: player.name ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (player.isCaptain)
                      const TextSpan(
                        text: ' (C)',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),

            // AFL stats summary
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('G: ${player.goals}',
                    style: const TextStyle(fontSize: 14)),
                Text('B: ${player.behinds}',
                    style: const TextStyle(fontSize: 14)),
                Text('K: ${player.kicks}',
                    style: const TextStyle(fontSize: 14)),
                Text('HB: ${player.handballs}',
                    style: const TextStyle(fontSize: 14)),
                Text('M: ${player.marks}',
                    style: const TextStyle(fontSize: 14)),
                Text('T: ${player.tackles}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
