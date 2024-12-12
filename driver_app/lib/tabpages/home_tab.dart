import 'dart:async';
import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/pages/destinationReach.dart';
import 'package:driver_app/pushNotification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver_app/models/user_ride_request_information.dart';
// New import

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with WidgetsBindingObserver {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  bool locationInitialized = false;
  static const CameraPosition _KgooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14.4);

  var geoLocator = Geolocator();

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  // Track position stream
  StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

  // Ride Request Information
  UserRideRequestInformation? rideRequestDetails;

  // Permissions and location check
  _checkLocationPermissionAndLocateUser() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      CommonMethods().displaySnackBar(
        "Location permission is required",
        context,
      );
      return;
    }
    locateDriverPosition();
  }

  void checkFirebaseConnection() {
    FirebaseDatabase.instance
        .ref()
        .child(".info/connected")
        .onValue
        .listen((event) {
      final bool connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        print("Driver App connected to Firebase.");
      } else {
        print("Driver App is not connected to Firebase.");
      }
    });
  }

  locateDriverPosition() async {
    try {
      CommonMethods().showLoadingDialog("Locating you...", context);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      driverModelCurrentInfo = position;
      LatLng latLng = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);
      newGoogleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );

      String address = await CommonMethods()
          .searchAddressForGeographicCoordinates(position, context);
    } catch (e) {
      print("Error locating user: $e");
    } finally {
      Navigator.pop(context);
    }
  }

  void readUserRideRequestInformation(
      String userRideRequestedId, BuildContext context) {
    print("Fetching ride request: $userRideRequestedId");

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestedId)
        .once()
        .then((DatabaseEvent snapData) {
      if (snapData.snapshot.exists) {
        Map data = snapData.snapshot.value as Map;
        print("Ride Request Data: $data");

        double originLat = data["origin"]["latitude"];
        double originLong = data["origin"]["longitude"];
        String originAddress = data["originAddress"];

        double destinationLat = data["destination"]["latitude"];
        double destinationLong = data["destination"]["longitude"];
        String destinationAddress = data["destinationAddress"];

        String userName = data["userName"];
        String userPhone = data["userPhone"];

        print("Parsed Data:");
        print("Origin: $originLat, $originLong ($originAddress)");
        print(
            "Destination: $destinationLat, $destinationLong ($destinationAddress)");
        print("User: $userName, $userPhone");

        UserRideRequestInformation userRideRequestInformation =
            UserRideRequestInformation(
          rideRequestId: userRideRequestedId,
          originLatLng: LatLng(originLat, originLong),
          destinationLatLng: LatLng(destinationLat, destinationLong),
          originAddress: originAddress,
          destinationAddress: destinationAddress,
          userName: userName,
          userPhone: userPhone,
          rideRequestStatus: data["status"],
        );

        // Show the ride request notification dialog
        showRideRequestNotificationDialog(context, userRideRequestInformation);
      } else {
        print("Ride request not found: $userRideRequestedId");
        Fluttertoast.showToast(msg: "Ride Request not found.");
      }
    }).onError((error, stackTrace) {
      print("Error fetching ride request: $error");
      print("Stack Trace: $stackTrace");
    });
  }

  void showRideRequestNotificationDialog(
      BuildContext context, UserRideRequestInformation rideRequestInformation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ride Request'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${rideRequestInformation.userName}'),
            Text('Phone: ${rideRequestInformation.userPhone}'),
            Text('Origin: ${rideRequestInformation.originAddress}'),
            Text('Destination: ${rideRequestInformation.destinationAddress}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle decline action
              updateRideStatus(
                  'Declined', rideRequestInformation.rideRequestId!, context);
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              // Handle accept action
              updateRideStatus(
                  'Accepted', rideRequestInformation.rideRequestId!, context);
              Navigator.pop(context); // Close the dialog

              // Navigate to the Destinationreach page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Destinationreach(
                    rideRequestInfo: rideRequestInformation,
                  ),
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  readCurrentDriverInformation() async {
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.address = (snap.snapshot.value as Map)["address"];
        onlineDriverData.car_color =
            (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model =
            (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number =
            (snap.snapshot.value as Map)["car_details"]["car_number"];
        onlineDriverData.car_number =
            (snap.snapshot.value as Map)["car_details"]["type"];

        driverVehicleType =
            (snap.snapshot.value as Map)["car_details"]["types"];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermissionAndLocateUser();
    readCurrentDriverInformation();
    super.initState();
    checkFirebaseConnection();
    listenToRideRequests();

    // Initialize push notifications
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();

    // Listen to incoming notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey("rideRequestedId")) {
        String rideRequestedId = message.data["rideRequestedId"];
        print("Ride Requested ID: $rideRequestedId");
        readUserRideRequestInformation(
            rideRequestedId, context); // Added context
      } else {
        print("No rideRequestedId in the notification.");
      }
    });

    // Listen for new ride requests in real time
    listenToRideRequests();
  }

  @override
  void dispose() {
    streamSubscriptionDriverLivePosition?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _KgooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            locateDriverPosition();
          },
        ),
        // UI for online/offline driver
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),

        // Button for online/offline driver
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.45
              : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    try {
                      if (!isDriverActive) {
                        await driverIsOnlineNow();
                        updateDriversLocationAtRealTime();
                      } else {
                        driverIsOfflineNow();
                      }
                    } catch (e) {
                      print("Error toggling online/offline status: $e");
                      Fluttertoast.showToast(
                          msg: "An error occurred. Try again.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: statusText != "Now Online"
                      ? Text(
                          statusText,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      : const Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 26,
                        ))
            ],
          ),
        ),
      ],
    );
  }

  driverIsOnlineNow() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      driverModelCurrentInfo = pos;

      // Initialize Geofire with error handling
      await Geofire.initialize("activeDrivers");
      await Geofire.setLocation(currentUser!.uid, pos.latitude, pos.longitude);

      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser!.uid)
          .child("newRideStatus");

      await ref.set("idle");

      print("Driver is now online at: ${pos.latitude}, ${pos.longitude}");

      setState(() {
        statusText = "Now Online";
        buttonColor = Colors.transparent;
        isDriverActive = true;
      });
    } catch (e) {
      print("Error setting driver online: $e");
      Fluttertoast.showToast(
          msg: "Failed to go online. Check your connection.");

      setState(() {
        statusText = "Now Offline";
        buttonColor = Colors.grey;
        isDriverActive = false;
      });
    }
  }

  void updateDriversLocationAtRealTime() {
    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive) {
        Geofire.setLocation(
            currentUser!.uid, position.latitude, position.longitude);

        LatLng latLng = LatLng(position.latitude, position.longitude);
        newGoogleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 15)),
        );
      }
    });
  }

  void listenToRideRequests() {
    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child("All Ride Requests");

    rideRequestRef.onChildAdded.listen((DatabaseEvent event) {
      print("Database listener triggered.");

      if (event.snapshot.exists) {
        String rideRequestedId = event.snapshot.key!;
        print("Ride Requested ID: $rideRequestedId");
        print("Ride Request Data: ${event.snapshot.value}");
        readUserRideRequestInformation(rideRequestedId, context);
      } else {
        print("No data found in the triggered event.");
      }
    }).onError((error) {
      print("Error listening to database: $error");
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    setState(() {
      statusText = "Now Offline";
      buttonColor = Colors.grey;
      isDriverActive = false;
    });

    streamSubscriptionDriverLivePosition?.cancel();
  }
}

void updateRideStatus(
    String status, String rideRequestId, BuildContext context) {
  FirebaseDatabase.instance
      .ref()
      .child("All Ride Requests")
      .child(rideRequestId)
      .update({
    'rideStatus': status,
  }).then((_) {
    Fluttertoast.showToast(msg: "Ride status updated to $status.");
    Navigator.pop(context); // Close the dialog
  }).catchError((error) {
    Fluttertoast.showToast(msg: "Failed to update ride status: $error");
  });

  // Reads ride request information from the database and displays it in the dialog
}
