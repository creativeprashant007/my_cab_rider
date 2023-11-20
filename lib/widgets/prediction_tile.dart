import 'package:cab_rider/constants/brand_colors.dart';
import 'package:cab_rider/global/global_variables.dart';
import 'package:cab_rider/helpers/request_helpers.dart';
import 'package:cab_rider/model/address.dart';
import 'package:cab_rider/model/predictions.dart';
import 'package:cab_rider/provider/app_data.dart';
import 'package:cab_rider/widgets/progress_dialog_cust.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {
  final Predictions predictions;

  const PredictionTile({Key? key, required this.predictions}) : super(key: key);

  void getPlaceDetails(String placeId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialogCust(status: 'Please Wait..'),
    );
    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=${placeId}&key=$mapKey";
    var response = await RequestHelper.getRequest(url);

    if (response == "failed") {
      Navigator.of(context).pop();
      return;
    }
    if (response['status'] == "OK") {
      Navigator.of(context).pop();
      Address thisPlace = Address(
        placeName: response['result']['name'],
        latitude: response['result']['geometry']['location']['lat'],
        longitude: response['result']['geometry']['location']['lng'],
        placeFormattedAddress: response['result']['formatted_address'],
        placeId: placeId,
      );
      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);
      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      
      onPressed: () {
        getPlaceDetails(
          '${predictions.place_id}',
          context,
        );
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                Icon(
                  OMIcons.locationOn,
                  color: BrandColors.colorDimText,
                ),
                SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${predictions.main_text}',
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        '${predictions.secondary_text}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.colorDimText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
