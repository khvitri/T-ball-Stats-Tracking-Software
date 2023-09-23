import 'package:cstballprogram/shared/constant.dart';
import 'package:flutter/material.dart';

class NonMtInputForm extends TextFormField {
  NonMtInputForm(
      {required Color? textColor,
      required String hintText,
      required String validationMsg,
      required TextEditingController controller,
      required bool isTextObscure})
      : super(
            style: TextStyle(color: textColor),
            decoration: textInputDecoration.copyWith(hintText: hintText),
            validator: (val) => val!.isEmpty ? validationMsg : null,
            controller: controller,
            obscureText: isTextObscure);
}
