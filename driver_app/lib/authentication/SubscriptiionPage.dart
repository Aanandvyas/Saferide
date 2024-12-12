import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:driver_app/pages/home_page.dart';

// Assuming DriverModel holds the driver's data
class DriverModel {
  final String mobileNumber;
  DriverModel({required this.mobileNumber});
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with TickerProviderStateMixin {
  String selectedPlan = "";
  Razorpay razorpay = Razorpay();
  DriverModel driver = DriverModel(mobileNumber: '8516894756'); // Example driver data
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    // Animation Controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    super.dispose();
    try {
      razorpay.clear();
      _scaleController.dispose();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, 
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Unlock All Features!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Enjoy a premium experience with unlimited access.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 42),

              // Pricing Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Perday Plan
                  ResponsivePricingCard(
                    plan: 'Perday',
                    price: '₹25/day',
                    isBestValue: false,
                    isSelected: selectedPlan == 'Perday',
                    onPressed: () {
                      setState(() {
                        selectedPlan = 'Perday';
                      });
                    },
                  ),
                  // Weekly Plan
                  ResponsivePricingCard(
                    plan: 'Weekly',
                    price: '₹150/week',
                    isBestValue: true,
                    isSelected: selectedPlan == 'Weekly',
                    onPressed: () {
                      setState(() {
                        selectedPlan = 'Weekly';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 95),

              // CTA Button with Animation
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Scale the button when pressed
                    _scaleController.forward().then((_) {
                      _scaleController.reverse();
                    });

                    int amount = 0;
                    if (selectedPlan == 'Perday') {
                      amount = 2500; // ₹25/day = ₹25 * 100 (Razorpay accepts paise)
                    } else if (selectedPlan == 'Weekly') {
                      amount = 15000; // ₹150/week = ₹150 * 100 (Razorpay accepts paise)
                    }

                    var options = {
                      'key': 'rzp_test_c12JmJoNzfrVOP',
                      'secret_key': 'Eu54gx2Z3MyDAYwEvkKa',
                      'amount': amount, // Set amount based on plan
                      'name': 'Anand Vyas',
                      'description': 'Cab Subscription',
                      'prefill': {
                        'contact': driver.mobileNumber, // Get the mobile number from DriverModel
                        'email': 'test@razorpay.com'
                      }
                    };
                    razorpay.open(options);
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 60,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          selectedPlan == 'Perday' 
                              ? "Pay ₹25" 
                              : selectedPlan == 'Weekly' 
                                  ? "Pay ₹150" 
                                  : "Select a Plan",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),

              // Terms and Conditions
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to Terms of Service
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsOfServicePage()),
                    );
                  },
                  child: Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(color: Colors.blue[700], fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Show success toast
    Fluttertoast.showToast(msg: "Payment Success");

    // Navigate to the Home Page after successful payment
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Show error toast
    Fluttertoast.showToast(msg: "Payment Failed");
  }
}

// Responsive Pricing Card
class ResponsivePricingCard extends StatelessWidget {
  final String plan;
  final String price;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onPressed;

  const ResponsivePricingCard({
    super.key,
    required this.plan,
    required this.price,
    required this.isBestValue,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, 
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              plan,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (isBestValue) ...[
              const SizedBox(height: 12),
              const Icon(Icons.star, color: Colors.blue, size: 20),
              const Text(
                'Best Value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const Center(
        child: Text('Terms of Service and Privacy Policy'),
      ),
    );
  }
}
