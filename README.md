# AFL Stats App (Flutter) 🏉

[![Flutter](https://img.shields.io/badge/Flutter-Mobile-blue?logo=flutter)](#)
[![Firebase](https://img.shields.io/badge/Firebase-Client-orange?logo=firebase)](#)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-success)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A match statistics app to **manage teams & lineups**, **start/resume matches**, **live-score events**, review **past matches**, and **compare players/teams**.  
Built with **Flutter** + **Firebase**.

---

## ✨ Features
- 👥 Manage Teams & Lineups  
- 🕹️ Start / Resume Match  
- 📊 Live scoring & match details  
- 🗂️ Past matches & results  
- ⚖️ Compare Players & Teams  
- 🕒 Optional 4-Quarter system

---

## 🚀 Getting Started

~~~bash
# 1) Install deps
flutter pub get

# 2) (Recommended) Configure Firebase for your own project
#    Generates lib/firebase_options.dart
dart pub global activate flutterfire_cli
flutterfire configure

# 3) Run
flutter run
~~~

> **Security note:** Keep API keys **restricted** (by package/bundle ID & SHA-1) and only enable APIs you actually use.

---

## 📸 Screenshots (with filenames)

<table>
  <tr>
    <td align="center"><img src="screenshots/home.png" width="210" alt="home"/><div><sub>home.png</sub></div></td>
    <td align="center"><img src="screenshots/create_team.png" width="210" alt="create_team"/><div><sub>create_team.png</sub></div></td>
    <td align="center"><img src="screenshots/create_player.png" width="210" alt="create_player"/><div><sub>create_player.png</sub></div></td>
    <td align="center"><img src="screenshots/manage_team_and_lineups.png" width="210" alt="manage_team_and_lineups"/><div><sub>manage_team_and_lineups.png</sub></div></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/create_match.png" width="210" alt="create_match"/><div><sub>create_match.png</sub></div></td>
    <td align="center"><img src="screenshots/match_preview.png" width="210" alt="match_preview"/><div><sub>match_preview.png</sub></div></td>
    <td align="center"><img src="screenshots/match_details.png" width="210" alt="match_details"/><div><sub>match_details.png</sub></div></td>
    <td align="center"><img src="screenshots/match_completed.png" width="210" alt="match_completed"/><div><sub>match_completed.png</sub></div></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/matches_result.png" width="210" alt="matches_result"/><div><sub>matches_result.png</sub></div></td>
    <td align="center"><img src="screenshots/recent_matches.png" width="210" alt="recent_matches"/><div><sub>recent_matches.png</sub></div></td>
    <td align="center"><img src="screenshots/compare_players_and_teams.png" width="210" alt="compare_players_and_teams"/><div><sub>compare_players_and_teams.png</sub></div></td>
    <td align="center"><img src="screenshots/teams_comparsion.png" width="210" alt="Teams Compersion"/><div><sub>Teams Comparsion.png</sub></div></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/players_comparsion.png" width="210" alt="Players Compersion"/><div><sub>Players Comparsion.png</sub></div></td>
    <td align="center"><img src="screenshots/4_quater_system.png" width="210" alt="4 Quater System"/><div><sub>4 Quater System.png</sub></div></td>
    <td align="center"><img src="screenshots/add_profile_photo.png" width="210" alt="add_profile_photo"/><div><sub>add_profile_photo.png</sub></div></td>
    <td align="center"><img src="screenshots/delete_team.png" width="210" alt="delete_team"/><div><sub>delete_team.png</sub></div></td>
  </tr>
</table>

---

## 🎥 Demo Video

<video src="media/afl-demo.mp4" width="720" controls poster="screenshots/Home.png"></video>  

If your browser doesn’t show the player, view/download directly: **[media/afl-demo.mp4](media/afl-demo.mp4)**

---

## 🧱 Project Structure (high-level)

lib/
  constants/
  controller/        # screens & controllers (home, live_score, etc.)
  models/            # data models, firebase manager
  services/          # notification_service.dart
  main.dart

---

## 🛠️ Build APK
~~~bash
flutter build apk --release
~~~
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📄 License
This project is licensed under the **MIT License** – see [LICENSE](LICENSE).
