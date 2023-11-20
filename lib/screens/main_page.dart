import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cab_rider/constants/brand_colors.dart';
import 'package:cab_rider/global/global_variables.dart';
import 'package:cab_rider/helpers/fire_helper.dart';
import 'package:cab_rider/helpers/helper_methods.dart';
import 'package:cab_rider/model/directions_details.dart';
import 'package:cab_rider/model/near_by_drivers.dart';
import 'package:cab_rider/provider/app_data.dart';
import 'package:cab_rider/rider_variables/ride_variables.dart';
import 'package:cab_rider/screens/search_page.dart';
import 'package:cab_rider/widgets/brand_divider.dart';
import 'package:cab_rider/widgets/collect_payment_dialog.dart';
import 'package:cab_rider/widgets/no_driver_dialog.dart';
import 'package:cab_rider/widgets/progress_dialog_cust.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  double rideDetailsSheetHeight = 0; //(Platform.isAndroid) ?235:260
  double requestingSheetHeight = 0; //(Platform.isAndroid) ?195:220
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  double mapButtomPadding = 0;
  double searchsheetHeight = (Platform.isIOS) ? 300 : 265;
  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> _polyline = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  StreamSubscription<DatabaseEvent>? rideSubscription;
  double tripSheetHeight = 0; //(Platform.isAndroid):275:300

  BitmapDescriptor? nearByIcons;

  Geolocator? geoLocator;
  Position? currentPosition;

  DirectionDetails? tripDirectionDetails;
  bool drawerCanOpen = true;
  String appState = "NORMAL";

  DatabaseReference? rideRef;
  List<NearByDrivers> availabelDrivers = [];

  bool nearByDriverKeysLoaded = false;

  bool isRequestingLocationDetails = false;
  Future<dynamic> _callPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    setState(() {
      currentPosition = position;
    });
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 17);
    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    print('we are her man go to fetch address');
    String address = await HelperMethods.findCordinateAddress(
      position.latitude,
      position.longitude,
      context,
    );

    print('herei is the address${position.latitude} lon${position.longitude}');
    print(address);

    startGeoFireListener();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mapController!.dispose();
    super.dispose();
  }

  void createMarker() {
    if (nearByIcons == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        Platform.isIOS
            ? 'assets/images/car_ios.png'
            : 'assets/images/car_android.png',
      ).then((icon) {
        nearByIcons = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    _callPermission();
    HelperMethods.getCurrentUserInfo();
    super.initState();
  }

  void showDetailSheet() async {
    await getDirection();
    setState(() {
      searchsheetHeight = 0;
      rideDetailsSheetHeight = (Platform.isAndroid) ? 235 : 260;
      mapButtomPadding = Platform.isAndroid ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapButtomPadding = Platform.isAndroid ? 200 : 190;
      drawerCanOpen = true;
    });
    createRideRequest();
  }

  void showTripSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = Platform.isAndroid ? 275 : 300;
      mapButtomPadding = Platform.isAndroid ? 280 : 270;
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 40, bottom: mapButtomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            markers: _markers,
            circles: _circles,
            polylines: _polyline,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setupPositionLocator();
              mapController = controller;
              setState(() {
                mapButtomPadding = (Platform.isIOS) ? 280 : 270;
              });
            },
          ),

          Positioned(
            top: 44,
            left: 20,
            child: InkWell(
              onTap: () {
                if (drawerCanOpen) {
                  _scaffoldKey.currentState!.openDrawer();
                } else
                  resetApp();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      drawerCanOpen ? Icons.menu : Icons.arrow_back,
                      color: Colors.black87,
                    )),
              ),
            ),
          ),

          //search Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(microseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchsheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Nice to see you!',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'Where are you going!',
                        style:
                            TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          var response = await Navigator.of(context)
                              .pushNamed(SearchPage.id);
                          if (response == "getDirection") {
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                ),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Search Destination',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Row(
                        children: [
                          Icon(OMIcons.home, color: BrandColors.colorDimText),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                child: Text(
                                  (Provider.of<AppData>(context)
                                              .pickupAddress !=
                                          null)
                                      ? Provider.of<AppData>(context)
                                          .pickupAddress!
                                          .placeName
                                      : 'Add Home',
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              SizedBox(
                                height: 3.0,
                              ),
                              Text(
                                'Your residential address',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: BrandColors.colorDimText),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      BrandDivider(),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Icon(OMIcons.workOutline,
                              color: BrandColors.colorDimText),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Work'),
                              SizedBox(
                                height: 3.0,
                              ),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: BrandColors.colorDimText),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //Ride Details sheet
          rideDetailsSheetHeight == 0
              ? Container()
              : Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    duration: Duration(milliseconds: 150),
                    child: Container(
                      height: rideDetailsSheetHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: BrandColors.colorAccent1,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/taxi.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Taxi',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Brand-Bold'),
                                        ),
                                        Text(
                                          '${tripDirectionDetails!.distanceText}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  BrandColors.colorTextLight),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      'Rs ${(tripDirectionDetails != null) ? HelperMethods.estimateFares(tripDirectionDetails!).toString() : ''}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(FontAwesomeIcons.moneyBillAlt,
                                    size: 18,
                                    color: BrandColors.colorTextLight),
                                SizedBox(
                                  width: 16,
                                ),
                                Text('Cash'),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: BrandColors.colorTextLight,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 22.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TexiButton(
                              callback: () {
                                ///createRideRequest();
                                ///
                                setState(() {
                                  appState = "REQUESTING";
                                });
                                showRequestingSheet();
                                availabelDrivers = FireHelper.nearByDriverList!;
                                findDriver();
                              },
                              color: BrandColors.colorGreen,
                              title: 'REQUEST CAB',
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(microseconds: 300),
              curve: Curves.easeIn,
              child: Container(
                height: requestingSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(15.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20.0,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: BrandColors.colorTextSemiLight,
                          strokeWidth: 1,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a Ride...',
                          waveColor: BrandColors.colorTextSemiLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: BrandColors.colorText,
                            fontSize: 25.0,
                            fontFamily: 'Brand-Bold',
                          ),
                          boxHeight: 45.0,
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      InkWell(
                        onTap: () {
                          cancelRequest();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1.0,
                              color: BrandColors.colorLightGrayFair,
                            ),
                          ),
                          child: Icon(Icons.close, size: 25),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //after accepting the ride request
          //trip sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(microseconds: 300),
              curve: Curves.easeIn,
              child: Container(
                height: tripSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(15.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$tripStatusDisplay",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Brand-Bold",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      BrandDivider(),
                      SizedBox(height: 20),
                      Text(
                        "$driverCarDetails",
                        style: TextStyle(color: BrandColors.colorTextLight),
                      ),
                      Text(
                        "$driverFullName",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      BrandDivider(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          iconButton(
                              text: "Call", icon: Icons.call, callback: () {}),
                          iconButton(
                              text: "Details",
                              icon: Icons.list,
                              callback: () {}),
                          iconButton(
                              text: "cancel",
                              icon: OMIcons.clear,
                              callback: () {
                                cancelRequest();

                                setState(() {
                                  tripSheetHeight = 0;
                                });
                              }),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget iconButton({
    String? text,
    IconData? icon,
    VoidCallback? callback,
  }) {
    return GestureDetector(
      onTap: callback,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              border: Border.all(
                width: 1.0,
                color: BrandColors.colorTextLight,
              ),
            ),
            child: Icon(icon),
          ),
          SizedBox(
            height: 10,
          ),
          Text("$text")
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickUp = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinatinAddress;

    var pickLatLng = LatLng(
      pickUp!.latitude,
      pickUp.longitude,
    );
    var destinationLatLng = LatLng(
      destination!.latitude,
      destination.longitude,
    );
    showDialog(
      context: context,
      builder: (context) => ProgressDialogCust(
        status: 'Please Wait',
      ),
    );
    var thisDetails =
        await HelperMethods.getDirectionDetaiils(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.of(context).pop();
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline('${thisDetails!.encodedPoints}');
    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((points) {
        polyLineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }
    _polyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyId'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polyline.add(polyline);
    });

    LatLngBounds bounds;
    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds = LatLngBounds(
        southwest: pickLatLng,
        northeast: destinationLatLng,
      );
    }
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickUp.placeName, snippet: "My Location"),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: "My Destination"),
    );
    _markers.clear();
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId(
        'pickup',
      ),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId(
        'destination',
      ),
      strokeColor: Colors.red,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    _circles.clear();
    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  resetApp() {
    setState(() {
      polyLineCoordinates.clear();
      _polyline.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = 0;
      status = "";
      driverFullName = "";
      driverCarDetails = "";
      driverPhoneNumber = "";
      tripStatusDisplay = "Driver is Arriving";
      searchsheetHeight = Platform.isAndroid ? 260 : 300;
      mapButtomPadding = Platform.isAndroid ? 280 : 270;
      drawerCanOpen = true;
      setupPositionLocator();
    });
  }

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.ref().child("rideRequest").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinatinAddress;
    Map pickUpMap = {
      'latitude': pickUp!.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };
    Map destinationMap = {
      'latitude': destination!.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };
    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo!.fullName,
      'rider_phone': currentUserInfo!.phone,
      'pickup_address': pickUp.placeName,
      'destination_address': destination.placeName,
      'location': pickUpMap,
      'destination': destinationMap,
      'payment_method': 'cash',
      'driver_id': 'waiting',
    };

    rideRef!.set(rideMap);
    rideSubscription = rideRef!.onValue.listen((DatabaseEvent? event) async {
      print("arrived here is driver arriced $status");
      if (event!.snapshot.value == null) {
        return;
      }

      if ((event.snapshot.value as dynamic)['car_details'] != null) {
        setState(() {
          driverCarDetails = (event.snapshot.value as dynamic)['car_details'];
        });
      }
      if ((event.snapshot.value as dynamic)['driver_name'] != null) {
        setState(() {
          driverFullName = (event.snapshot.value as dynamic)['driver_name'];
        });
      }
      if ((event.snapshot.value as dynamic)['driver_phone'] != null) {
        setState(() {
          driverPhoneNumber = (event.snapshot.value as dynamic)['driver_phone'];
        });
      }
      if ((event.snapshot.value as dynamic)['status'] != null) {
        status = (event.snapshot.value as dynamic)['status'];
        setState(() {});
      }
      if (status == "accepted") {
        showTripSheet();

        Geofire.stopListener();
        removeGeofireMarkers();
      }
      //get and use driver location updates
      if ((event.snapshot.value as dynamic)['driver_location'] != null) {
        double driverLat = double.parse(
            (event.snapshot.value as dynamic)['driver_location']['latitude']
                .toString());
        double driverLng = double.parse(
            (event.snapshot.value as dynamic)['driver_location']['lognitude']
                .toString());
        LatLng driverLocation = LatLng(driverLat, driverLng);
        print("arrived here is driver arriced $status");
        if (status == "accepted") {
          updateToPickup(driverLocation: driverLocation);
        } else if (status == "arrive") {
          print("arrived here is driver arriced 23334 $status");
          setState(() {
            tripStatusDisplay = "Driver has arrived";
          });
        } else if (status == "ontrip") {
          updateToDestination(driverLocation: driverLocation);
        } else if (status == "ended") {
          setState(() {
            tripStatusDisplay = "Driver has ended";
          });
        }
      }
      if (status == "ended") {
        if ((event.snapshot.value as dynamic)["fares"] != null) {
          int fares =
              int.parse((event.snapshot.value as dynamic)["fares"].toString());
          var response = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return CollectPayment(
                  paymentMethod:
                      "${(event.snapshot.value as dynamic)['payment_method']}",
                  fares: fares,
                );
              });
          if (response == "close") {
            rideRef!.onDisconnect();
            rideRef = null;
            rideSubscription!.cancel();
            rideSubscription = null;

            resetApp();
          }
        }
      }
    });
  }

  void removeGeofireMarkers() {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value.contains("driver"));
    });
  }

  void updateToPickup({LatLng? driverLocation}) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;
      var positionLatLng =
          LatLng(currentPosition!.latitude, currentPosition!.longitude);
      var thisDetails = await HelperMethods.getDirectionDetaiils(
          driverLocation!, positionLatLng);

      if (thisDetails == null) {
        return;
      }
      setState(() {
        tripStatusDisplay = "Driver is Arriving - ${thisDetails.durationText}";
      });
      isRequestingLocationDetails = false;
    }
  }

  void updateToDestination({LatLng? driverLocation}) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;
      var destination =
          Provider.of<AppData>(context, listen: false).destinatinAddress;
      var destinationLatLng =
          LatLng(destination!.latitude, destination.longitude);
      var thisDetails = await HelperMethods.getDirectionDetaiils(
          driverLocation!, destinationLatLng);

      if (thisDetails == null) {
        return;
      }
      setState(() {
        tripStatusDisplay =
            "Driving to Destination - ${thisDetails.durationText}";
      });
      isRequestingLocationDetails = false;
    }
  }

  void cancelRequest() {
    rideRef!.remove();
    setState(() {
      appState = "NORMAL";
    });
    resetApp();
  }

  void startGeoFireListener() async {
    print('here we are');
    Geofire.initialize('driversAvailable');
    print(
      currentPosition!.latitude,
    );
    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 60)!
        .listen((map) {
      print('need to print map');
      print(map);
      if (map != null) {
        print('we are inside map');
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearByDrivers nearByDrivers = NearByDrivers();
            nearByDrivers.key = map['key'];
            nearByDrivers.latitude = map['latitude'];
            nearByDrivers.longitiude = map['longitude'];
            FireHelper.nearByDriverList!.add(nearByDrivers);
            if (nearByDriverKeysLoaded) {
              updateDrivers();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDrivers();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearByDrivers nearByDrivers = NearByDrivers();
            nearByDrivers.key = map['key'];
            nearByDrivers.latitude = map['latitude'];
            nearByDrivers.longitiude = map['longitude'];

            FireHelper.updateNearByLocation(nearByDrivers);
            updateDrivers();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            nearByDriverKeysLoaded = true;
            updateDrivers();
            print('driver length:${FireHelper.nearByDriverList!.length}');
            print(map['result']);

            break;
        }
      }
      //setState(() {});
    });
  }

  void updateDrivers() async {
    setState(() {
      _markers.clear();
    });
    Set<Marker> tempMarkers = Set<Marker>();
    for (NearByDrivers driver in FireHelper.nearByDriverList!) {
      LatLng driverPosition = LatLng(driver.latitude!, driver.longitiude!);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearByIcons!,
        rotation: HelperMethods.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _markers = tempMarkers;
    });
  }

  void noDriverFound() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return NoDriverDialog();
        });
  }

  void findDriver() {
    if (availabelDrivers.length == 0) {
      cancelRequest();
      noDriverFound();
      resetApp();
      return;
    }
    var driver = availabelDrivers[0];
    availabelDrivers.removeAt(0);
    notifyDriver(driver);
    print(driver.key);
  }

  void notifyDriver(NearByDrivers drivers) {
    DatabaseReference driverTripRef =
        FirebaseDatabase.instance.ref().child("drivers/${drivers.key}/newtrip");
    driverTripRef.set(rideRef!.key);
    DatabaseReference tokenRef =
        FirebaseDatabase.instance.ref().child("drivers/${drivers.key}/token");
    tokenRef.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        String token = snapshot.snapshot.value.toString();
        HelperMethods.sendNotification(
            context: context, rideId: rideRef!.key, token: token);
      } else {
        return;
      }
      const oneSecTric = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecTric, (timer) {
        //stop timer when ride request is cancelled
        if (appState != "REQUESTING") {
          driverTripRef.set("cancelled");
          driverTripRef.onDisconnect();
          timer.cancel();
          driverRequestTimeOut = 30;
        }
        driverRequestTimeOut--;
        driverTripRef.onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driverTripRef.onDisconnect();
            timer.cancel();
            driverRequestTimeOut = 30;
          }
        });

        if (driverRequestTimeOut == 0) {
          //
          driverTripRef.set("timeout");
          driverTripRef.onDisconnect();
          driverRequestTimeOut = 30;
          timer.cancel();
//select the next cloest driver
          findDriver();
        }
      });
    });
  }
}
