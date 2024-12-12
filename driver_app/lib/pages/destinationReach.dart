import 'dart:async';
import 'package:driver_app/models/user_ride_request_information.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/widgets/progress_dialog.dart';

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
  final CommonMethods _commonMethods = CommonMethods();

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Loading route, please wait...",
      ),
    );

    try {
      final origin = widget.rideRequestInfo.originLatLng;
      final destination = widget.rideRequestInfo.destinationLatLng;

      if (origin == null || destination == null) {
        throw Exception("Missing origin or destination coordinates.");
      }

      final directions = await _commonMethods.fetchDirections(
        origin: origin,
        destination: destination,
      );

      if (directions != null) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: directions.ePoints,
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      Navigator.pop(context); // Close the progress dialog
    }
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
              target: widget.rideRequestInfo.originLatLng ??
                  const LatLng(0.0, 0.0),
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
