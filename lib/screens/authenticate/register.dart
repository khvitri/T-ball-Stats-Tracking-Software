import 'package:cstballprogram/screens/authenticate/authenticate.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool loading = false;
  String error = '';
  final AuthService _cAuth = AuthService();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';
    String name = '';

    return loading == true
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.grey[800],
            appBar: AppBar(
              backgroundColor: Colors.grey[900],
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                teacher
                    ? 'Teacher Register to Swing'
                    : 'Student Register to Swing',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                )),
              ),
            ),
            body: Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextFormField(
                      style: TextStyle(color: Colors.amber),
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        email = val;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      style: TextStyle(color: Colors.amber),
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      validator: (val) => val!.length < 8
                          ? 'Enter a password 8+ characters long'
                          : null,
                      obscureText: true,
                      onChanged: (val) {
                        password = val;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.amber),
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Full Name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter a Full Name' : null,
                      onChanged: (val) {
                        name = val;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.amber,
                        fixedSize: Size(300, 30),
                      ),
                      onPressed: () async {
                        //if it returns null from both validators, it will proceed as true
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          dynamic result = await _cAuth
                              .registerEmailAndPassword(name, email, password);
                          if (result == null) {
                            setState(() {
                              error = 'Invalid email';
                              loading = false;
                            });
                            //unable to catch error in email format
                          } else {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }
                        }
                      },
                      child: Text(
                        teacher ? 'Register as Teacher' : 'Register as Student',
                        style: TextStyle(color: Colors.grey[900]),
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
