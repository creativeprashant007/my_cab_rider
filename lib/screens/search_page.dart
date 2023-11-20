import 'package:cab_rider/constants/brand_colors.dart';
import 'package:cab_rider/global/global_variables.dart';
import 'package:cab_rider/helpers/request_helpers.dart';
import 'package:cab_rider/model/predictions.dart';
import 'package:cab_rider/provider/app_data.dart';
import 'package:cab_rider/widgets/brand_divider.dart';
import 'package:cab_rider/widgets/prediction_tile.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  static const String id = "search";
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _pickUpController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  FocusNode focusDestination = FocusNode();
  bool focused = false;
  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Predictions> destinatinPredictionList = [];

  void SearchPlace(String placeName) async {
    print(
        'we are inside the search lace methohhdfads=-==================================');
    if (placeName.length > 1) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${placeName}&key=${mapKey}&sessiontoken=1234567890&components=country:np";

      var response = await RequestHelper.getRequest(url);
      if (response == "failed") {
        return;
      }
      if (response["status"] == "OK") {
        var predictionJSON = response["predictions"];
        var thisList = (predictionJSON as List)
            .map(
              (e) => Predictions.fromJson(e),
            )
            .toList();
        setState(() {
          destinatinPredictionList = thisList;
        });
      }

      print(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    String address = Provider.of<AppData>(context).pickupAddress!.placeName;
    _pickUpController.text = address;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  top: 35,
                  right: 24,
                  bottom: 20.0,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Stack(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.arrow_back)),
                        Center(
                          child: Text(
                            'Set Destination',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Brand-Bold',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: BrandColors.colorLightGrayFair,
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                controller: _pickUpController,
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                  hintText: 'Pickup location',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 10,
                                    top: 8,
                                    bottom: 8,
                                    right: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/desticon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: BrandColors.colorLightGrayFair,
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                onChanged: (value) {
                                  print(
                                      'we are inside un change method++++++++++++++______________');
                                  print(value);
                                  SearchPlace(value);
                                },
                                controller: _destinationController,
                                focusNode: focusDestination,
                                decoration: InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: BrandColors.colorLightGrayFair,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 10,
                                    top: 8,
                                    bottom: 8,
                                    right: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //prdiction list view
            destinatinPredictionList.length > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0.0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                            predictions: destinatinPredictionList[index]);
                      },
                      separatorBuilder: (context, index) {
                        return BrandDivider();
                      },
                      itemCount: destinatinPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
