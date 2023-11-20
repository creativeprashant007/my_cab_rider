// @dart=2.9

import 'dart:io';

import 'package:cab_rider/provider/app_data.dart';
import 'package:cab_rider/screens/login_page.dart';
import 'package:cab_rider/screens/main_page.dart';
import 'package:cab_rider/screens/regisration_page.dart';
import 'package:cab_rider/screens/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'global/global_variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    //  name: 'db3',
    options: Platform.isIOS || Platform.isMacOS
        ? const FirebaseOptions(
            appId: '1:297855924061:ios:c6de2b69b03a5be8',
            apiKey: 'AIzaSyBEnYVcxOEaejEzT6UyG8l8n5EZ2mT9C1I',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '297855924061',
            databaseURL: 'https://cab-rider-35e1c-default-rtdb.firebaseio.com',
          )
        : const FirebaseOptions(
            appId: '1:589846735931:android:d64a53fd3793d6e0c8c01e',
            apiKey: 'AIzaSyBEnYVcxOEaejEzT6UyG8l8n5EZ2mT9C1I',
            messagingSenderId: '297855924061',
            projectId: 'flutter-firebase-plugins',
            databaseURL: 'https://cab-rider-35e1c-default-rtdb.firebaseio.com',
          ),
  );
  currentFirebaseUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Brand-Regular',
        ),
        //  home: RegistrationPage(),
        initialRoute: currentFirebaseUser == null ? LoginPage.id : MainPage.id,
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MainPage.id: (context) => MainPage(),
          SearchPage.id: (context) => SearchPage(),
        },
      ),
    );
  }
}
