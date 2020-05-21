import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:server/widget/button.dart';

import '../transition.dart';
import 'usermenu.dart';

class EmployeesOrders extends StatefulWidget {
  @override
  _EmployeesOrdersState createState() => _EmployeesOrdersState();
}

class _EmployeesOrdersState extends State<EmployeesOrders> {
  final String page = "All Orders";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
          border: null,
          middle: Text(page, style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("orders").snapshots(),
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                return Container(
                  child: ListView.builder(
                      itemCount: snapshots.data.documents.length,
                      itemBuilder: (BuildContext context, int orderIndex) {
                        return ListTile(
                          title: Text(
                              snapshots.data.documents[orderIndex].documentID),
                          onTap: () {
                            Navigator.of(context).push(createRoute(UserMenu([
                              StreamBuilder<QuerySnapshot>(
                                stream: Firestore.instance
                                    .collection('orders')
                                    .document(snapshots
                                        .data.documents[orderIndex].documentID)
                                    .collection('orders')
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> items) {
                                  if (items.hasData) {
                                    return Column(
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          color: Colors.white,
                                          child: ListView.builder(
                                              itemCount:
                                                  items.data.documents.length,
                                              itemBuilder: (context, index) {
                                                return Material(
                                                  child: ListTile(
                                                    leading: Image.network(
                                                      items
                                                          .data
                                                          .documents[index]
                                                          .data['picture'],
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                    ),
                                                    title: Text(items
                                                        .data
                                                        .documents[index]
                                                        .data['name']),
                                                    trailing:
                                                        RoundedButtonWidget(
                                                      buttonColor:
                                                          CupertinoColors
                                                              .activeBlue,
                                                      onPressed: () {
                                                        print(index);
                                                        if (items
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data[
                                                                'status'] !=
                                                            "Completed") {
                                                          Firestore.instance
                                                              .collection(
                                                                  'users')
                                                              .document(snapshots
                                                                  .data
                                                                  .documents[
                                                                      orderIndex]
                                                                  .documentID)
                                                              .updateData({
                                                            "balance": FieldValue
                                                                .increment(-items
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .data['cost'])
                                                          });
                                                          Firestore.instance
                                                              .collection(
                                                                  'inventory')
                                                              .where('name',
                                                                  isEqualTo: items
                                                                          .data
                                                                          .documents[
                                                                              index]
                                                                          .data[
                                                                      'name'])
                                                              .getDocuments()
                                                              .then((value) =>
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          'inventory')
                                                                      .document(value
                                                                          .documents[
                                                                              0]
                                                                          .documentID)
                                                                      .updateData({
                                                                    "quantity":
                                                                        FieldValue.increment(
                                                                            -1),
                                                                    "sales": FieldValue
                                                                        .increment(
                                                                            1)
                                                                  }));

                                                          Firestore.instance
                                                              .runTransaction(
                                                                  (transaction) async {
                                                            transaction.set(
                                                                items
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .reference,
                                                                {
                                                                  'name': items
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data['name'],
                                                                  'cost': items
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data['cost'],
                                                                  'picture': items
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data['picture'],
                                                                  'quantity': items
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data['quantity'],
                                                                  "status":
                                                                      "Completed",
                                                                });
                                                          });
                                                        }
                                                      },
                                                      buttonText: items
                                                          .data
                                                          .documents[index]
                                                          .data['status'],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        RoundedButtonWidget(
                                          buttonText: "Delete Order",
                                          onPressed: () {
                                            Firestore.instance.runTransaction(
                                                (transaction) async {
                                              transaction.delete(snapshots
                                                  .data
                                                  .documents[orderIndex]
                                                  .reference);
                                            });

                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  }
                                  return Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              )
                            ])));
                          },
                        );
                      }),
                );
              }
              return Center(
                child: CupertinoActivityIndicator(),
              );
            },
          ),
        ));
  }
}
