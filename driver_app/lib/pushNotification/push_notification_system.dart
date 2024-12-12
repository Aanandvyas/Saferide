import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver_app/models/user_ride_request_information.dart';
import 'package:driver_app/pushNotification/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initializeCloudMessaging(BuildContext context) async {
    // 1. When the app is terminated and opened via push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(remoteMessage.data["rideRequestedId"], context);
      }
    });

    // 2. When the app is in the foreground (active)
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(remoteMessage.data["rideRequestedId"], context);
      }
    });

    // 3. When the app is in the background and opened via push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(remoteMessage.data["rideRequestedId"], context);
      }
    });
  }

  // Read ride request details and show the notification dialog
  void readUserRideRequestInformation(String userRideRequestedId, BuildContext context) {
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestedId).child("driverId").onValue.listen((event) {
      if (event.snapshot.value == "waiting" || event.snapshot.value == FirebaseAuth.instance.currentUser!.uid) {
        FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestedId).once().then((DatabaseEvent snapData) {
          if (snapData.snapshot.value != null) {
            Map data = snapData.snapshot.value as Map;

            double originLat = double.parse(data["origin"]["latitude"]);
            double originLong = double.parse(data["origin"]["longitude"]);
            String originAddress = data["originAddress"];

            double destinationLat = double.parse(data["destination"]["latitude"]);
            double destinationLong = double.parse(data["destination"]["longitude"]);
            String destinationAddress = data["destinationAddress"];

            String userName = data["userName"];
            String userPhone = data["userPhone"];

            UserRideRequestInformation userRideRequestInformation = UserRideRequestInformation();

            userRideRequestInformation.originLatLng = LatLng(originLat, originLong);
            userRideRequestInformation.originAddress = originAddress;
            userRideRequestInformation.destinationLatLng = LatLng(destinationLat, destinationLong);
            userRideRequestInformation.destinationAddress = destinationAddress;
            userRideRequestInformation.userName = userName;
            userRideRequestInformation.userPhone = userPhone;
            userRideRequestInformation.rideRequestId = userRideRequestedId;

            // Show the notification dialog with ride details
            showDialog(
              context: context,
              builder: (BuildContext context) => NotificationDialogBox(
                userRideRequestDetails: userRideRequestInformation,
                onRideStatusUpdate: (String status) {
                  updateRideStatus(userRideRequestedId, status, context);
                },
              ),
            );
          } else {
            Fluttertoast.showToast(msg: "This Ride Request ID does not exist");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled");
        Navigator.pop(context);
      }
    });
  }

  // Update the ride status in Firebase Realtime Database
  void updateRideStatus(String rideRequestId, String status, BuildContext context) {
    String driverId = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the ride request in Firebase Realtime Database
    DatabaseReference rideRequestRef = FirebaseDatabase.instance.ref().child('All Ride Requests').child(rideRequestId);
    rideRequestRef.update({
      'rideStatus': status,
      'driverId': status == 'accepted' ? driverId : null,
    }).then((_) {
      Fluttertoast.showToast(msg: "Ride status updated to $status");
      Navigator.pop(context); // Close the notification dialog
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Failed to update ride status: $error");
    });
  }

  // Get and generate the FCM token for the driver
  Future<void> generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: $registrationToken");

    FirebaseDatabase.instance.ref().child("drivers").child(FirebaseAuth.instance.currentUser!.uid).child("token").set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
