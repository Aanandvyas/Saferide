import 'package:driver_app/models/directions.dart';
import 'package:flutter/cupertino.dart';


class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, UserDropOffLocation;
  int countTotalTrips = 0;

  void updatePickkUpLocationAddress(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress){
    UserDropOffLocation = userDropOffAddress;
    notifyListeners();
  }
}
