import 'package:firebase_database/firebase_database.dart';

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
    DatabaseReference rideRequestRef = FirebaseDatabase.instance.ref().child('All Ride Requests').push();
    
    // Write ride request details
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
      'rideStatus': 'waiting', // Initially set as 'waiting'
      'driverId': null, // No driver assigned initially
    });

    // Set expiration time (e.g., 30 minutes)
    DateTime expirationTime = DateTime.now().add(const Duration(minutes: 30));
    await rideRequestRef.child('expirationTime').set(expirationTime.toIso8601String());

    // Send push notification (using FCM)
    // You would call FCM here to notify drivers
  }
}
