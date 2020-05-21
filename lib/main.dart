
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'pages/customer.dart';
import 'pages/employee.dart';
import 'pages/usermenu.dart';
import 'transition.dart';
import 'utils.dart';
import 'widget/button.dart';
import 'widget/textfieldpro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "C.U.P.S. Coffee",
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController email = TextEditingController();
  final TextEditingController fname = TextEditingController();

  final TextEditingController lname = TextEditingController();

  final TextEditingController password = TextEditingController();
  int chosen = 2;
  List<String> list = <String>["Employee", "Customer"];
  List<Column> columns = <Column>[];

  @override
  Widget build(BuildContext context) {
    columns.add(employeeCreate());
    columns.add(customerCreate());
    columns.add(loginColumn());
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
          border: null,
          leading: Material(
            color: Colors.white,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(createRoute(UserMenu([
                  makeListItem(Icons.person, 'Customer Create Account', () {
                    chosen = 1;
                    Navigator.pop(context);
                    setState(() {});
                  }),
                  makeListItem(Icons.person, 'Employee Create Account', () {
                    chosen = 0;

                    Navigator.pop(context);
                    setState(() {});
                  }),
                  makeListItem(Icons.person, 'Login', () {
                    chosen = 2;

                    Navigator.pop(context);
                    setState(() {});
                  }),
                ])));
              },
              icon: Icon(Icons.person_pin),
            ),
          ),
          middle:
              Text('C.U.P.S. Coffee', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white),
      body: Center(
        child: Column(
          children: <Widget>[
            Image.network(
                "https://firebasestorage.googleapis.com/v0/b/agriculture-system-be41f.appspot.com/o/CUPS%20LOGO.png?alt=media&token=c62ad202-d31d-40df-8476-cd50c8e5aa5e"),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            columns[chosen]
          ],
        ),
      ),
    );
  }

  Column employeeCreate() {
    return Column(
      children: <Widget>[
        new TextFieldPro(
            controller: email,
            label: "Email",
            hideText: false,
            type: TextInputType.emailAddress),
        new TextFieldPro(
            controller: password,
            hideText: true,
            label: "Password",
            type: TextInputType.visiblePassword),
        RoundedButtonWidget(
          buttonText: ("Create Account"),
          buttonColor: CupertinoColors.activeBlue,
          onPressed: () async {
            int response = await createUser(
                email: email.text, password: password.text, type: "Employee");
            if (response == 1) {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => Employee()));
            }
          },
        )
      ],
    );
  }

  Column loginColumn() {
    return Column(
      children: <Widget>[
        new TextFieldPro(
            controller: email,
            label: "Email",
            hideText: false,
            type: TextInputType.emailAddress),
        new TextFieldPro(
            controller: password,
            hideText: true,
            label: "Password",
            type: TextInputType.visiblePassword),
        RoundedButtonWidget(
          buttonText: ("Login"),
          buttonColor: CupertinoColors.activeBlue,
          onPressed: () async {
            int response = await login(email.text, password.text);

            if (response == 1) {
              FirebaseUser user = await FirebaseAuth.instance.currentUser();
              String type = '';
              await Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .get()
                  .then((value) => type = value.data['type']);
              if (type == list[1])
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => Customer()));
              if (type == list[0])
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => Employee()));
            }
          },
        ),
      ],
    );
  }

  Column customerCreate() {
    return Column(
      children: <Widget>[
        new TextFieldPro(
            controller: email,
            label: "Email",
            hideText: false,
            type: TextInputType.emailAddress),
        new TextFieldPro(
            controller: password,
            hideText: true,
            label: "Password",
            type: TextInputType.visiblePassword),
        new TextFieldPro(
            controller: fname,
            label: "First Name",
            hideText: false,
            type: TextInputType.text),
        new TextFieldPro(
          controller: lname,
          label: "Last Name",
          type: TextInputType.text,
          hideText: false,
        ),
        RoundedButtonWidget(
          buttonText: ("Create Account"),
          buttonColor: CupertinoColors.activeBlue,
          onPressed: () async {
            int response = await createCustomer(
                email: email.text,
                password: password.text,
                type: "Customer",
                fname: fname.text,
                lname: lname.text);
            if (response == 1) {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => Customer()));
            }
          },
        )
      ],
    );
  }

  Future<int> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return 1;
    } catch (e) {
      sendToast(e.toString());

      return 0;
    }
  }

  Future<int> createUser({String email, String password, String type}) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await Firestore.instance
          .collection('users')
          .document(result.user.uid)
          .setData({
        'type': type,
        'balance': 500,
      });
      result.user.sendEmailVerification();
      print("success");
      return 1;
    } catch (e) {
      sendToast(e.toString());
      return 0;
    }
  }

  Future<int> createCustomer(
      {String email,
      String password,
      String fname,
      String lname,
      String type}) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await Firestore.instance
          .collection('users')
          .document(result.user.uid)
          .setData({
        'type': type,
        'balance': 500,
        'fname': fname,
        'lname': lname,
      });
      result.user.sendEmailVerification();
      print("success");
      return 1;
    } catch (e) {
      sendToast(e.toString());
      return 0;
    }
  }

}
