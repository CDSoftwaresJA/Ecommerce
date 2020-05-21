import 'package:flutter/material.dart';

class RoundedButtonWidget extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onPressed;

  const RoundedButtonWidget({
    Key key,
    this.buttonText,
    this.buttonColor,
    this.textColor = Colors.white,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.amber[800],
      shape: StadiumBorder(),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: Text(
          buttonText,
          style: Theme.of(context).textTheme.button.copyWith(color: textColor),
        ),
      ),
    );
  }
}
