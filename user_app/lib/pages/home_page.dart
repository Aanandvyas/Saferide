import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/global/global_var.dart';
import 'package:user_app/methods/common_method.dart';
import 'package:user_app/methods/geofire_assistant.dart';
import 'package:user_app/models/active_nearby_available_drivers.dart';
import 'package:user_app/models/directions.dart';
import 'package:user_app/models/user_model.dart';
import 'package:user_app/pages/driverInfoScreen.dart';
import 'package:user_app/pages/search_places.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:user_app/pages/drawer_screen.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  GoogleMapController? newGoogleMapController;
  DatabaseReference rideRequestRef =
      FirebaseDatabase.instance.ref().child('All Ride Requests');
  bool activeNearByAvailableDriversKeyLoaded = false;
  BitmapDescriptor? activeNearbyIcon, destinationIcon, userLocationIcon;
  Position? userCurrentPosition;
  Set<Marker> markers = {};
  String? currentLocationName;
  String? destinationAddress;
  UserModel? userModelCurrentInfo;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  Set<Polyline> polylines = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962), // Default location
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _loadCarMarkerIcon();
    _checkLocationPermissionAndLocateUser();
  }

  // Load car, destination, and user location icons
  Future<void> _loadCarMarkerIcon() async {
    activeNearbyIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/car.png',
    );

    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/initial.png',
    );

    userLocationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/initial.png',
    );
  }

  Future<void> fetchUserInfo() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Fetch data from the 'users' node using the current user's UID
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/${firebaseUser.uid}');

      // Attempt to get the user data from the database
      try {
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          // Map the snapshot data to your custom UserModel
          userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
          print('User info fetched: ${userModelCurrentInfo!.name}');
        } else {
          print('No user data found in database.');
        }
      } catch (e) {
        print("Error fetching user info: $e");
      }
    } else {
      print('No user is logged in.');
    }
  }

  // Request location permission and locate user
  Future<void> _checkLocationPermissionAndLocateUser() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      CommonMethods()
          .displaySnackBar("Location permission is required", context);
      return;
    }
    locateUserPosition();
  }

  // Locate the user's position and update map
  Future<void> locateUserPosition() async {
    try {
      CommonMethods().showLoadingDialog("Locating you...", context);

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userCurrentPosition = position;
      LatLng latLng = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);
      newGoogleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String address = await CommonMethods()
          .searchAddressForGeographicCoordinates(position, context);

      setState(() {
        currentLocationName = address;
        markers.add(Marker(
          markerId: const MarkerId('userLocation'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: userLocationIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
    } catch (e) {
      CommonMethods().displaySnackBar("Error locating user: $e", context);
    } finally {
      Navigator.pop(context);
    }

    initializeGeoFireListener();
  }

  // Initialize GeoFire listener for nearby drivers
  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveNearByAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearByAvailableDrivers();
            activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
            activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
            activeNearbyAvailableDrivers.driverId = map["key"];
            GeofireAssistant.activeNearByAvailableDriversList
                .add(activeNearbyAvailableDrivers);

            if (activeNearByAvailableDriversKeyLoaded) {
              displayActiveDriversOnUsersMap();
            }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.deleteOfflineDriversFromList(map["key"]);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onKeyMoved:
            ActiveNearByAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearByAvailableDrivers();
            activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
            activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
            activeNearbyAvailableDrivers.driverId = map["key"];
            GeofireAssistant.updateActiveNearByAvailableDriversList(
                activeNearbyAvailableDrivers);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onGeoQueryReady:
            activeNearByAvailableDriversKeyLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }
      setState(() {});
    });
  }

  // Display nearby drivers on the map
  displayActiveDriversOnUsersMap() {
    setState(() {
      Set<Marker> driversMarkerSet = {};

      for (ActiveNearByAvailableDrivers eachDriver
          in GeofireAssistant.activeNearByAvailableDriversList) {
        if (eachDriver.driverId != null) {
          LatLng eachDriverActivePosition = LatLng(
              eachDriver.locationLatitude!, eachDriver.locationLongitude!);
          Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: activeNearbyIcon ?? BitmapDescriptor.defaultMarker,
            rotation: 360,
            infoWindow: const InfoWindow(title: "Driver"),
          );
          driversMarkerSet.add(marker);
        }
      }

      markers = driversMarkerSet;
    });
  }

  // Navigate to the destination search screen
  Future<void> navigateToSearchScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPlacesScreen()),
    );

    if (result != null) {
      setState(() {
        destinationAddress = result.locationName;
      });
      await drawPolyline();
    }
  }

  // Draw polyline between current location and destination
  Future<void> drawPolyline() async {
    if (userCurrentPosition == null || destinationAddress == null) return;

    final destinationCoordinates =
        await CommonMethods().getCoordinatesFromAddress(destinationAddress!);

    if (destinationCoordinates != null) {
      final directions = await fetchDirections(
        origin: LatLng(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude),
        destination: destinationCoordinates,
      );

      if (directions != null) {
        setState(() {
          polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 6,
            points: directions.directionDetails!.ePoints,
          ));

          markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: destinationCoordinates,
            icon: destinationIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
            infoWindow:
                InfoWindow(title: "Destination", snippet: destinationAddress),
          ));
        });
      }
    }
  }

  // Fetch directions from the Google Maps API
  Future<Directions?> fetchDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleMapsKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Directions.fromJson(data);
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // Show loading dialog for driver notification
  showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Send notification to driver (simulation for now)
  sendNotificationToDriver(String driverId) async {
    print("Sending notification to driver with ID: $driverId");
    // Simulate driver acceptance after a delay
    await Future.delayed(const Duration(seconds: 5));
    navigateToDriverInfoScreen();
  }

  // Navigate to Driver Info screen
  navigateToDriverInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriverInfoScreen()),
    );
  }

  // Listen for driver response (accept/reject)
  void listenForDriverResponse() async {
    try {
      // Example: Use your backend logic here (Firebase, REST API, etc.) to fetch real-time response
      bool driverAccepted = await checkDriverResponseFromBackend();

      Navigator.pop(context); // Close loading dialog

      if (driverAccepted) {
        // Navigate to DriverInfoScreen if the driver accepts
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverInfoScreen()),
        );
      } else {
        // Handle driver rejection
        CommonMethods()
            .displaySnackBar("Driver rejected your request.", context);
      }
    } catch (e) {
      // Handle errors from backend/response listening
      Navigator.pop(context); // Close loading dialog
      CommonMethods()
          .displaySnackBar("Error listening for driver response: $e", context);
    }
  }

  // Function to create a ride request and send a notification to online drivers
  void createRideRequest(
      String originAddress,
      LatLng originLatLng,
      String destinationAddress,
      LatLng destinationLatLng,
      String userName,
      String userPhone) {
    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    String rideRequestedId =
        rideRequestRef.key!; // Generate unique ride request ID

    // Create the ride request data structure
    Map<String, dynamic> rideRequestData = {
      "origin": {
        "latitude": originLatLng.latitude,
        "longitude": originLatLng.longitude,
      },
      "destination": {
        "latitude": destinationLatLng.latitude,
        "longitude": destinationLatLng.longitude,
      },
      "originAddress": originAddress,
      "destinationAddress": destinationAddress,
      "userName": userName,
      "userPhone": userPhone,
      "rideRequestedId": rideRequestedId,
      "status": "waiting", // Ride status: "waiting" means it's a new request
    };

    // Save the ride request data to Firebase
    rideRequestRef.set(rideRequestData).then((_) {
      print("Ride request successfully created: $rideRequestedId");

      // Trigger Firebase Cloud Function to send push notification to drivers
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(rideRequestedId)
          .update({
        "notificationSent":
            true, // Optional: to keep track of sent notifications
      });
    }).catchError((error) {
      print("Error creating ride request: $error");
      CommonMethods().displaySnackBar(
          "Failed to create ride request. Please try again.", context);
    });
  }

