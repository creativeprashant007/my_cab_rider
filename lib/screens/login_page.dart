import 'package:cab_rider/constants/brand_colors.dart';
import 'package:cab_rider/screens/main_page.dart';
import 'package:cab_rider/screens/regisration_page.dart';
import 'package:cab_rider/widgets/progress_dialog_cust.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scffoldkey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  void _loginUser(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return ProgressDialogCust(
            status: 'Logging you in...',
          );
        });
    final UserCredential user = await _auth
        .signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )
        .catchError((error) {
      Navigator.of(context).pop();
      FirebaseAuthException thisEx = error;
      showSnackBar(
        thisEx.message.toString(),
      );
    });
    if (user.user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child(
            'users/${user.user!.uid}',
          );
      userRef.once().then((DatabaseEvent snapshot) {
        if (snapshot.snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainPage.id, (route) => false);
        }
      });
    }
  }

  void showSnackBar(String title) {
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
                  'Sign In as Rider',
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
                        controller: _emailController,
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
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar(
                              'No Internet connection',
                            );
                            return;
                          }

                          if (!_emailController.text.contains('@')) {
                            showSnackBar(
                              'invalid email address',
                            );
                            return;
                          }
                          if (_passwordController.text.length < 6) {
                            showSnackBar(
                              'Password at least 6 character',
                            );
                            return;
                          }
                          _loginUser(context);
                        },
                        color: BrandColors.colorGreen,
                        title: 'LOGIN',
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              RegistrationPage.id, (route) => false);
                        },
                        child: Text(
                          'Don\'t have an account, Sign up here',
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
