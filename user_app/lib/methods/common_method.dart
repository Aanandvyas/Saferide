import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/methods/direction_details_info.dart';
import 'package:user_app/models/directions.dart';
import 'package:user_app/infoHandler/app_info.dart';

class CommonMethods {
  // Fetch address for given geographic coordinates
  Future<String> searchAddressForGeographicCoordinates(
      Position position, BuildContext context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapsKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          String address = data['results'][0]['formatted_address'];
          Directions userPickUpAddress = Directions(
            locationLatitude: position.latitude,
            locationLongitude: position.longitude,
            locationName: address,
          );

          // Update provider
          Provider.of<AppInfo>(context, listen: false)
              .updatePickkUpLocationAddress(userPickUpAddress);
          return address;
        } else {
          return "No address found.";
        }
      } else {
        return "Error retrieving address.";
      }
    } catch (e) {
      print("Error in searchAddressForGeographicCoordinates: $e");
      return "Failed to fetch address.";
    }
  }

  // Add this method in CommonMethods
Future<LatLng?> getCoordinatesFromAddress(String address) async {
  try {
    final query = Uri.encodeComponent(address);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$googleMapsKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        return LatLng(lat, lng);
      }
    }
  } catch (e) {
    print("Error in geocoding address: $e");
  }
  return null;
}


  Future<Map<String, dynamic>?> fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      return null;
    }
  }

  Future<DirectionDetailsInfo?> fetchDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}&"
        "destination=${destination.latitude},${destination.longitude}&"
        "key=$googleMapsKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        debugPrint("Error: ${response.statusCode} ${response.body}");
        return null;
      }

      final data = json.decode(response.body);
      if ((data['routes'] as List).isEmpty) {
        debugPrint("No routes available.");
        return null;
      }

      final route = data['routes'][0];
      return DirectionDetailsInfo(
        ePoints: decodePolyline(route["overview_polyline"]["points"]),
        distanceValue: route["legs"][0]["distance"]["value"],
        durationValue: route["legs"][0]["duration"]["value"],
        distanceText: route["legs"][0]["distance"]["text"],
        durationText: route["legs"][0]["duration"]["text"],
      );
    } catch (e) {
      debugPrint("Error fetching directions: $e");
      return null;
    }
  }

  void showLoadingDialog(String message, context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.yellow),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  // Obtain directions details between origin and destination
  Future<DirectionDetailsInfo?> obtainOriginToDirectionDetails(
    Directions? originPosition,
    Directions? destinationPosition,
  ) async {
    if (originPosition == null || destinationPosition == null) return null;

    String directionsUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.locationLatitude},${originPosition.locationLongitude}&destination=${destinationPosition.locationLatitude},${destinationPosition.locationLongitude}&key=YOUR_GOOGLE_MAPS_API_KEY";

    try {
      var responseApi = await fetchData(directionsUrl);

      if (responseApi == null || responseApi["status"] != "OK") return null;

      DirectionDetailsInfo directionDetails = DirectionDetailsInfo(
        ePoints: decodePolyline(
            responseApi["routes"][0]["overview_polyline"]["points"]),
        distanceValue: responseApi["routes"][0]["legs"][0]["distance"]["value"],
        durationValue: responseApi["routes"][0]["legs"][0]["duration"]["value"],
        distanceText: responseApi["routes"][0]["legs"][0]["distance"]["text"],
        durationText: responseApi["routes"][0]["legs"][0]["duration"]["text"],
      );

      return directionDetails;
    } catch (e) {
      debugPrint("Error obtaining directions: $e");
      return null;
    }
  }

  // Decode polyline
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Snackbar
  void displaySnackBar(String message, BuildContext context,
      {bool isSuccess = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
    );

    // Ensuring context is valid and ScaffoldMessenger is available
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  // Check network connection
  Future<bool> checkConnectivity(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      displaySnackBar(
          "No internet connection. Please try again later.", context);
      return false;
    }
    return true;
  }

  /// Draw a polyline from origin to destination
  Future<void> drawPolyLineFromOriginToDestination({
  required BuildContext context,
  required GoogleMapController googleMapController,
  required Set<Polyline> polylineSet,
  required Function(Set<Polyline>) onUpdatePolylineSet,
}) async {
  try {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    final Directions? pickLocation = appInfo.userPickUpLocation;
    final Directions? dropOffLocation = appInfo.UserDropOffLocation;

    // Null and data validation
    if (pickLocation == null || dropOffLocation == null) {
      _showSafeSnackBar(context, "Pickup or destination location is null.");
      return;
    }

    // Ensure location coordinates are valid
    if (pickLocation.locationLatitude == null || pickLocation.locationLongitude == null ||
        dropOffLocation.locationLatitude == null || dropOffLocation.locationLongitude == null) {
      _showSafeSnackBar(context, "Pickup or destination coordinates are invalid.");
      return;
    }

    // Create LatLng objects
    final LatLng originLatLng = LatLng(
      pickLocation.locationLatitude!, pickLocation.locationLongitude!);
    final LatLng destinationLatLng = LatLng(
      dropOffLocation.locationLatitude!, dropOffLocation.locationLongitude!);

    // Fetch directions
    DirectionDetailsInfo? directionDetails =
        await obtainOriginToDirectionDetails(pickLocation, dropOffLocation);

    if (directionDetails == null) {
      _showSafeSnackBar(context, "Unable to fetch route directions.");
      return;
    }

    // Safely handle polyline creation
    polylineSet.clear();
    Polyline polyline = Polyline(
      polylineId: const PolylineId("route"),
      color: Colors.blue,
      width: 6,
      points: directionDetails.ePoints,
    );
    polylineSet.add(polyline);

    // Update polyline set
    onUpdatePolylineSet(polylineSet);

    // Calculate bounds for camera positioning
    final bounds = _getLatLngBounds(
        pickLocation: originLatLng, dropOffLocation: destinationLatLng);

    // Safely animate camera
    _animateCameraToRouteView(googleMapController, bounds);

    _showSafeSnackBar(context, "Route successfully drawn!");
  } catch (e, stackTrace) {
    debugPrint("Error in drawPolyLineFromOriginToDestination: $e");
    debugPrint("Stack trace: $stackTrace");
    _showSafeSnackBar(context, "An unexpected error occurred.");
  }
}

