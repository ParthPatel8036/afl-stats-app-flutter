import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  String? documentID;
  String? name;
  bool isCaptain;
  File? image;
  int goals;
  int behinds;
  int kicks;
  int handballs;
  int marks;
  int tackles;

  Player({
    this.documentID,
    this.name,
    this.isCaptain = false,
    this.image,
    this.goals = 0,
    this.behinds = 0,
    this.kicks = 0,
    this.handballs = 0,
    this.marks = 0,
    this.tackles = 0,
  });

  Player.fromFirestore(Map<String, dynamic> data, String id)
      : documentID = id,
        name = data["name"],
        isCaptain = data["isCaptain"] ?? false,
        goals = data["goals"] ?? 0,
        behinds = data["behinds"] ?? 0,
        kicks = data["kicks"] ?? 0,
        handballs = data["handballs"] ?? 0,
        marks = data["marks"] ?? 0,
        tackles = data["tackles"] ?? 0,
        image = null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCaptain': isCaptain,
      'goals': goals,
      'behinds': behinds,
      'kicks': kicks,
      'handballs': handballs,
      'marks': marks,
      'tackles': tackles,
    };
  }
}

class Team {
  String? documentID;
  String? name;
  List<Player> players;

  Team({
    this.documentID,
    this.name,
    required this.players,
  });

  Team.fromFirestore(Map<String, dynamic>? data, String id,
      List<Map<String, dynamic>> playersData)
      : documentID = id,
        name = data?["name"],
        players = playersData.map((playerMap) {
          String playerId = playerMap["id"];
          return Player.fromFirestore(playerMap, playerId);
        }).toList();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

enum MatchStatus {
  yetToStart,
  inProgress,
  completed,
}

class AFLMatch {
  String? documentID;
  String team1Name;
  String team2Name;
  String team1Doc;
  String team2Doc;
  MatchStatus status;
  String venue;
  DateTime date;
  int quarter;
  int team1Goals;
  int team1Behinds;
  int team2Goals;
  int team2Behinds;

  AFLMatch({
    this.documentID,
    required this.team1Name,
    required this.team2Name,
    required this.team1Doc,
    required this.team2Doc,
    this.status = MatchStatus.yetToStart,
    required this.venue,
    required this.date,
    this.quarter = 1,
    this.team1Goals = 0,
    this.team1Behinds = 0,
    this.team2Goals = 0,
    this.team2Behinds = 0,
  });

  AFLMatch.fromFirestore(Map<String, dynamic> data, String id)
      : documentID = id,
        team1Name = data["team1Name"],
        team2Name = data["team2Name"],
        team1Doc = data["team1Doc"],
        team2Doc = data["team2Doc"],
        status = MatchStatus.values.firstWhere(
            (e) => e.toString() == "MatchStatus.${data["status"]}",
            orElse: () => MatchStatus.yetToStart),
        venue = data["venue"],
        date = (data["date"] as Timestamp).toDate(),
        quarter = data["quarter"] ?? 1,
        team1Goals = data["team1Goals"] ?? 0,
        team1Behinds = data["team1Behinds"] ?? 0,
        team2Goals = data["team2Goals"] ?? 0,
        team2Behinds = data["team2Behinds"] ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Doc': team1Doc,
      'team2Doc': team2Doc,
      'status': status.toString().split('.').last,
      'venue': venue,
      'date': date,
      'quarter': quarter,
      'team1Goals': team1Goals,
      'team1Behinds': team1Behinds,
      'team2Goals': team2Goals,
      'team2Behinds': team2Behinds,
    };
  }
}
extension PlayerStats on Player {
  Map<String,int> statsMap() => {
    'Kicks'      : kicks,
    'Handballs'  : handballs,
    'Marks'      : marks,
    'Tackles'    : tackles,
    'Goals'      : goals,
    'Behinds'    : behinds,
    'Total Score': goals * 6 + behinds,
  };
}

extension TeamStats on Team {
  Map<String,int> aggregateStats() {
    final agg = <String,int>{
      'Kicks'      : 0,
      'Handballs'  : 0,
      'Marks'      : 0,
      'Tackles'    : 0,
      'Goals'      : 0,
      'Behinds'    : 0,
      'Total Score': 0,
    };
    for (final p in players) {
      agg['Kicks']      = agg['Kicks']!      + p.kicks;
      agg['Handballs']  = agg['Handballs']!  + p.handballs;
      agg['Marks']      = agg['Marks']!      + p.marks;
      agg['Tackles']    = agg['Tackles']!    + p.tackles;
      agg['Goals']      = agg['Goals']!      + p.goals;
      agg['Behinds']    = agg['Behinds']!    + p.behinds;
      agg['Total Score']= agg['Total Score']!+ (p.goals * 6 + p.behinds);
    }
    return agg;
  }
}