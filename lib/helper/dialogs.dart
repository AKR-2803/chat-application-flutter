import 'package:flutter/material.dart';

class Dialogs {
  //static ensures that there's no need for
  //class object to access its methods or variables
  //they are created only once

  static void showSnackBar(
      BuildContext context, String msg, Duration passDuration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: passDuration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF7700C6),
      //Text Copied snackbar(in message_card bottomsheet) color : const Color(0xFFA841FC)
    ));
  }

  static void showErrorSnackBar(
      BuildContext context, String msg, Duration passDuration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: passDuration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color.fromARGB(255, 189, 0, 95),
      //Text Copied snackbar(in message_card bottomsheet) color : const Color(0xFFA841FC)
    ));
  }

  //static CircularProgressIndicator
  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
