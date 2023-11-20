import 'package:cab_rider/constants/brand_colors.dart';
import 'package:flutter/material.dart';

class TexiButton extends StatelessWidget {
  final VoidCallback callback;
  final String title;
  final Color color;
  const TexiButton(
      {Key? key,
      required this.callback,
      required this.title,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) => color),
          shape: MaterialStateProperty.resolveWith(
              (states) => RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ))),
      child: Container(
        height: 50.0,
        child: Center(
          child: Text(
            '$title',
            style: TextStyle(
                fontSize: 18.0, fontFamily: 'Brand-Bold', color: Colors.white),
          ),
        ),
      ),
      onPressed: callback,
    );
  }
}
