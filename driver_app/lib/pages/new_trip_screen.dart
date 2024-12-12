import 'dart:async';
import 'package:driver_app/models/user_ride_request_information.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Ensure this import is added

class NewTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestInformation;

  const NewTripScreen({super.key, this.userRideRequestInformation});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  StreamSubscription<Position>? positionStream;
  LatLng? currentDriverLatLng;
  bool isUpdatingStatus = false; // For disabling buttons during status update

  @override
  void initState() {
    super.initState();
    checkUserAuth();
    checkLocationPermission(); // Check for location permission
    startLocationTracking();
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }

  /// Starts tracking the driver's location in real-time
  void startLocationTracking() {
    Geolocator.requestPermission().then((permission) {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permission denied.");
        return;
      }

      positionStream =
          Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          currentDriverLatLng = LatLng(position.latitude, position.longitude);
        });

        print("Driver's current location: $currentDriverLatLng");
        updateDriverLocationInDatabase(currentDriverLatLng);
      });
    });
  }

  /// Stops tracking the driver's location
  void stopLocationTracking() {
    positionStream?.cancel();
  }

  /// Check if the user is authenticated
  void checkUserAuth() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated!')),
      );
    } else {
      print('User authenticated with UID: ${user.uid}');
    }
  }

  /// Check for location permission
  void checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  /// Updates the driver's location in Firestore
  void updateDriverLocationInDatabase(LatLng? driverLatLng) async {
    if (driverLatLng == null) return;

    String driverId = getCurrentUserId(); // Get the driver's current user ID

    // Example Firestore update logic to save the driver's location
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({
        "location": {
          "latitude": driverLatLng.latitude,
          "longitude": driverLatLng.longitude
        }
      });
      print("Driver location updated in database");
    } catch (error) {
      print("Error updating driver location: $error");
    }
  }

  /// Get the current authenticated user ID (from Firebase Authentication)
  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? ''; // Return the user ID or an empty string if not logged in
  }

  /// Update the ride request status in Firestore
  Future<void> updateRideStatus(String status) async {
    if (widget.userRideRequestInformation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ride request information is missing.")),
      );
      return;
    }

    String? rideRequestId = widget.userRideRequestInformation!.rideRequestId;
    String driverId = getCurrentUserId();

    setState(() {
      isUpdatingStatus = true; // Disable the button during status update
    });

    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(rideRequestId)
          .update({
        'status': status,
        'driverId': driverId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ride status updated to $status")),
      );
      Navigator.pop(context, status); // Go back with the status
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied. Please try again.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        isUpdatingStatus = false; // Re-enable buttons after the update
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Trip"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 120),
            const Text(
              "Ride Request Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
                "Ride ID", widget.userRideRequestInformation?.rideRequestId),
            _buildInfoRow(
                "Origin", widget.userRideRequestInformation?.originAddress),
            _buildInfoRow("Destination",
                widget.userRideRequestInformation?.destinationAddress),
            _buildInfoRow("User", widget.userRideRequestInformation?.userName),
            _buildInfoRow(
                "Phone", widget.userRideRequestInformation?.userPhone),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isUpdatingStatus
                      ? null
                      : () {
                          // Handle Reject Action
                          updateRideStatus('rejected');
                          stopLocationTracking();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isUpdatingStatus
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Reject",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
                ElevatedButton(
                  onPressed: isUpdatingStatus
                      ? null
                      : () {
                          // Handle Accept Action
                          updateRideStatus('accepted');
                          stopLocationTracking();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isUpdatingStatus
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Accept",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (currentDriverLatLng != null)
              Text(
                "Driver's Current Location: \nLat: ${currentDriverLatLng!.latitude}, "
                "Lng: ${currentDriverLatLng!.longitude}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "N/A",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
