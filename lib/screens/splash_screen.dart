import 'package:flutter/material.dart';
import 'dart:developer';
import '../main.dart';
import '../api/apis.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("\n\nInside the splash screen initState................");

    Future.delayed(const Duration(milliseconds: 1500), () {
      //before going to home page we need to return to the normal system UI mode
      //i.e., exit the full screen mode
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      print("\n\nInside the splash screen Future................");

      //set colors of upper status bar, or bottom navogation bar, etc using SystemChrome
      /*
      // SystemChrome.setSystemUIOverlayStyle(
      //   SystemUiOverlayStyle(
      //statusBarColor is the color of the bar displaying percentage in the device
      //     statusBarColor: Colors.cyanAccent,
      //     systemNavigationBarColor: Colors.purple.shade200,
      //     systemNavigationBarDividerColor: Colors.lightGreenAccent.shade700,
      //     statusBarBrightness: Brightness.dark,
      //   ),
      // );
        */

      //Navigate to home page if user is already logged in
      if (APIs.auth.currentUser != null) {
        log("\nUser(alreadyLoggedIn) =============> ${APIs.auth.currentUser}");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
      //Navigate to login screen if user is signed out
      else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
      print("\n\nFuture.delayed over...............");
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        "\n\n\n==============>Inside build method of splash screen<==============");
    mq = MediaQuery.of(context).size;
    ThemeData appTextThemeData = Theme.of(context);
    //using MediaQuery to get device height, width

    return Scaffold(
      body: Stack(children: [
        //to animate the app icon
        Positioned(
          top: mq.height * 0.10,
          right: mq.width * 0.25,
          width: mq.width * 0.5,
          child: Image.asset('assets/images/appicon.png'),
        ),
        // Positioned(
        //   top: mq.height * 0.35,
        //   left: mq.width * 0.30,
        //   child: Text(
        //     "Welcome!",
        //     style: appTextThemeData.textTheme.bodyLarge,
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        Positioned(
          bottom: mq.height * 0.2,
          left: mq.width * 0.45,
          //can put your custom logo here
          //later if needed
          child: Text("From\nAKR⭐",
              style: appTextThemeData.textTheme.bodySmall!
                  .copyWith(letterSpacing: 0.5),
              textAlign: TextAlign.center),
        ),
      ]),
    );
  }
}
