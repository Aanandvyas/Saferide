import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation {
  String? rideRequestId;
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? userName;
  String? userPhone;
  String? rideRequestStatus;

  UserRideRequestInformation({
    this.rideRequestId,
    this.originLatLng,
    this.destinationLatLng,
    this.originAddress,
    this.destinationAddress,
    this.userName,
    this.userPhone,
    this.rideRequestStatus,
  });

  /// Factory method to create an instance from a Firebase Realtime Database snapshot.
  factory UserRideRequestInformation.fromMap(Map<dynamic, dynamic> data) {
    return UserRideRequestInformation(
      rideRequestId: data['rideRequestId'] as String?,
      originLatLng: data['origin'] != null
          ? LatLng(
              double.parse(data['origin']['latitude'].toString()),
              double.parse(data['origin']['longitude'].toString()),
            )
          : null,
      destinationLatLng: data['destination'] != null
          ? LatLng(
              double.parse(data['destination']['latitude'].toString()),
              double.parse(data['destination']['longitude'].toString()),
            )
          : null,
      originAddress: data['originAddress'] as String?,
      destinationAddress: data['destinationAddress'] as String?,
      userName: data['userName'] as String?,
      userPhone: data['userPhone'] as String?,
      rideRequestStatus: data['rideRequestStatus'] as String?,
    );
  }

  /// Converts an instance into a Map (for Firebase or other uses).
  Map<String, dynamic> toMap() {
    return {
      'rideRequestId': rideRequestId,
      'origin': originLatLng != null
          ? {
              'latitude': originLatLng!.latitude,
              'longitude': originLatLng!.longitude,
            }
          : null,
      'destination': destinationLatLng != null
          ? {
              'latitude': destinationLatLng!.latitude,
              'longitude': destinationLatLng!.longitude,
            }
          : null,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'userName': userName,
      'userPhone': userPhone,
      'rideRequestStatus': rideRequestStatus,
    };
  }
}
