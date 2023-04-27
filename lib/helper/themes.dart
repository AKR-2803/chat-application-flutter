import 'package:chatapplication/main.dart';
import 'package:flutter/material.dart';

class Themes {
  // final providertext = Provider.of<TextTypeProvider>(context, listen: false);
  static AppBarTheme appBarTheme = AppBarTheme(
      // centerTitle: true,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 20,
        fontFamily: TextThemeClass.textType,
      ),
      backgroundColor: Colors.white);

  static TextTheme myTextTheme = const TextTheme(
    // bodySmall: TextStyle(fontSize: 20, color: Colors.black),
    bodySmall: TextStyle(fontSize: 17, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 20, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 30, color: Colors.black),
  );
}
