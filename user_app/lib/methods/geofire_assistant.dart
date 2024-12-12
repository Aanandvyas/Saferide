import 'package:user_app/models/active_nearby_available_drivers.dart';

class GeofireAssistant {
  static List<ActiveNearByAvailableDrivers> activeNearByAvailableDriversList =
      [];

  static void deleteOfflineDriversFromList(String driverId) {
    int indexNumber = activeNearByAvailableDriversList
        .indexWhere((element) => element.driverId == driverId);

    if (indexNumber != -1) {
      activeNearByAvailableDriversList.removeAt(indexNumber);
    }
  }

  static void updateActiveNearByAvailableDriversList(
      ActiveNearByAvailableDrivers driverWhoMove) {
    int indexNumber = activeNearByAvailableDriversList
        .indexWhere((element) => element.driverId == driverWhoMove.driverId);

    if (indexNumber != -1) {
      activeNearByAvailableDriversList[indexNumber].locationLatitude =
          driverWhoMove.locationLatitude;
      activeNearByAvailableDriversList[indexNumber].locationLongitude =
          driverWhoMove.locationLongitude;
    } else {
      // Add the driver if not already in the list
      activeNearByAvailableDriversList.add(driverWhoMove);
    }
  }
}
