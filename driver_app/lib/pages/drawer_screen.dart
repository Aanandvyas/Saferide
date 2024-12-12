import 'dart:async';
import 'dart:convert';
import 'package:driver_app/global/global_var.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:driver_app/models/user_ride_request_information.dart';

class Destinationreach extends StatefulWidget {
  final UserRideRequestInformation rideRequestInfo;

  const Destinationreach({
    super.key,
    required this.rideRequestInfo,
  });

  @override
  State<Destinationreach> createState() => _DestinationreachState();
}

class _DestinationreachState extends State<Destinationreach> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _fetchAndAddPolyline();
  }

  // Add markers for origin and destination
  Future<void> _addMarkers() async {
    BitmapDescriptor carIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/car.png',
    );
    BitmapDescriptor destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/final.png',
    );

    setState(() {
      // Origin Marker
      if (widget.rideRequestInfo.originLatLng != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('origin'),
            position: widget.rideRequestInfo.originLatLng!,
            icon: carIcon,
            infoWindow: InfoWindow(
              title: 'Origin',
              snippet: widget.rideRequestInfo.originAddress ?? '',
            ),
          ),
        );
      }

      // Destination Marker
      if (widget.rideRequestInfo.destinationLatLng != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: widget.rideRequestInfo.destinationLatLng!,
            icon: destinationIcon,
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: widget.rideRequestInfo.destinationAddress ?? '',
            ),
          ),
        );
      }
    });
  }

  // Fetch directions and add polyline
  Future<void> _fetchAndAddPolyline() async {
    try {
      final origin = widget.rideRequestInfo.originLatLng;
      final destination = widget.rideRequestInfo.destinationLatLng;

      if (origin == null || destination == null) {
        print("Origin or destination coordinates are null");
        return;
      }

      final directions = await _fetchDirectionsFromAPI(origin, destination);

      print("Decoded Polyline Points: ${directions.length}");

      if (directions.isNotEmpty) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: directions,
              color: Colors.blue,
              width: 6,
            ),
          );
        });

        // Adjust camera to fit the route
        LatLngBounds bounds = _getLatLngBounds(
          origin: origin,
          destination: destination,
        );
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 70),
        );
      } else {
        print("No directions found, adding fake polyline");
        _addFakePolyline();
      }
    } catch (e) {
      print("Error in fetching polyline: $e");
      _addFakePolyline();
    }
  }

  // Fetch directions from Google Maps API
  Future<List<LatLng>> _fetchDirectionsFromAPI(
      LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleMapsKey';

    print("Directions API URL: $url"); // Log the full URL for debugging

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // More detailed error checking
        if (data['status'] != 'OK') {
          print("API Error Status: ${data['status']}");
          print(
              "API Error Message: ${data['error_message'] ?? 'No error message'}");
          return [];
        }

        if (data['routes'] == null || data['routes'].isEmpty) {
          print("No routes found in the API response");
          return [];
        }

        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(polylinePoints);
      } else {
        print("HTTP Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception in fetching directions: $e");
      return [];
    }
  }

  // Add fake polyline as fallback
  void _addFakePolyline() {
    final origin = widget.rideRequestInfo.originLatLng;
    final destination = widget.rideRequestInfo.destinationLatLng;

    if (origin != null && destination != null) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('fake_route'),
            points: [origin, destination],
            color: Colors.red,
            width: 4,
          ),
        );
      });

      LatLngBounds bounds = _getLatLngBounds(
        origin: origin,
        destination: destination,
      );
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 70),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Using fallback route.")),
      );
    }
  }

  // Decode polyline
  List<LatLng> _decodePolyline(String encoded) {
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

  // Helper method to calculate LatLngBounds
  LatLngBounds _getLatLngBounds({
    required LatLng origin,
    required LatLng destination,
  }) {
    double minLat = origin.latitude < destination.latitude
        ? origin.latitude
        : destination.latitude;
    double minLng = origin.longitude < destination.longitude
        ? origin.longitude
        : destination.longitude;
    double maxLat = origin.latitude > destination.latitude
        ? origin.latitude
        : destination.latitude;
    double maxLng = origin.longitude > destination.longitude
        ? origin.longitude
        : destination.longitude;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination Reach'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  widget.rideRequestInfo.originLatLng ?? const LatLng(0.0, 0.0),
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ride Completed!")),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ride Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