// Function to send push notification to all online drivers

// Simulated method to check driver's response (to be replaced with real backend logic)
  Future<bool> checkDriverResponseFromBackend() async {
    // Example: Simulate waiting for a response (replace this with actual Firebase or API call)
    await Future.delayed(const Duration(seconds: 7)); // Simulate network delay
    return false; // Simulate driver accepting the request
  }

  Future<void> sendRequestToNearbyDrivers() async {
    if (userCurrentPosition == null) {
      CommonMethods()
          .displaySnackBar("Unable to locate your position", context);
      return;
    }

    CommonMethods().showLoadingDialog("Requesting nearby drivers...", context);

    // This function should call a backend service to send a request to nearby drivers
    // Example: `sendDriverRequest(userCurrentPosition, destinationAddress)`
    bool requestSent =
        await sendDriverRequest(userCurrentPosition!, destinationAddress);

    if (requestSent) {
      // If request is sent, listen for driver's response
      listenForDriverResponse();
    } else {
      Navigator.pop(context); // Close the loading dialog if request fails
      CommonMethods().displaySnackBar("No nearby drivers available", context);
    }
  }

// Example function for sending the driver request (this would interact with Firebase or similar backend):
  Future<bool> sendDriverRequest(
      Position userPosition, String? destination) async {
    // Replace with your actual request sending logic
    // Return true if the request is successfully sent, else false
    return true; // Simulate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      drawer:
          const DrawerScreen(), // DrawerScreen widget for the navigation drawer
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMaps.complete(controller);
              newGoogleMapController = controller;
            },
            markers: markers,
            polylines: polylines,
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () {
                _scaffoldState.currentState!.openDrawer();
              },
            ),
          ),
          Positioned(
            bottom: 50,
            left: 15,
            right: 15,
            child: GestureDetector(
              // Inside your GestureDetector for requesting a ride
              onTap: () async {
                // Ensure user info is fetched before proceeding
                if (userModelCurrentInfo == null) {
                  await fetchUserInfo(); // Fetch the user info asynchronously
                  if (userModelCurrentInfo == null) {
                    CommonMethods().displaySnackBar(
                        "User information is missing", context);
                    print("User info is still missing after fetching.");
                    return;
                  }
                }

                // Check if location coordinates are available
                if (userCurrentPosition == null) {
                  CommonMethods()
                      .displaySnackBar("Current location is missing", context);
                  print("User's current position is null.");
                  return;
                }

                // Check if destination address is provided
                if (destinationAddress == null || destinationAddress!.isEmpty) {
                  CommonMethods().displaySnackBar(
                      "Destination address is missing", context);
                  print("Destination address is null or empty.");
                  return;
                }

                // Get user's name and phone from the user model
                String userName = userModelCurrentInfo!.name!;
                String userPhone = userModelCurrentInfo!.phone!;

                // Get the user's current position as LatLng
                LatLng originLatLng = LatLng(userCurrentPosition!.latitude,
                    userCurrentPosition!.longitude);

                // Get destination coordinates from the address
                LatLng? destinationLatLng;
                try {
                  destinationLatLng = await CommonMethods()
                      .getCoordinatesFromAddress(destinationAddress!);
                } catch (e) {
                  CommonMethods().displaySnackBar(
                      "Error getting destination coordinates", context);
                  print("Error fetching destination coordinates: $e");
                  return;
                }

                // Proceed if destination coordinates are valid
                if (destinationLatLng != null) {
                  // Create the ride request
                  createRideRequest(
                    currentLocationName ??
                        "Unknown Location", // Address of current location
                    originLatLng, // User's current location
                    destinationAddress ??
                        "Unknown Destination", // Destination address
                    destinationLatLng, // Destination coordinates
                    userName, // User's name
                    userPhone, // User's phone number
                  );
                } else {
                  // Handle case where destination coordinates are null or invalid
                  CommonMethods().displaySnackBar(
                      "Unable to get destination coordinates", context);
                  print("Destination coordinates could not be fetched.");
                }
              },

              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Nearby Driver",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Current Location Container
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          currentLocationName ?? "Finding your location...",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Destination Location Search
                GestureDetector(
                  onTap: navigateToSearchScreen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            destinationAddress ?? "Enter Destination",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
