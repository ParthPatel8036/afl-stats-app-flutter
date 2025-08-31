\# AFL Stats App (Flutter) 🏉



\[!\[Flutter](https://img.shields.io/badge/Flutter-Mobile-blue?logo=flutter)](#)

\[!\[Firebase](https://img.shields.io/badge/Firebase-Client-orange?logo=firebase)](#)

\[!\[Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-success)](#)

\[!\[License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)



A match statistics app to \*\*manage teams \& lineups\*\*, \*\*start/resume matches\*\*, \*\*live-score events\*\*, review \*\*past matches\*\*, and \*\*compare players/teams\*\*.  

Built with \*\*Flutter\*\* + \*\*Firebase\*\*.



---



\## ✨ Features

\- 👥 Manage Teams \& Lineups  

\- 🕹️ Start / Resume Match  

\- 📊 Live scoring \& match details  

\- 🗂️ Past matches \& results  

\- ⚖️ Compare Players \& Teams  

\- 🕒 Optional 4-Quarter system



---



\## 🚀 Getting Started



~~~bash

\# 1) Install deps

flutter pub get



\# 2) (Recommended) Configure Firebase for your own project

\#    Generates lib/firebase\_options.dart

dart pub global activate flutterfire\_cli

flutterfire configure



\# 3) Run

flutter run

~~~



> \*\*Security note:\*\* Keep API keys \*\*restricted\*\* (by package/bundle ID \& SHA-1) and only enable APIs you actually use.



---



\## 📸 Screenshots (with filenames)



<table>

&nbsp; <tr>

&nbsp;   <td align="center"><img src="screenshots/home.png" width="210" alt="home"/><div><sub>home.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/create\_team.png" width="210" alt="create\_team"/><div><sub>create\_team.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/create\_player.png" width="210" alt="create\_player"/><div><sub>create\_player.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/manage\_team\_and\_lineups.png" width="210" alt="manage\_team\_and\_lineups"/><div><sub>manage\_team\_and\_lineups.png</sub></div></td>

&nbsp; </tr>

&nbsp; <tr>

&nbsp;   <td align="center"><img src="screenshots/create\_match.png" width="210" alt="create\_match"/><div><sub>create\_match.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/match\_preview.png" width="210" alt="match\_preview"/><div><sub>match\_preview.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/match\_details.png" width="210" alt="match\_details"/><div><sub>match\_details.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/match\_completed.png" width="210" alt="match\_completed"/><div><sub>match\_completed.png</sub></div></td>

&nbsp; </tr>

&nbsp; <tr>

&nbsp;   <td align="center"><img src="screenshots/matches\_result.png" width="210" alt="matches\_result"/><div><sub>matches\_result.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/recent\_matches.png" width="210" alt="recent\_matches"/><div><sub>recent\_matches.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/compare\_players\_and\_teams.png" width="210" alt="compare\_players\_and\_teams"/><div><sub>compare\_players\_and\_teams.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/teams\_comparison.png" width="210" alt="teams\_comparison"/><div><sub>teams\_comparison.png</sub></div></td>

&nbsp; </tr>

&nbsp; <tr>

&nbsp;   <td align="center"><img src="screenshots/players\_comparison.png" width="210" alt="players\_comparison"/><div><sub>players\_comparison.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/4\_quarter\_system.png" width="210" alt="4\_quarter\_system"/><div><sub>4\_quarter\_system.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/add\_profile\_photo.png" width="210" alt="add\_profile\_photo"/><div><sub>add\_profile\_photo.png</sub></div></td>

&nbsp;   <td align="center"><img src="screenshots/delete\_team.png" width="210" alt="delete\_team"/><div><sub>delete\_team.png</sub></div></td>

&nbsp; </tr>

</table>



---



\## 🎥 Demo Video



<video src="media/afl-demo.mp4" width="720" controls poster="screenshots/Home.png"></video>  



If your browser doesn’t show the player, view/download directly: \*\*\[media/afl-demo.mp4](media/afl-demo.mp4)\*\*



---



\## 🧱 Project Structure (high-level)

lib/

&nbsp; constants/

&nbsp; controller/        # screens \& controllers (home, live\_score, etc.)

&nbsp; models/            # data models, firebase manager

&nbsp; services/          # notification\_service.dart

&nbsp; main.dart



---



\## 🛠️ Build APK

~~~bash

flutter build apk --release

~~~

Output: `build/app/outputs/flutter-apk/app-release.apk`



---



\## 📄 License

This project is licensed under the \*\*MIT License\*\* – see \[LICENSE](LICENSE).



