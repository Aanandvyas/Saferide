import 'dart:convert';
import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/infoHandler/app_info.dart';
import 'package:driver_app/methods/direction_details_info.dart';
import 'package:driver_app/models/directions.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CommonMethods {
  /// Fetch address for given geographic coordinates
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  //check network connection
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
      // Fetch pickup and dropoff locations from AppInfo
      final Directions? pickLocation =
          Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
      final Directions? dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).UserDropOffLocation;

      if (pickLocation == null || dropOffLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pickup or destination is not set.")),
        );
        return;
      }

      // Get directions details
      DirectionDetailsInfo? directionDetails =
          await obtainOriginToDirectionDetail(pickLocation, dropOffLocation);

      if (directionDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to fetch directions.")),
        );
        return;
      }

      // Decode the polyline points
      List<LatLng> polylineCoordinates = directionDetails.ePoints;

      // Clear existing polylines
      polylineSet.clear();

      // Create a new polyline
      Polyline polyline = Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.blue,
        width: 6,
        points: polylineCoordinates,
      );

      // Add the polyline to the set
      polylineSet.add(polyline);

      // Update the UI with the new polyline set
      onUpdatePolylineSet(polylineSet);

      // Calculate bounds for the camera view
      LatLngBounds bounds = _getLatLngBounds(
        pickLocation: LatLng(
          pickLocation.locationLatitude!,
          pickLocation.locationLongitude!,
        ),
        dropOffLocation: LatLng(
          dropOffLocation.locationLatitude!,
          dropOffLocation.locationLongitude!,
        ),
      );

      // Animate the camera to fit the bounds
      googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 70),
      );

      // Display success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Route successfully drawn!")),
      );
    } catch (e) {
      debugPrint("Error in drawPolyLineFromOriginToDestination: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// Helper to calculate LatLngBounds
  LatLngBounds _getLatLngBounds({
    required LatLng pickLocation,
    required LatLng dropOffLocation,
  }) {
    return LatLngBounds(
      southwest: LatLng(
        pickLocation.latitude < dropOffLocation.latitude
            ? pickLocation.latitude
            : dropOffLocation.latitude,
        pickLocation.longitude < dropOffLocation.longitude
            ? pickLocation.longitude
            : dropOffLocation.longitude,
      ),
      northeast: LatLng(
        pickLocation.latitude > dropOffLocation.latitude
            ? pickLocation.latitude
            : dropOffLocation.latitude,
        pickLocation.longitude > dropOffLocation.longitude
            ? pickLocation.longitude
            : dropOffLocation.longitude,
      ),
    );
  }
  // Public wrapper for the private _getLatLngBounds method
LatLngBounds getLatLngBoundsWrapper({
  required LatLng pickLocation,
  required LatLng dropOffLocation,
}) {
  return _getLatLngBounds(pickLocation: pickLocation, dropOffLocation: dropOffLocation);
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

// Helper method to get min and max
  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;

  /// Fetch directions details between origin and destination
  Future<DirectionDetailsInfo?> obtainOriginToDirectionDetail(
      Directions? originPosition, Directions? destinationPosition) async {
    if (originPosition == null || destinationPosition == null) {
      return null;
    }

    String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.locationLatitude},${originPosition.locationLongitude}&destination=${destinationPosition.locationLatitude},${destinationPosition.locationLongitude}&key=$googleMapsKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['routes'] as List).isNotEmpty) {
          var route = data['routes'][0];
          DirectionDetailsInfo directionDetails = DirectionDetailsInfo(
            ePoints: decodePolyline(route["overview_polyline"]["points"]),
            distanceValue: route["legs"][0]["distance"]["value"],
            durationValue: route["legs"][0]["duration"]["value"],
            distanceText: route["legs"][0]["distance"]["text"],
            durationText: route["legs"][0]["duration"]["text"],
          );

          return directionDetails;
        } else {
          print("No routes found.");
          return null;
        }
      } else {
        print("Error retrieving directions: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in obtainOriginToDirectionDetails: $e");
      return null;
    }
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionDriverLivePosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTravelledFareAmountPerMinute =
        (directionDetailsInfo.durationValue / 60) * 0.1;

    double distanceTravelledFareAmountPerKilometer =
        (directionDetailsInfo.durationValue / 1000) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute +
        distanceTravelledFareAmountPerKilometer;

    double localCurrencyTotalFare = totalFareAmount * 107;

    if (driverVehicleType == "Bike") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
      resultFareAmount;
    } else if (driverVehicleType == "CNG") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 1.55);
      resultFareAmount;
    } else if (driverVehicleType == "Car") {
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 2);
      resultFareAmount;
    } else {
      return localCurrencyTotalFare.truncate().toDouble();
    }
    return localCurrencyTotalFare.truncate().toDouble();
  }
}
