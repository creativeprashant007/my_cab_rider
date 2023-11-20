import 'package:cab_rider/constants/brand_colors.dart';
import 'package:flutter/material.dart';

class TaxiOutlineButton extends StatelessWidget {
  final String? title;
  final Function? onPressed;
  final Color? color;

  TaxiOutlineButton({this.title, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
       
       
        onPressed: () {
          onPressed!();
        },
        style:  ButtonStyle(
          shape: MaterialStateProperty.resolveWith((states) => RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),),
          side:MaterialStateBorderSide.resolveWith((states) => BorderSide(color: color!)),
           backgroundColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.focused))
          return color;
        return null; // Defer to the widget's default.
      }
    ),
  
        ),
        
      
        child: Container(
          height: 50.0,
          child: Center(
            child: Text(title!,
                style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Brand-Bold',
                    color: BrandColors.colorText)),
          ),
        ));
  }
}
