import 'package:cab_rider/model/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

String mapKey = "AIzaSyBEnYVcxOEaejEzT6UyG8l8n5EZ2mT9C1I";

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

firebase.User? currentFirebaseUser;

User? currentUserInfo;

String serverKey =
    "key=AAAAiVWa7Ds:APA91bEsSGfvXyS8e-5dBkzHtID5jBBt_zQQtL3Ozz0uR6bSHMILVbSVqSbYUwJEmUs2T4hd8oJ7jpyPOvRO7sfN6dR7T4GhJPfjJWgn5d4nbI3hevLlYc7rbKy0Y4RyetkYibfjWZTa";
String firebasePushUrl = "https://fcm.googleapis.com/fcm/send";
