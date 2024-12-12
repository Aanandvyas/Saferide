import 'package:driver_app/infoHandler/app_info.dart';
import 'package:driver_app/pages/Splash_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.subscribeToTopic('drivers');

  // Correct way to enable Firestore settings and logging
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);  // Correct Settings class
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        title: 'Cab_Services',
        home: SplashScreen(),
      ),
    );
  }
}
