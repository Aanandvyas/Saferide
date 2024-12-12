import 'package:flutter/material.dart';
import 'package:user_app/pages/drawer_screen.dart';
import 'package:user_app/pages/home_page.dart'; // Assuming HomePage exists
import 'package:url_launcher/url_launcher.dart'; // For launching payment apps

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  int _rating = 0; // Store rating from 1 to 5
  bool _feedbackGiven = false; // Track if feedback has been given

  // Method to launch the respective payment app
  Future<void> _launchPaymentApp(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the app')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver :)"),
        backgroundColor: Colors.yellow.shade700, // Yellow AppBar
      ),
      drawer: const DrawerScreen(), // Custom Drawer Screen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar image from assets
            const SizedBox(height: 22),
            Center(
              child: Image.asset(
                'assets/images/avatarwoman.webp',
                width: 120, // Adjust the size of the avatar
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // Thank you message or star rating based on feedback status
            _feedbackGiven
                ? const Text(
                    'Thank you, Sir, for your feedback!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                  )
                : const Text(
                    'Thank You, Sir!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
            const SizedBox(height: 16),

            // Rating Section (only visible when feedback is not given)
            !_feedbackGiven
                ? Column(
                    children: [
                      const Text(
                        'Rate the Driver:',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.green,
                              size: 35, // Increased size for stars
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1; // Set the rating based on the star clicked
                                _feedbackGiven = true; // Mark feedback as given
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // Hide star rating after feedback

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Payment options (PayPal, PhonePe, Paytm)
            const Text(
              'Pay the Driver:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PayPal
                IconButton(
                  icon: Image.asset('assets/images/paypal.png', width: 50, height: 50),
                  onPressed: () {
                    _launchPaymentApp('paypal://'); // PayPal URL
                  },
                ),
                const SizedBox(width: 16),

                // PhonePe
                IconButton(
                  icon: Image.asset('assets/images/phonepe.png', width: 50, height: 50),
                  onPressed: () {
                    _launchPaymentApp('phonepe://'); // PhonePe URL
                  },
                ),
                const SizedBox(width: 16),

                // Paytm
                IconButton(
                  icon: Image.asset('assets/images/paytm.png', width: 50, height: 50),
                  onPressed: () {
                    _launchPaymentApp('paytm://'); // Paytm URL
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Button to book a new ride
            ElevatedButton(
              onPressed: () {
                // Navigate to HomePage for booking a new ride
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Book New Ride',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

