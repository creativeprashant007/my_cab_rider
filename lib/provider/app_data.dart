import 'package:cab_rider/model/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  Address? pickupAddress;
  Address? destinatinAddress;

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination) {
    destinatinAddress = destination;
    notifyListeners();
  }
}
