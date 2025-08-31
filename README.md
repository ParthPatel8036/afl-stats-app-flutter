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
    <td align="center"><img src="screenshots/Home.png" width="210" alt="Home"/><div><sub>Home.png</sub></div></td>
    <td align="center"><img src="screenshots/Create%20Team.png" width="210" alt="Create Team"/><div><sub>Create Team.png</sub></div></td>
    <td align="center"><img src="screenshots/Create%20Player.png" width="210" alt="Create Player"/><div><sub>Create Player.png</sub></div></td>
    <td align="center"><img src="screenshots/Manage%20Team%20%26%20Lineups.png" width="210" alt="Manage Team & Lineups"/><div><sub>Manage Team & Lineups.png</sub></div></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/Create%20Match.png" width="210" alt="Create Match"/><div><sub>Create Match.png</sub></div></td>
    <td align="center"><img src="screenshots/Match%20Preview.png" width="210" alt="Match Preview"/><div><sub>Match Preview.png</sub></div></td>
    <td align="center"><img src="screenshots/Match%20Details.png" width="210" alt="Match Details"/><div><sub>Match Details.png</sub></div></td>
    <td align="center"><img src="screenshots/Match%20Completed.png" width="210" alt="Match Completed"/><div><sub>Match Completed.png</sub></div></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/Matches%20Result.png" width="210" alt="Matches Result"/><div><sub>Matches Result.png</sub></div></td>
    <td align="center"><img src="screenshots/Recent%20Matches.png" width="210" alt="Recent Matches"/><div><sub>Recent Matches.png</sub></div></td>
    <td align="center"><img src="screenshots/Compare%20Players%20%26%20Teams.png" width="210" alt="Compare Players & Teams"/><div><sub>Compare Players & Teams.png</sub></div></td>
    <td align="center"><img src="screenshots/Teams%20Compersion.png" width="210" alt="Teams Compersion"/><div><sub>Teams Compersion.png</sub></div></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/Players%20Compersion.png" width="210" alt="Players Compersion"/><div><sub>Players Compersion.png</sub></div></td>
    <td align="center"><img src="screenshots/4%20Quater%20System.png" width="210" alt="4 Quater System"/><div><sub>4 Quater System.png</sub></div></td>
    <td align="center"><img src="screenshots/Add%20Profile%20Photo.png" width="210" alt="Add Profile Photo"/><div><sub>Add Profile Photo.png</sub></div></td>
    <td align="center"><img src="screenshots/Delete%20Team.png" width="210" alt="Delete Team"/><div><sub>Delete Team.png</sub></div></td>
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
