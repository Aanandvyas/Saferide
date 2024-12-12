import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cab Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    fetchUserInfoAtLaunch(); // Fetch user details at app launch
    _startSplashScreenTimer();
  }

  // Function to simulate splash screen delay
  _startSplashScreenTimer() async {
    // Wait for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    // Navigate to the next screen (LoginScreen in this case)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Fetch user details from Firebase at app launch
  Future<void> fetchUserInfoAtLaunch() async {
    final userId = firebaseAuth.currentUser?.uid;

    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    try {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("users").child(userId);

      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
        print("User info loaded at launch: ${userModelCurrentInfo?.name}");
      } else {
        print("User data not found in Firebase.");
      }
    } catch (e) {
      print("Error fetching user info at launch: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 202, 39),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(
              Icons.local_taxi,
              size: 100.0,
              color: Colors.black,
            ),
            SizedBox(height: 20),
            // App name
            Text(
              'SafeRide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Developer's credit
            Text(
              'Developed by Anand Vyas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
