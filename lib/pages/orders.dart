import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:server/widget/button.dart';

import '../transition.dart';
import 'usermenu.dart';

class Orders extends StatefulWidget {
  final String id;

  const Orders({this.id});
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final String page = "Your Orders";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CupertinoNavigationBar(
          border: null,
          middle: Text(page, style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("orders")
                .document(widget.id)
                .collection('orders')
                .snapshots(),
            builder: (context, snapshots) {
              if (snapshots.hasData)
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
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
                                String text = "Cancel Order";
                                if (snapshots
                                        .data.documents[index].data['status']
                                        .toString() ==
                                    'Completed') text = "Order Complete";
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
                                    snapshots
                                        .data.documents[index].data['picture'],
                                    height: MediaQuery.of(context).size.height *
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
                                  Material(
                                    child: Text(r'Quantity: ' +
                                        snapshots.data.documents[index]
                                            .data['quantity']
                                            .toString()),
                                  ),
                                  Material(
                                    child: Text(r'Status: ' +
                                        snapshots.data.documents[index]
                                            .data['status']
                                            .toString()),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RoundedButtonWidget(
                                        buttonColor: CupertinoColors.activeBlue,
                                        buttonText: text,
                                        onPressed: () {
                                          if (snapshots.data.documents[index]
                                                  .data['status'] ==
                                              'Order Placed')
                                            Firestore.instance.runTransaction(
                                                (transaction) async {
                                              transaction.delete(snapshots.data
                                                  .documents[index].reference);
                                            });
                                          Navigator.pop(context);
                                        },
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
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                        );
                      }),
                );
              return Center(
                child: CupertinoActivityIndicator(),
              );
            },
          ),
        ));
  }
}
