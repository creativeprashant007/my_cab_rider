import 'package:cab_rider/model/near_by_drivers.dart';

class FireHelper {
  static List<NearByDrivers>? nearByDriverList = [];

  static void removeFromList(String key) {
    int index = nearByDriverList!.indexWhere((element) => element.key == key);
    nearByDriverList!.removeAt(index);
  }

  static void updateNearByLocation(NearByDrivers driver) {
    int index =
        nearByDriverList!.indexWhere((element) => element.key == driver.key);
    if (index >= 0) {
      nearByDriverList![index].longitiude = driver.longitiude;
      nearByDriverList![index].latitude = driver.latitude;
    }
  }
}
