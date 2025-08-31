import 'dart:io';
import 'package:afl/constants/constants.dart';
import 'package:afl/controller/home_vc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:afl/services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      name: "afl",
      options: const FirebaseOptions(
        projectId: 'afl-flutter-ee8f0',
        appId: '1:881809193443:ios:f54cfb44617f6d7b2b48d6',
        apiKey: 'AIzaSyBzXvoV7cinFeMLw0qgZRtID9JXVxzu1NI',
        messagingSenderId: '881809193443',
        storageBucket: '',
      ),
    );
    await NotificationService.initialize();
    runApp(const MyApp());
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFL',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      home: const HomeVC(),
    );
  }
}
