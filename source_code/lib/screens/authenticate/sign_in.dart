import 'package:cstballprogram/customWidgets/NonMtInputForm.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/loading.dart';
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
          appBar: _signInAppBar(),
          body: _signInForm());
    }
  }

  // returns the login form of the sign in page
  Widget _signInForm() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            SizedBox(height: 20),
            NonMtInputForm(
                textColor: Colors.amber,
                hintText: "Email",
                validationMsg: "Enter an email",
                controller: emailController,
                isTextObscure: false),
            SizedBox(height: 20),
            NonMtInputForm(
                textColor: Colors.amber,
                hintText: "Password",
                validationMsg: "Enter a password",
                controller: passwordController,
                isTextObscure: true),
            SizedBox(height: 20),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              onPressed: _validateSignIn,
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
    );
  }

  // returns the app bar of the sign in page
  PreferredSizeWidget _signInAppBar() {
    return AppBar(
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
    );
  }

  // validates the sign in information of the user
  void _validateSignIn() async {
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
