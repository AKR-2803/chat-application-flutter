import 'package:flutter/material.dart';
import '../main.dart';

//used to listen to change in text theme and change UI accordingly
class TextTypeProvider with ChangeNotifier {
  TextTypeProvider({this.selectedTextType});
  //string the texttype in sharedprefs
  //roboto is the default fontFamily
  String? selectedTextType = sharedPrefs!.getString('textType') ?? "Roboto";
  String? get getselectedTextType => selectedTextType;

  void setTextType({String? setThisTextType}) {
    selectedTextType = setThisTextType;
    notifyListeners();
  }
}
