import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

// Firebase Cloud Messaging (FCM) - Get the server token
const String fcmServerToken = 'YOUR_FCM_SERVER_KEY_HERE';

class RideRequest {
  static Future<void> sendRideRequest({
    required String userId,
    required String originAddress,
    required double originLat,
    required double originLng,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
  }) async {
    // Reference to the ride request in Firebase Database
    DatabaseReference rideRequestRef = FirebaseDatabase.instance.ref().child('All Ride Requests').push();
    
    // Write ride request details to the database
    await rideRequestRef.set({
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'origin': {
        'latitude': originLat,
        'longitude': originLng,
      },
      'destination': {
        'latitude': destinationLat,
        'longitude': destinationLng,
      },
      'userId': userId,
      'rideStatus': 'waiting', // Initially set to 'waiting'
      'driverId': null, // No driver assigned initially
    });

    // Send push notification to notify drivers (using FCM)
    sendDriverNotification(originLat, originLng, destinationLat, destinationLng);
  }

  // Function to send notification to drivers (FCM)
  static Future<void> sendDriverNotification(
    double originLat, 
    double originLng, 
    double destinationLat, 
    double destinationLng
  ) async {
    // Construct the notification payload
    final Map<String, dynamic> payload = {
      "notification": {
        "title": "New Ride Request",
        "body": "A user needs a ride. Check the details and accept.",
      },
      "data": {
        "originLat": originLat.toString(),
        "originLng": originLng.toString(),
        "destinationLat": destinationLat.toString(),
        "destinationLng": destinationLng.toString(),
      },
      "priority": "high",
      "to": "/topics/drivers", // Send to all drivers (ensure you subscribe drivers to 'drivers' topic)
    };

    // FCM API endpoint
    const String url = "https://fcm.googleapis.com/fcm/send";
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$fcmServerToken', // Your FCM Server key
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      print("Notification sent to drivers");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  }
}

class UserRideStatusListener {
  static void listenForRideStatusChanges(String rideRequestedId) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(rideRequestedId)
        .child("rideStatus")
        .onValue
        .listen((event) {
      final status = event.snapshot.value;
      
      if (status == 'accepted') {
        // Notify the user that the ride has been accepted
        print('Ride accepted by driver');
        // Optionally, you can navigate to another screen if needed
      } else if (status == 'rejected') {
        print('Ride request rejected by driver');
      } else if (status == 'driver_enroute') {
        print('Driver is on the way');
      } else if (status == 'completed') {
        print('Ride completed');
      }
    });
  }
}
