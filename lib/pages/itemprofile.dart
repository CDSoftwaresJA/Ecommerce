import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:server/objects/item.dart';

class Menu extends StatelessWidget {
  Item item;
  Menu(this.item);

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
            children: <Widget>[
              Image.network(
                item.picture,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              makeListItem(Icons.close, 'Log out', () {}),
            ],
          ),
        )
      ],
    );
  }

  makeListItem(IconData iconData, String text, VoidCallback onTap) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Material(
          color: Colors.black,
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
}
