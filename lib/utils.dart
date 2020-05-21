import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

sendToast(String title) {
  Fluttertoast.showToast(
      msg: title,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.amber[800],
      textColor: Colors.white,
      fontSize: 16.0);
}

makeListItem(IconData iconData, String text, VoidCallback onTap) {
  return Column(
    children: <Widget>[
      SizedBox(
        height: 20,
      ),
      Material(
        color: Colors.white,
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData),
              Text(
                text,
              )
            ],
          ),
          onTap: onTap,
        ),
      )
    ],
  );
}
