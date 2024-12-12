import 'package:driver_app/models/user_ride_request_information.dart';
import 'package:driver_app/pages/destinationReach.dart';
import 'package:flutter/material.dart';

class NotificationDialogBox extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;
  final Function(String) onRideStatusUpdate; // Callback function for status update

  const NotificationDialogBox({super.key, this.userRideRequestDetails, required this.onRideStatusUpdate});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/car.png"),
            const SizedBox(height: 10),
            const Text(
              "New Ride Request",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 14),
            const Divider(height: 2, thickness: 2, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("assets/images/initial.png", width: 30, height: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails?.originAddress ?? "Unknown",
                          style: const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset("assets/images/final.png", width: 30, height: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails?.destinationAddress ?? "Unknown",
                          style: const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 2, thickness: 2, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Cancel".toUpperCase(), style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      widget.onRideStatusUpdate("accepted"); // Accept the ride
                      // Navigate to the DestinationReach page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Destinationreach(
                            rideRequestInfo: widget.userRideRequestDetails!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Accept".toUpperCase(), style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      widget.onRideStatusUpdate("rejected"); // Reject the ride
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text("Reject".toUpperCase(), style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
