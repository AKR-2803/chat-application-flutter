import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double opacityLevelIcon = 0.0;

  @override
  void initState() {
    super.initState();

    //changing the opacity level of the icon using future.delayed
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        opacityLevelIcon = opacityLevelIcon == 0.0
            ? opacityLevelIcon = 1.0
            : opacityLevelIcon = 0.0;
      });
    });
  }
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  _handleGoogleButtonClick() {
    //showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      //hiding progress bar after the firebase dialog pops up
      Navigator.pop(context);
      //log is also used for mathematics imported from 'dart:math'
      //for message log purpose import from 'dart:developer'
      if (user != null) {
        print("\nUser(_signInWithGoogle()) =============> ${user.user}");
        print("\nAdditional Info =============> ${user.additionalUserInfo}");

        //if user already exists navigate to home screen
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
        //if user is new, first create user and then navigate to home screen
        else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        }
      }
    });
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  //sign in with google function
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // We need to ensure that user is connected to internet
      //Just checking any website to know the internect connectivity status
      await InternetAddress.lookup("google.com");

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log("\n===>Error occured in _signInWithGoogle(): ${e.toString()}");
      Dialogs.showSnackBar(
          context,
          "Something went wrong. Please ensure you have internet connectivity",
          Duration(milliseconds: 1500));
      return null;
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  //signOut function
  // _signOut() async {
  //   await APIs.auth.signOut();
  //   await GoogleSignIn().signOut();
  // }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    ThemeData appTextThemeData = Theme.of(context);
    //using MediaQuery to get device height, width
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          //giving leading space to [title]
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("Welcome to ChatApp")),
      body: Stack(children: [
        //to animate the app icon
        Positioned(
          top: deviceHeight * 0.10,
          right: deviceWidth * 0.25,
          width: deviceWidth * 0.5,
          child: AnimatedOpacity(
              opacity: opacityLevelIcon,
              duration: const Duration(seconds: 1),
              child: Image.asset('assets/images/appicon.png')),
        ),
        Positioned(
          top: deviceHeight * 0.35,
          left: deviceWidth * 0.30,
          child: AnimatedOpacity(
            opacity: opacityLevelIcon,
            duration: const Duration(seconds: 1),
            child: Text(
              "Welcome!",
              style: appTextThemeData.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        //AnimatedPositioned animates the transition in positions of the widget
        //one can change the postion of the widget by using a bool value
        //like isAnimate and use setState to toggle the bool value
        //define the postion according to the bool value using ternary operator
        Positioned(
          bottom: deviceHeight * 0.30,
          // left: deviceWidth * 0.2,
          right: deviceWidth * 0.2,
          child: Text("Please Sign in to continue",
              style: appTextThemeData.textTheme.bodySmall,
              textAlign: TextAlign.start),
        ),

        Positioned(
            bottom: deviceHeight * 0.15,
            left: deviceWidth * 0.1,
            width: deviceWidth * 0.8,
            height: deviceHeight * 0.07,
            child: ElevatedButton.icon(
                //google sign in o  n click
                onPressed: () {
                  _handleGoogleButtonClick();
                  // Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                icon: Image.asset('assets/images/googleicon.png',
                    height: deviceHeight * 0.04),
                label: RichText(
                  text: TextSpan(
                      style: appTextThemeData.textTheme.bodySmall,
                      children: [
                        const TextSpan(text: "Sign In with "),
                        TextSpan(
                            text: "Google",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.bold))
                      ]),
                ),
                style: ElevatedButton.styleFrom(
                    shape:
                        const StadiumBorder(side: BorderSide(strokeAlign: 1)),
                    backgroundColor: const Color(0xFFDFD3FF))))
      ]),
    );
  }
}

//AnimatedOpacity animates the change in opacity level of widgets
//implementing similar to AnimatedPositioned
/*

          double opacityLevelGoogle = 0.0;
  bool isAnimateGoogle = false;

    Future.delayed(Duration(milliseconds: 1400), () {
      opacityLevelGoogle = opacityLevelGoogle == 0.0
          ? opacityLevelGoogle = 1.0
          : opacityLevelGoogle = 0.0;
      isAnimateGoogle = true;
    });



        AnimatedOpacity(
          opacity: opacityLevelGoogle,
          duration: Duration(seconds: 2),
          child: Positioned(
            bottom: deviceHeight * 0.15,
            left: deviceWidth * 0.1,
            width: deviceWidth * 0.8,
            height: deviceHeight * 0.07,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Image.asset('assets/images/googleicon.png',
                  height: deviceHeight * 0.04),
              label: RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 17),
                    children: [
                      TextSpan(text: "Sign In with "),
                      TextSpan(
                          text: "Google",
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
              ),
              style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(side: BorderSide(strokeAlign: 1)),
                  backgroundColor: Color.fromARGB(255, 223, 211, 255)),
            ),
          ),
        )
        */
