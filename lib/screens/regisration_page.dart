import 'package:cab_rider/constants/brand_colors.dart';
import 'package:cab_rider/screens/login_page.dart';
import 'package:cab_rider/screens/main_page.dart';
import 'package:cab_rider/widgets/progress_dialog_cust.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatelessWidget {
  static const String id = 'register';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scffoldkey = GlobalKey<ScaffoldState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailControllerController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _registerUser(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ProgressDialogCust(
            status: 'Registering you...',
          );
        });
    final UserCredential user = await _auth
        .createUserWithEmailAndPassword(
      email: _emailControllerController.text,
      password: _passwordController.text,
    )
        .catchError((error) {
      Navigator.of(context).pop();
      PlatformException thisEx = error;
      showSnackBar(thisEx.message.toString(), context);
    });
    if (user.user != null) {
      DatabaseReference newUserRef =
          FirebaseDatabase.instance.reference().child(
                'users/${user.user!.uid}',
              );
      Map userMap = {
        'fullname': _fullNameController.text,
        'email': _emailControllerController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
      };

      newUserRef.set(userMap);
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }
  }

  void showSnackBar(String title, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15.0),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scffoldkey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              ///  mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                ),
                Image(
                  alignment: Alignment.center,
                  image: AssetImage('assets/images/logo.png'),
                  height: 100.0,
                  width: 100.0,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Create a Rider\'s Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Brand-Bold',
                    fontSize: 25,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        controller: _emailControllerController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TexiButton(
                        callback: () async {
                          //check network avaibaliy

                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No Internet connection', context);
                            return;
                          }
                          if (_fullNameController.text.length < 3) {
                            showSnackBar(
                                'Full name must be more than three character',
                                context);
                            return;
                          }
                          if (_phoneController.text.length < 10) {
                            showSnackBar('Phone must be 10 digit', context);
                            return;
                          }

                          if (!_emailControllerController.text.contains('@')) {
                            showSnackBar('invalid email address', context);
                            return;
                          }
                          if (_passwordController.text.length < 6) {
                            showSnackBar(
                                'Password at least 6 character', context);
                            return;
                          }
                          _registerUser(context);
                        },
                        color: BrandColors.colorGreen,
                        title: 'REGISTER',
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              LoginPage.id, (route) => false);
                        },
                        child: Text(
                          'Already have an account? Login  here',
                          style: TextStyle(fontSize: 15.0),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
