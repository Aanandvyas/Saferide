import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_app/pages/drawer_screen.dart';
import 'package:user_app/pages/home_page.dart';
import 'package:user_app/pages/lastScreen.dart'; // Assuming HomePage exists
import 'dart:async'; // For Future.delayed
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class DriverInfoScreen extends StatefulWidget {
  const DriverInfoScreen({super.key});

  @override
  State<DriverInfoScreen> createState() => _DriverInfoScreenState();
}

class _DriverInfoScreenState extends State<DriverInfoScreen> {
  // Loading screen visibility state
  bool _isLoading = false;

  // Show loading screen
  void _showLoadingScreen() {
    setState(() {
      _isLoading = true;
    });

    // Hide the loading screen after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to the next screen after the delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThankYouScreen()),
      );
    });
  }

  // Call driver function
  void _callDriver() async {
    const phoneNumber = '8516894856'; // Driver's phone number
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    // Check if the URL can be launched
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the phone dialer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Details"),
        backgroundColor: Colors.yellow.shade700, // Yellow app bar
      ),
      drawer: const DrawerScreen(), // Custom Drawer Screen
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image at the top (Center image)
                Center(
                  child: Image.asset(
                    'assets/images/avatarman.png',
                    width: 120, // Adjust size of the image
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),

                // Ride Details Section
                const Text(
                  'Ride Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('From:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('Kothri Kalan...', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('To:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('lalghati', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Total Distance and Fare Section
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Distance:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('63 km', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fare:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('₹15/km', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('waiting Time:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('5 min', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Driver Info Section
                const Text(
                  'Driver Info',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Name:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('Saksham Kriplani', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vehicle:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('Toyota ', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('License Plate:', style: TextStyle(fontSize: 18, color: Colors.black)),
                    Text('MP0476', style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 32),

                // Cancel Ride Button
                Center(
                  child: ElevatedButton(
                    onPressed: _showLoadingScreen, // Show loading screen
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 99, 89), // Red button for cancel
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel Ride',
                      style: TextStyle(fontSize: 18,color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: _callDriver, // Call driver button
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green button for call
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Call Driver',
                      style: TextStyle(fontSize: 18,color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading screen overlay
          if (_isLoading)
            Center(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
