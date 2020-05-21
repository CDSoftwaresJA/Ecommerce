import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:server/objects/item.dart';
import 'package:server/widget/button.dart';
import 'package:server/widget/textfieldpro.dart';

import '../transition.dart';
import 'customer.dart';
import 'usermenu.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchText = '';
  TextEditingController search = TextEditingController();
  StreamController<DocumentSnapshot> controller =
      StreamController<DocumentSnapshot>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        border: null,
        middle: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextFieldPro(
                controller: search,
                label: "Search",
                hideText: false,
                type: TextInputType.text,
              ),
            ),
            IconButton(
              onPressed: () {
                searchText = search.text;
                setState(() {});
              },
              icon: Icon(Icons.search),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('inventory')
                  .where("name", isEqualTo: searchText)
                  .snapshots(),
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
                                      CustomerState.list.add(
                                        Item(
                                            name: snapshots.data
                                                .documents[index].data['name'],
                                            cost: double.parse(snapshots.data
                                                .documents[index].data['cost']),
                                            picture: snapshots
                                                .data
                                                .documents[index]
                                                .data['picture'],
                                            quantity: 1),
                                      );
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

  Stream<DocumentSnapshot> findItem(String search) {
    Firestore.instance
        .collection('inventory')
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              RegExp regExp = new RegExp(
                "$search",
                caseSensitive: false,
              );
              print(regExp.hasMatch(element.data.toString()));
              if (regExp.hasMatch(element.data.toString()) == true) {
                print(element.data.toString());
                controller.add(element);
              }
            }));
    return controller.stream;
  }
}
