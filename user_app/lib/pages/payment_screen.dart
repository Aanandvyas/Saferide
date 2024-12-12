import 'package:flutter/material.dart';
import 'package:user_app/pages/add_payment_option.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // data for travel and payment records
  final List<Map<String, String>> travelRecords = [
    {"date": "2024-11-15", "route": "Sehore  → Nadra... ", "amount": "₹250"},
    {"date": "2024-11-10", "route": "Bhopal Station → DB Mall", "amount": "₹200"},
    {"date": "2024-11-05", "route": "Kothri Kalan → Lalghati", "amount": "₹120"},
    {"date": "2024-11-01", "route": "Raisen Road... → Indore", "amount": "₹180"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
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
              "Your Past Travel Records",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: travelRecords.length,
                itemBuilder: (context, index) {
                  final record = travelRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.local_taxi, color: Colors.blue),
                      title: Text(
                        record["route"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Date: ${record["date"]}"),
                      trailing: Text(
                        record["amount"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the AddPaymentMethodScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
                  );
                },
                icon: const Icon(Icons.payment
                ),
                label: const Text("Add Payment Method",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
