import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _cAuth = AuthService();
  final _formkey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';
    return loading == true
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.grey[800],
            appBar: AppBar(
              backgroundColor: Colors.grey[900],
              elevation: 0.0,
              title: Text(
                'Sign in to Swing',
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                )),
              ),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formkey,
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
                      validator: (val) =>
                          val!.isEmpty ? 'Enter a password' : null,
                      obscureText: true,
                      onChanged: (val) {
                        password = val;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          dynamic result = await _cAuth.signInEmailAndPassword(
                              email, password);
                          if (result == null) {
                            setState(() {
                              error = 'Could not Sign In';
                              loading = false;
                            });
                          } else {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }
                        }
                      },
                      child: Text(
                        'Sign in',
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
