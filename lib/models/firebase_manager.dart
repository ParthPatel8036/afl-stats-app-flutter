import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';

class FirestoreManager {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addNewTeam(Team team) async {
    try {
      DocumentReference teamRef =
          await db.collection('teams').add(team.toMap());

      for (Player player in team.players) {
        await addPlayerToTeam(teamRef.id, player);
      }
    } catch (error) {
      dev.log('Error adding team: $error');
      rethrow;
    }
  }

  Future<void> deletePlayer(
      String teamId, String playerId, Function(Error?) completion) async {
    final playerReference =
        db.collection("teams").doc(teamId).collection("players").doc(playerId);

    try {
      var document = await playerReference.get();
      if (!document.exists) {
        throw Exception("Player document not found");
      }
      await playerReference.delete();

      await checkAndUpdateCaptain(teamId, completion);
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<void> checkAndUpdateCaptain(
      String teamId, Function(Error?) completion) async {
    try {
      var querySnapshot = await db
          .collection("teams")
          .doc(teamId)
          .collection("players")
          .where("isCaptain", isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await makeRandomPlayerCaptain(teamId, completion);
      } else {
        completion(null);
      }
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<void> updateTeamName(
      String teamId, String newName, Function(Error?) completion) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection("teams").doc(teamId).update({"name": newName});
      completion(null);
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<void> deleteTeam(String teamId, Function(Error?) completion) async {
    try {
      await db.collection("teams").doc(teamId).delete();
      completion(null);
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<List<Team>> fetchAllTeams() async {
    var qs = await db.collection('teams').get();
    var teams = <Team>[];
    for (var doc in qs.docs) {
      var playersSnap =
          await db.collection('teams').doc(doc.id).collection('players').get();
      var playersData =
          playersSnap.docs.map((p) => {'id': p.id, ...p.data()}).toList();
      teams.add(Team.fromFirestore(doc.data(), doc.id, playersData));
    }
    return teams;
  }

  Future<void> makeRandomPlayerCaptain(
      String teamId, Function(Error?) completion) async {
    try {
      var querySnapshot =
          await db.collection("teams").doc(teamId).collection("players").get();

      if (querySnapshot.docs.isEmpty) {
        completion(null);
        return;
      }

      var documents = querySnapshot.docs;
      var randomIndex = documents.isEmpty
          ? 0
          : (documents.length * Random().nextDouble()).toInt();
      var randomPlayerId = documents[randomIndex].id;

      await updateSpecificPlayerCaptainStatus(
          teamId, randomPlayerId, true, completion);
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<void> updateSpecificPlayerCaptainStatus(String teamId, String playerId,
      bool isCaptain, Function(Error?) completion) async {
    final playerReference =
        db.collection("teams").doc(teamId).collection("players").doc(playerId);

    try {
      await playerReference.update({"isCaptain": isCaptain});
      completion(null);
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<void> updatePlayerInTeam(
    String teamId,
    String playerId,
    Player player,
    Function(Error?) completion,
  ) async {
    try {
      await db
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .doc(playerId)
          .update(player.toMap());
      completion(null);
    } catch (error) {
      completion(error as Error?);
    }
  }

  Future<void> addPlayerToTeam(String teamId, Player player) async {
    try {
      Map<String, dynamic> playerData = player.toMap();
      await db
          .collection('teams')
          .doc(teamId)
          .collection('players')
          .add(playerData);
    } catch (error) {
      dev.log('Error adding player: $error');
      rethrow;
    }
  }

  Future<String> addMatch(AFLMatch match) async {
    var doc = await db.collection('matches').add(match.toMap());
    return doc.id;
  }

  Future<List<AFLMatch>> fetchAllMatches() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      var matchesSnapshot = await firestore.collection("matches").get();

      var matches = <AFLMatch>[];
      for (var document in matchesSnapshot.docs) {
        var data = document.data();
        var matchId = document.id;

        var match = AFLMatch.fromFirestore(data, matchId);

        matches.add(match);
      }
      return matches;
    } catch (error) {
      rethrow;
    }
  }

  Future<AFLMatch?> fetchActiveMatch() async {
    var qs = await db
        .collection('matches')
        .where('status', whereIn: ['yetToStart', 'inProgress']).get();
    if (qs.docs.isEmpty) return null;
    var d = qs.docs.first;
    return AFLMatch.fromFirestore(d.data(), d.id);
  }

  Future<void> updateMatchDetails(
    AFLMatch match,
    Function(Error?) completion,
  ) async {
    final matchReference = db.collection('matches').doc(match.documentID);
    try {
      await matchReference.update({
        'team1Goals': match.team1Goals,
        'team1Behinds': match.team1Behinds,
        'team2Goals': match.team2Goals,
        'team2Behinds': match.team2Behinds,
        'quarter': match.quarter,
        'status': match.status.toString().split('.').last,
      });
      completion(null);
    } catch (error) {
      completion(error as Error?);
    }
  }

  /// Updates just the match status (e.g. to completed) for an AFLMatch.
  Future<void> updateMatchStatus(
    MatchStatus status,
    AFLMatch match,
  ) async {
    final matchReference = db.collection('matches').doc(match.documentID);
    try {
      await matchReference.update({
        'status': status.toString().split('.').last,
      });
    } catch (error) {
      throw Exception('Failed to update match status: $error');
    }
  }

  Future<void> updateMatchScore(
    String matchId, {
    int? quarter,
    int? team1Goals,
    int? team1Behinds,
    int? team2Goals,
    int? team2Behinds,
  }) async {
    var data = <String, dynamic>{};
    if (quarter != null) data['quarter'] = quarter;
    if (team1Goals != null) data['team1Goals'] = team1Goals;
    if (team1Behinds != null) data['team1Behinds'] = team1Behinds;
    if (team2Goals != null) data['team2Goals'] = team2Goals;
    if (team2Behinds != null) data['team2Behinds'] = team2Behinds;
    await db.collection('matches').doc(matchId).update(data);
  }
  Future<void> deleteMatch(String matchId) {
    return db.collection('matches').doc(matchId).delete();
  }
}