// Safe SnackBar method
void _showSafeSnackBar(BuildContext context, String message) {
  // Ensure we're not on a disposed context
  if (!context.mounted) return;

  // Use ScaffoldMessenger to show snack bar safely
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

// Safer camera animation
void _animateCameraToRouteView(
    GoogleMapController? controller, LatLngBounds bounds) {
  if (controller == null) {
    debugPrint("Google Map Controller is null");
    return;
  }

  try {
    // Validate bounds
    if (_areBoundsValid(bounds)) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    } else {
      debugPrint("Invalid camera bounds");
    }
  } on PlatformException catch (e) {
    debugPrint("Platform Exception in camera animation: ${e.message}");
  } catch (e) {
    debugPrint("Unexpected error in camera animation: $e");
  }
}

// Bounds validation method
bool _areBoundsValid(LatLngBounds bounds) {
  return bounds.southwest.latitude != bounds.northeast.latitude &&
      bounds.southwest.longitude != bounds.northeast.longitude;
}

// Helper to calculate LatLngBounds
LatLngBounds _getLatLngBounds({
  required LatLng pickLocation,
  required LatLng dropOffLocation,
}) {
  return LatLngBounds(
    southwest: LatLng(
      math.min(pickLocation.latitude, dropOffLocation.latitude),
      math.min(pickLocation.longitude, dropOffLocation.longitude),
    ),
    northeast: LatLng(
      math.max(pickLocation.latitude, dropOffLocation.latitude),
      math.max(pickLocation.longitude, dropOffLocation.longitude),
    ),
  );
}

  /// Fetch address for given latitude and longitude coordinates
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          return "No address found.";
        }
      } else {
        return "Error retrieving address.";
      }
    } catch (e) {
      print("Error in getAddressFromCoordinates: $e");
      return "Failed to fetch address.";
    }
  }

  static double calculateFareAmountFromOrigintoDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    // Calculate fare based on travel time
    double timeTravelledFareAmountPerMinute =
        (directionDetailsInfo.durationValue / 60) * 0.1;

    // Calculate fare based on distance (in kilometers)
    double distanceFareAmountPerKilometer =
        (directionDetailsInfo.distanceValue / 1000) * 0.2;

    // Total fare
    double totalFareAmount =
        timeTravelledFareAmountPerMinute + distanceFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': serviceAccountJson,
    };

    Map bodyNotification = {
      "body": "Destination Address: \n$destinationAddress ",
      "title": "New Trip Request"
    };

    Map dataMap = {
      "body": "Destination Address:  \n$destinationAddress",
      "id": "1",
      "status": "done",
      "rideRequested": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notifier": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken
    };

    var responseNotification = http.post(
        Uri.parse("https://www.googleapis.com/auth/firebase.messaging"),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat));
  }
}
