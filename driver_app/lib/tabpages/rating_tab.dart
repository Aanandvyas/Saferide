import 'package:flutter/material.dart';

class RatingTab extends StatefulWidget {
  const RatingTab({super.key});

  @override
  State<RatingTab> createState() => _RatingTabState();
}

class _RatingTabState extends State<RatingTab> {
  final List<Map<String, dynamic>> demoRatings = [
    {
      "name": "Anand vyas",
      "rating": 4.5,
      "feedback": "Great experience! Highly professional."
    },
    {
      "name": "Saksham Kriplani",
      "rating": 4.0,
      "feedback": "Good service, but could be improved."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rating "),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo account notice
            const Text(
              "This is a demo acccount please upload your documents in the account tab to start getting feedback ",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Demo ratings header
            const Text(
              " Ratings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Demo ratings list
            Expanded(
              child: ListView.builder(
                itemCount: demoRatings.length,
                itemBuilder: (context, index) {
                  final rating = demoRatings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          rating["name"]![0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        rating["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${rating["rating"]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rating["feedback"],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
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
