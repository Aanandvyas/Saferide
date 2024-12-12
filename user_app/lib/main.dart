import 'package:firebase_core/firebase_core.dart';  // Import Firebase package
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/pages/Splash_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure Flutter binding is initialized

  // Initialize Firebase before running the app
  await Firebase.initializeApp();  // This ensures Firebase is ready
  FirebaseMessaging.instance.subscribeToTopic('user');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppInfo()),  
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),  
      ),
    );
  }

}
