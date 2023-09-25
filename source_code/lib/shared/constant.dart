import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const textInputDecoration = InputDecoration(
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

final bases = Container(
  height: 15,
  width: 15,
  color: Color(0xFFBDBDBD),
);

final lato = GoogleFonts.lato(textStyle: TextStyle());
