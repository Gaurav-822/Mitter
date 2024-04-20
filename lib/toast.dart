import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Just for testing Okay
void showToastMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.transparent,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
