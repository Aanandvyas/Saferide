import 'package:user_app/methods/direction_details_info.dart';


class Directions {
  String? humanReadableAddress;
  String? locationName;
  String? locationId;
  double? locationLatitude;
  double? locationLongitude;
  DirectionDetailsInfo? directionDetails;

  Directions({
    this.humanReadableAddress,
    this.locationName,
    this.locationId,
    this.locationLatitude,
    this.locationLongitude,
    this.directionDetails,
  });

  // Method to parse JSON data from Directions API response
  factory Directions.fromJson(Map<String, dynamic> json) {
    var routes = json['routes'] as List;
    if (routes.isNotEmpty) {
      var route = routes[0];
      var legs = route['legs'] as List;
      if (legs.isNotEmpty) {
        var leg = legs[0];
        return Directions(
          humanReadableAddress: leg['end_address'],
          locationName: leg['start_address'],
          locationLatitude: leg['end_location']['lat'],
          locationLongitude: leg['end_location']['lng'],
          directionDetails: DirectionDetailsInfo.fromJson(route),
        );
      }
    }
    return Directions();
  }
}
