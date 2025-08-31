import 'package:afl/constants/constants.dart';
import 'package:afl/controller/match_details_vc.dart';
import 'package:afl/controller/matches_vc.dart';
import 'package:afl/controller/teams_vc.dart';
import 'package:afl/models/firebase_manager.dart';
import 'package:afl/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:afl/controller/compare_vc.dart';


class HomeVC extends StatefulWidget {
  const HomeVC({super.key});

  @override
  State<HomeVC> createState() => HomeVCState();
}

class HomeVCState extends State<HomeVC> {
  FirestoreManager firestoreManager = FirestoreManager();
  bool isLoading = false;

  void showLoader() {
    setState(() {
      isLoading = true;
    });
  }

  void hideLoader() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/aflLogo.png',
                  width: 122,
                  height: 122,
                ),
                const SizedBox(height: 11),
                const Text(
                  'AFL',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 37),
                AFLButtonWidget(
                  title: 'Manage Teams and Lineups',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TeamsVC()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                AFLButtonWidget(
                  title: 'Start a New Match',
                  onTap: () {
                    navigateToResume(null);
                  },
                ),
                const SizedBox(height: 10),
                AFLButtonWidget(
                  title: 'View Past Matches',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const MatchesVC()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                AFLButtonWidget(
                  title: 'Resume Match',
                  onTap: () {
                    fetchActiveMatchAndResume();
                  },
                ),
                const SizedBox(height: 10),
                AFLButtonWidget(
                  title: 'Compare Players/Teams',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CompareVC()),
                    );
                  },
                ),

              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitCircle(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void navigateToResume(AFLMatch? match) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => MatchDetailsVC(resumeMatchObj: match)),
    );
  }

  void fetchActiveMatchAndResume() async {
    showLoader();
    try {
      AFLMatch? match = await firestoreManager.fetchActiveMatch();
      hideLoader();
      if (match != null) {
        navigateToResume(match);
      } else {
        showSnackBar("No active match found");
      }
    } catch (error) {
      hideLoader();
      showSnackBar("Something went wrong. Try again later.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

class AFLButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const AFLButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? Colors.blue : AppColors.primaryColor,
        minimumSize: const Size(double.infinity, 50),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
