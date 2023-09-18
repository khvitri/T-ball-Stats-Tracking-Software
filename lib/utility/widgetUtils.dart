import 'package:cstballprogram/shared/constant.dart';
import 'package:flutter/material.dart';

class WidgetUtils {
  static Widget createInputForm(String hint, String validationMsg,
      TextEditingController controller, bool isTextObscure) {
    return TextFormField(
      style: TextStyle(color: Colors.amber),
      decoration: textInputDecoration.copyWith(hintText: hint),
      validator: (val) => val!.isEmpty ? validationMsg : null,
      controller: controller,
      obscureText: isTextObscure,
    );
  }
}
