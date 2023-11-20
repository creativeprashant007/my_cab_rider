import 'dart:convert';
import 'dart:math';

import 'package:cab_rider/global/global_variables.dart';
import 'package:cab_rider/helpers/request_helpers.dart';
import 'package:cab_rider/model/address.dart';
import 'package:cab_rider/model/directions_details.dart';
import 'package:cab_rider/model/user.dart';
import 'package:cab_rider/provider/app_data.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';

class HelperMethods {
  static void getCurrentUserInfo() async {
    currentFirebaseUser = firebase.FirebaseAuth.instance.currentUser!;
    String userId = currentFirebaseUser!.uid;
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('users/$userId');
    databaseReference.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        currentUserInfo = User.fromSnapsot(snapshot.snapshot);
        print(
            'her is my full ianem +++++++++++++++++++++++|||||||||||||||||||||||||||||||||||');
        print('my name is${currentUserInfo!.fullName}');
      }
    });
  }

  static Future<String> findCordinateAddress(
    double lat,
    double lng,
    BuildContext context,
  ) async {
    print('insider find co func');
    String placeAddress = "";
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${mapKey}";
    var response = await RequestHelper.getRequest(url);
    print('here s the latest response $response');
    if (response != "failed") {
      placeAddress = response['results'][0]['formatted_address'];
      Address pickupAddress = new Address(
        latitude: lat,
        longitude: lng,
        placeName: placeAddress,
        placeId: '',
        placeFormattedAddress: '',
      );
      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionDetaiils(
      LatLng startPosition, LatLng endPosition) async {
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=${mapKey}";
    var response = await RequestHelper.getRequest(url);
    print('here is helper method response');
    print(response);
    if (response == "failed") {
      print('failed here');
      return null;
    } else {
      print('success here');

      DirectionDetails directionDetails = DirectionDetails();
      directionDetails.durationText =
          response['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue =
          response['routes'][0]['legs'][0]['duration']['value'];
      directionDetails.distanceText =
          response['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue =
          response['routes'][0]['legs'][0]['distance']['value'];
      directionDetails.encodedPoints =
          response['routes'][0]['overview_polyline']['points'];
      print('here is final data');
      print(response['routes'][0]['legs'][0]['duration']['text']);

      return directionDetails;
    }
  }

  static int estimateFares(DirectionDetails details) {
    //per kilomerter = Rs 20
    //base fare = 30
    //perminute = 5

    double baseFare = 16;
    double distanceFare = (details.distanceValue! / 1000) * 5;
    double timeFare = (details.durationValue! / 60) * 2;
    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int ranInt = randomGenerator.nextInt(max);
    return ranInt.toDouble();
  }

  static sendNotification(
      {String? token, BuildContext? context, String? rideId}) async {
    print("here is final 1");
    var destination = Provider.of<AppData>(
      context!,
      listen: false,
    ).destinatinAddress;
    Map<String, String> headerMap = {
      "Content-Type": "application/json",
      "Authorization": "$serverKey",
    };
    Map notificationMap = {
      "title": 'NEW TRIP REQUEST',
      "body": 'Destination, ${destination!.placeName}',
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "ride_id": "$rideId",
      "status": "done",
    };
    Map bodyMap = {
      "notification": notificationMap,
      "proirity": 'high',
      "data": dataMap,
      "to": token
    };
    print("here is final 2");
    var response = await http.post(
      Uri.parse(firebasePushUrl),
      body: jsonEncode(bodyMap),
      headers: headerMap,
    );

    print("here is final ${response.body}");
  }

  static void enableHomTabLocationUpdates() {}
}
