import 'package:flutter/material.dart';

class EarningTab extends StatefulWidget {
  const EarningTab({super.key});

  @override
  State<EarningTab> createState() => _EarningTabState();
}

class _EarningTabState extends State<EarningTab> {
  final List<Map<String, dynamic>> demoEarnings = [
    {
      "rideId": "Ride #1234",
      "amount": 250.0,
      "date": "2024-12-01",
    },
    {
      "rideId": "Ride #5678",
      "amount": 300.0,
      "date": "2024-12-02",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earning"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo account notice
            const Text(
              "This is a demo acccount please upload your documents in the account tab to start earning",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Demo earnings header
            const Text(
              "Demo Earnings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Demo earnings list
            Expanded(
              child: ListView.builder(
                itemCount: demoEarnings.length,
                itemBuilder: (context, index) {
                  final earning = demoEarnings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                        size: 30,
                      ),
                      title: Text(
                        earning["rideId"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Date: ${earning["date"]}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Text(
                        "₹${earning["amount"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
