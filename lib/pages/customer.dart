import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:server/objects/item.dart';
import 'package:server/widget/button.dart';

import '../main.dart';
import '../transition.dart';
import '../utils.dart';
import 'cart.dart';
import 'orders.dart';
import 'search.dart';
import 'usermenu.dart';

class Customer extends StatefulWidget {
  @override
  CustomerState createState() => CustomerState();
}

class CustomerState extends State<Customer> {
  static List<Item> list = [];
  Widget middle =
      Text("C.U.P.S. Coffee Shop", style: TextStyle(color: Colors.black));
  int total = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        border: null,
        middle: middle,
        leading: Material(
          color: Colors.white,
          child: IconButton(
            onPressed: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => Search()));
            },
            icon: Icon(Icons.search),
          ),
        ),
        trailing: Material(
          color: Colors.white,
          child: IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () async {
              FirebaseUser user = await FirebaseAuth.instance.currentUser();
              String balance;
              String name;
              await Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .get()
                  .then((value) {
                balance = value.data['balance'].toString();
                name = value.data['fname'] + " " + value.data['lname'];
              });

              Navigator.of(context).push(createRoute(UserMenu([
                makeListItem(Icons.person, name, () {}),
                makeListItem(Icons.attach_money, 'Balance: $balance', () {}),
                makeListItem(Icons.shopping_cart, 'Checkout', () {
                  Navigator.pop(context);
                  Navigator.of(context).push(createRoute(Cart()));
                }),
                makeListItem(Icons.clear, 'Clear Cart', () {
                  list = [];
                }),
                makeListItem(Icons.attach_money, 'Your Orders', () async {
                  Navigator.pop(context);
                  Navigator.of(context).push(createRoute(Orders(
                      id: (await FirebaseAuth.instance.currentUser()).uid)));
                }),
                makeListItem(Icons.feedback, "Send Feedback", () async {
                  final Email email = Email(
                    body: '',
                    subject: 'Feedback - C. U. P. S. System',
                    recipients: ['cupssystemutech@gmail.com'],
                    isHTML: false,
                  );

                  await FlutterEmailSender.send(email);
                }),
                makeListItem(Icons.person_outline, 'Log out', () {
                  FirebaseAuth.instance.signOut();

                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      CupertinoPageRoute(builder: (context) => Home()));
                }),
              ])));
            },
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("inventory").snapshots(),
              builder: (context, snapshots) {
                if (snapshots.hasData)
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: ListView.builder(
                        itemCount: snapshots.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                                snapshots.data.documents[index].data['name']),
                            trailing: Material(
                              color: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  String text;
                                  VoidCallback onTap;
                                  int quantity = snapshots
                                      .data.documents[index].data['quantity'];

                                  if (quantity > 0) {
                                    text = "Add to Cart";
                                    onTap = () {
                                      list.add(
                                        Item(
                                            name: snapshots.data
                                                .documents[index].data['name'],
                                            cost: snapshots.data
                                                .documents[index].data['cost']
                                                .toDouble(),
                                            picture: snapshots
                                                .data
                                                .documents[index]
                                                .data['picture'],
                                            quantity: 1),
                                      );
                                      print(list.toString());
                                      Navigator.pop(context);
                                    };
                                  } else {
                                    text = "Out of Stock";
                                    onTap = () {};
                                  }
                                  Navigator.of(context)
                                      .push(createRoute(UserMenu([
                                    Material(
                                      child: Text(
                                        snapshots
                                            .data.documents[index].data['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Image.network(
                                      snapshots.data.documents[index]
                                          .data['picture'],
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                    ),
                                    Material(
                                      child: Text(
                                        r'Category: ' +
                                            snapshots.data.documents[index]
                                                .data['category']
                                                .toString(),
                                      ),
                                    ),
                                    Material(
                                      child: Text(
                                        r'Cost: $' +
                                            snapshots.data.documents[index]
                                                .data['cost']
                                                .toString(),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        RoundedButtonWidget(
                                          buttonColor:
                                              CupertinoColors.activeBlue,
                                          buttonText: text,
                                          onPressed: onTap,
                                        ),
                                      ],
                                    )
                                  ])));
                                },
                                icon: Icon(Icons.more_horiz),
                              ),
                            ),
                            leading: Image.network(
                              snapshots.data.documents[index].data['picture'],
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          );
                        }),
                  );
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
