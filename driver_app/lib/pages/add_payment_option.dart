import 'package:flutter/material.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  String selectedPaymentMethod = '';

  // Controllers for the payment form details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payment Method"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose a Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Payment options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _paymentOption(
                  'PayPal',
                  'assets/images/paypal.png',
                  'paypal',
                ),
                _paymentOption(
                  'Paytm',
                  'assets/images/paytm.png',
                  'paytm',
                ),
                _paymentOption(
                  'PhonePe',
                  'assets/images/phonepe.png',
                  'phonepe',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment details form (appears only after selecting a method)
            if (selectedPaymentMethod.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Payment Details",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: accountController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement your submit action (save the payment method)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Payment method with $selectedPaymentMethod added successfully!",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Save Payment Method"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Function to display each payment option
  Widget _paymentOption(String name, String image, String method) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Column(
        children: [
          Image.asset(
            image,
            height: 50,
            width: 50,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
