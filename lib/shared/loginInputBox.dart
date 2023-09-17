import 'package:flutter/material.dart';

class LoginInputBox extends StatelessWidget {
  late String hintText;

  LoginInputBox(String hintText) {
    this.hintText = hintText;
  }

  @override
  Widget build(BuildContext context) {
    return InputDecoration(
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF212121), width: 2.0),
      ),
      focusedErrorBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      errorStyle: TextStyle(fontSize: 10, height: 1),
      hintStyle: TextStyle(
        color: Color(0xFFBDBDBD),
      ),
      fillColor: Colors.transparent,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF212121), width: 2.0),
      ),
    );
  }
}
