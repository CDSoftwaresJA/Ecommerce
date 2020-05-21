import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:server/widget/button.dart';
import 'package:server/widget/textfieldpro.dart';

import '../main.dart';
import '../transition.dart';
import '../utils.dart';
import 'employeeorders.dart';
import 'usermenu.dart';

class Employee extends StatefulWidget {
  @override
  _EmployeeState createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  final String page = "Product Entry";

  final TextEditingController name = TextEditingController();

  final TextEditingController cost = TextEditingController();

  final TextEditingController picture = TextEditingController();

  final TextEditingController category = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        border: null,
        middle: Text(page, style: TextStyle(color: Colors.black)),
        trailing: Material(
          color: Colors.white,
          child: IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () async {
              FirebaseUser user = await FirebaseAuth.instance.currentUser();
              Navigator.of(context).push(createRoute(UserMenu([
                StreamBuilder<QuerySnapshot>(
                  stream:
                      Firestore.instance.collection('inventory').snapshots(),
                  builder: (context, items) {
                    if (items.hasData) {
                      int x = 0;
                      List<BarChartGroupData> groups =
                          List<BarChartGroupData>();
                      for (DocumentSnapshot item in items.data.documents) {
                        groups.add(
                          BarChartGroupData(x: x, barRods: [
                            BarChartRodData(
                                y: item.data['sales'].toDouble(),
                                color: Colors.lightBlueAccent)
                          ], showingTooltipIndicators: [
                            0
                          ]),
                        );
                        x++;
                      }

                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.transparent,
                              tooltipPadding: const EdgeInsets.all(0),
                              tooltipBottomMargin:
                                  items.data.documents.length.toDouble(),
                              getTooltipItem: (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                return BarTooltipItem(
                                  rod.y.round().toString(),
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                              showTitles: true,
                              textStyle: TextStyle(
                                  color: const Color(0xff7589a2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                              margin: 20,
                              getTitles: (double value) {
                                return items.data.documents[value.toInt()]
                                    ['name'];
                              },
                            ),
                            leftTitles: SideTitles(showTitles: false),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: groups,
                        ),
                      );
                    }
                    return CupertinoActivityIndicator();
                  },
                ),
                makeListItem(Icons.person, user.email, () {}),
                makeListItem(Icons.query_builder, 'Orders', () {
                  Navigator.pop(context);
                  Navigator.of(context).push(createRoute(EmployeesOrders()));
                }),
                makeListItem(Icons.close, 'Log out', () {
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
      body: Column(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("inventory").snapshots(),
            builder: (context, snapshots) {
              if (snapshots.hasData)
                return Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                      itemCount: snapshots.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                              snapshots.data.documents[index].data['name']),
                          trailing: Material(
                            color: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.more_horiz),
                              onPressed: () {
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
                                    child: Text(
                                      r'ID: $' +
                                          snapshots
                                              .data.documents[index].documentID
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
                                    child: Text(r'Sales: ' +
                                        snapshots
                                            .data.documents[index].data['sales']
                                            .toString()),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Material(
                                        color: Colors.white,
                                        child: IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            Firestore.instance
                                                .collection('inventory')
                                                .where('name',
                                                    isEqualTo: snapshots
                                                        .data
                                                        .documents[index]
                                                        .data['name'])
                                                .getDocuments()
                                                .then((value) => Firestore
                                                        .instance
                                                        .collection('inventory')
                                                        .document(value
                                                            .documents[0]
                                                            .documentID)
                                                        .updateData({
                                                      "quantity":
                                                          FieldValue.increment(
                                                              1)
                                                    }));

                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      Material(
                                        color: Colors.white,
                                        child: IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            Firestore.instance
                                                .collection('inventory')
                                                .where('name',
                                                    isEqualTo: snapshots
                                                        .data
                                                        .documents[index]
                                                        .data['name'])
                                                .getDocuments()
                                                .then((value) => Firestore
                                                        .instance
                                                        .collection('inventory')
                                                        .document(value
                                                            .documents[0]
                                                            .documentID)
                                                        .updateData({
                                                      "quantity":
                                                          FieldValue.increment(
                                                              -1)
                                                    }));

                                            Navigator.pop(context);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  RoundedButtonWidget(
                                    buttonColor: CupertinoColors.activeBlue,
                                    buttonText: "Remove Item",
                                    onPressed: () {
                                      Firestore.instance
                                          .runTransaction((transaction) async {
                                        transaction.delete(snapshots
                                            .data.documents[index].reference);
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  RoundedButtonWidget(
                                      buttonColor: CupertinoColors.activeBlue,
                                      buttonText: "Change Cost",
                                      onPressed: () {
                                        TextEditingController controller =
                                            TextEditingController();
                                        Navigator.of(context)
                                            .push(createRoute(UserMenu([
                                          TextFieldPro(
                                            controller: controller,
                                            label: "New Cost",
                                            type: TextInputType.number,
                                            hideText: false,
                                          ),
                                          RoundedButtonWidget(
                                            buttonText: "Change Cost",
                                            onPressed: () {
                                              Firestore.instance
                                                  .collection('inventory')
                                                  .document(snapshots
                                                      .data
                                                      .documents[index]
                                                      .documentID)
                                                  .setData({
                                                'cost':
                                                    int.parse(controller.text)
                                              }, merge: true);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ])));
                                      })
                                ])));
                              },
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
          TextFieldPro(
            controller: name,
            hideText: false,
            label: "Name",
            type: TextInputType.text,
          ),
          TextFieldPro(
            controller: category,
            hideText: false,
            label: "Category",
            type: TextInputType.text,
          ),
          TextFieldPro(
            controller: cost,
            label: "Cost",
            hideText: false,
            type: TextInputType.number,
          ),
          TextFieldPro(
            controller: picture,
            hideText: false,
            label: "Picture(Link)",
            type: TextInputType.text,
          ),
          RoundedButtonWidget(
            onPressed: () {
              Firestore.instance.collection('inventory').add({
                'name': name.text,
                'quantity': 0,
                'cost': cost.text,
                'picture': picture.text,
                'sales': 0,
                'category': category.text,
              });
            },
            buttonText: ("Add Item"),
            buttonColor: CupertinoColors.activeBlue,
          ),
        ],
      ),
    );
  }
}
