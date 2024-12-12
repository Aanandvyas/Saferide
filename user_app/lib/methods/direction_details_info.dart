import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionDetailsInfo {
  final List<LatLng> ePoints;
  final int distanceValue;
  final int durationValue;
  final String distanceText;
  final String durationText;

  DirectionDetailsInfo({
    required this.ePoints,
    required this.distanceValue,
    required this.durationValue,
    required this.distanceText,
    required this.durationText,
  });

  // Method to parse JSON data for the directions
  factory DirectionDetailsInfo.fromJson(Map<String, dynamic> json) {
    var polyline = json['overview_polyline']['points'];
    List<LatLng> points = _decodePolyline(polyline);

    var legs = json['legs'] as List;
    var leg = legs[0];

    return DirectionDetailsInfo(
      ePoints: points,
      distanceValue: leg['distance']['value'],
      durationValue: leg['duration']['value'],
      distanceText: leg['distance']['text'],
      durationText: leg['duration']['text'],
    );
  }

  // Helper function to decode the polyline into a list of LatLng points
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }
}