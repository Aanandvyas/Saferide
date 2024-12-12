import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:user_app/pages/driverInfoScreen.dart';
import 'package:user_app/pages/splash_screen.dart';
import 'package:user_app/pages/home_page.dart';
import 'package:user_app/pages/payment_screen.dart';
import 'package:user_app/pages/profile_screen.dart';
import 'package:user_app/pages/setting_screen.dart';
import 'package:user_app/global/global_var.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_app/widgets/progress_dialog.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  Future<String> fetchUserName() async {
    String userId = firebaseAuth.currentUser?.uid ?? '';
    if (userId.isEmpty) return "Guest";

    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(userId)
        .child('name')
        .get();

    return snapshot.value?.toString() ?? "Guest";
  }

  // Method to launch phone call
  Future<void> _launchPhoneCall() async {
    const String phoneNumber = '100';
    final Uri phoneUrl = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunch(phoneUrl.toString())) {
        await launch(phoneUrl.toString());
      } else {
        print('Could not launch phone call');
      }
    } catch (e) {
      print('Error occurred while launching phone call: $e');
    }
  }

  // Method to get current location and share via WhatsApp
  Future<void> _shareLocation() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();
      String locationMessage =
          'I am here: https://www.google.com/maps?q=$latitude,$longitude';

      // Correct WhatsApp URL format (without extra characters)
      final whatsappUrl =
          Uri.parse('whatsapp://wa.me/918516894756?text=$locationMessage');
      final webWhatsAppUrl = Uri.parse(
          'https://api.whatsapp.com/send?phone=918516894756&text=$locationMessage');

      // Check if WhatsApp is installed (using canLaunchUrl)
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(webWhatsAppUrl)) {
        await launchUrl(webWhatsAppUrl); // Launch WhatsApp Web
      } else {
        print('Could not launch WhatsApp');
      }
    } catch (e) {
      print('Error occurred while sharing location: $e');
    }
  }

  // Method to launch the email for a rash driving complaint
  Future<void> _complainRashDriving() async {
    final Uri emailUrl = Uri(
      scheme: 'mailto', // Use 'mailto' scheme
      path: 'support@example.com',
      query: Uri.encodeFull(
          'subject=Complaint about Rash Driving&body=I would like to report a case of rash driving that I witnessed.'),
    );

    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
      } else {
        print('Could not open email client');
      }
    } catch (e) {
      print('Error occurred while launching email client: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Drawer(
      child: Container(
        color: Colors.white, // White background for the drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            FutureBuilder<String>(
              future: fetchUserName(),
              builder: (context, snapshot) {
                String userName = snapshot.data ?? "Loading...";

                return UserAccountsDrawerHeader(
                  accountName: Text(
                    userName,
                    style: const TextStyle(color: Colors.black),
                  ),
                  accountEmail: Text(
                    firebaseAuth.currentUser?.email ?? 'No email',
                    style: const TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/avatarman.png'),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700, // Yellow header background
                  ),
                );
              },
            ),

            // Drawer Items
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_forwarded, color: Colors.blue),
              title: const Text('NearByDriver',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                // Show the progress dialog
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Prevent dismissal by tapping outside
                  builder: (context) =>
                      const ProgressDialog(message: 'Please Wait...'),
                );

                // Wait for 7 seconds and then navigate to DriverInfoScreen
                Future.delayed(const Duration(seconds: 7), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DriverInfoScreen()),
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title:
                  const Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title:
                  const Text('Payments', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.blue),
              title:
                  const Text('Log Out', style: TextStyle(color: Colors.black)),
              onTap: () {
                firebaseAuth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                );
              },
            ),

            // Helpline Button
            ListTile(
              leading: const Icon(Icons.phone,
                  color: Color.fromARGB(255, 218, 82, 82)),
              title: const Text('Emergency Helpline',
                  style: TextStyle(color: Color.fromARGB(255, 180, 21, 21))),
              tileColor: const Color.fromARGB(255, 213, 58, 47),
              onTap: _launchPhoneCall,
            ),

            // Share Location Button
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('Share Location',
                  style: TextStyle(color: Colors.green)),
              tileColor: Colors.green.shade50,
              onTap: _shareLocation,
            ),

            // Complain Rash Driving Button
            ListTile(
              leading: const Icon(Icons.warning,
                  color: Colors.red), // Red warning icon
              title: const Text('Complain Rash Driving',
                  style: TextStyle(color: Colors.red)),
              tileColor: Colors
                  .red.shade50, // Light red background for complaint button
              onTap: _complainRashDriving, // Trigger rash driving complaint
            ),
          ],
        ),
      ),
    );
  }
}
