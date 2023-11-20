import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'brand_divider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  get kDrawerItemStyle => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      color: Colors.white,
      child: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              height: 160,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/user_icon.png',
                      height: 60,
                      width: 60,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Prashant',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('View Profile')
                      ],
                    )
                  ],
                ),
              ),
            ),
            BrandDivider(),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: Icon(OMIcons.cardGiftcard),
              title: Text(
                'Free Rides',
                style: kDrawerItemStyle,
              ),
            ),
            ListTile(
              leading: Icon(OMIcons.payment),
              title: Text(
                'Payments',
                style: kDrawerItemStyle,
              ),
            ),
            ListTile(
              leading: Icon(OMIcons.history),
              title: Text(
                'Ride History',
                style: kDrawerItemStyle,
              ),
            ),
            ListTile(
              leading: Icon(OMIcons.contactSupport),
              title: Text(
                'Support',
                style: kDrawerItemStyle,
              ),
            ),
            ListTile(
              leading: Icon(OMIcons.info),
              title: Text(
                'About',
                style: kDrawerItemStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
