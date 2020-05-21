
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:server/objects/item.dart';
import 'package:server/widget/button.dart';

import '../transition.dart';
import 'customer.dart';
import 'usermenu.dart';

class Cart extends StatefulWidget {
  Cart();

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final String page = "Cart";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        border: null,
        middle: Text(page, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        trailing: Material(
          color: Colors.white,
          child: IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: () {
              double total = 0;
              for (Item item in CustomerState.list) total += item.cost;
              Navigator.of(context).push(createRoute(UserMenu([
                Material(child: Text("Total: $total ")),
                RoundedButtonWidget(
                  buttonColor: CupertinoColors.activeBlue,
                  buttonText: "Confirm Purchase",
                  onPressed: () async {
                    FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();
                    Firestore.instance
                        .collection('orders')
                        .document(user.uid)
                        .setData({"Test": "Test"});
                    for (Item item in CustomerState.list)
                      Firestore.instance
                          .collection('orders')
                          .document(user.uid)
                          .collection('orders')
                          .add({
                        'name': item.name,
                        'quantity': 1,
                        'cost': item.cost,
                        'status': 'Order Placed',
                        'picture': item.picture
                      });
                    CustomerState.list = [];
                    Navigator.pop(context);
                    setState(() {});
                  },
                )
              ])));
              ;
            },
          ),
        ),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: CustomerState.list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(CustomerState.list[index].name),
                  leading: Image.network(
                    CustomerState.list[index].picture,
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  onTap: () {
                    CustomerState.list.remove(CustomerState.list[index]);
                    setState(() {});
                  },
                );
              })),
    );
  }
}
