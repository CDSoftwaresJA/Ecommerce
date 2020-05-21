import 'package:flutter/material.dart';

class TextFieldPro extends StatelessWidget {
  final label;
  final TextEditingController controller;
  final TextInputType type;
  final Function(String) submit;
  bool hideText = false;

  TextFieldPro(
      {@required this.label,
      @required this.controller,
      @required this.type,
      this.submit,
      this.hideText});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          width: 350,
          child: TextFormField(
            controller: controller,
            onFieldSubmitted: submit,
            obscureText: hideText,
            decoration: new InputDecoration(
              labelText: label,
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(50.0),
                borderSide: new BorderSide(),
              ),
            ),
            keyboardType: type,
            style: new TextStyle(
              fontFamily: "Poppins",
            ),
          ),
        ),
      ),
    );
  }
}
