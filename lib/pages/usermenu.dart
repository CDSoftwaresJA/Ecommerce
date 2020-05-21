import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserMenu extends StatelessWidget {
  List<Widget> list;
  UserMenu(this.list);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Scaffold(
                backgroundColor: Colors.white,
              )),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list,
          ),
        )
      ],
    );
  }
}
