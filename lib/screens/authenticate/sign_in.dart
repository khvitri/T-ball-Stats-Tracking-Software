import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:cstballprogram/utility/widgetUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Server side authentication service
  final AuthService _cAuth = AuthService();

  // Form variables for input validation
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Loading();
    } else {
      return Scaffold(
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
                WidgetUtils.createInputForm(
                    "Email", "Enter an email", emailController, false),
                SizedBox(height: 20),
                WidgetUtils.createInputForm(
                    "Password", "Enter a password", passwordController, true),
                SizedBox(height: 20),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  onPressed: validateSignIn,
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

  void validateSignIn() async {
    if (_formkey.currentState!.validate()) {
      setState(() => loading = true);

      dynamic result = await _cAuth.signInEmailAndPassword(
          emailController.text, passwordController.text);

      if (result == null) {
        setState(() {
          error = 'Could not Sign In';
          loading = false;
        });
      } else {
        setState(() => Navigator.pop(context));
      }
    }
  }
}
