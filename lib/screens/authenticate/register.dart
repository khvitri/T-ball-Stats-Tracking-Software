import 'package:cstballprogram/screens/authenticate/authenticate.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:cstballprogram/utility/widgetUtils.dart';
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Loading();
    }
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          teacher ? 'Teacher Register to Swing' : 'Student Register to Swing',
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                WidgetUtils.createInputForm(
                    "Email", "Enter an email", emailController, false),
                SizedBox(height: 20),
                WidgetUtils.createInputForm(
                    "Password",
                    "Password should be 8+ characters long",
                    passwordController,
                    true),
                SizedBox(
                  height: 20,
                ),
                WidgetUtils.createInputForm(
                    "Full Name", "Enter a Full Name", nameController, false),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber,
                    fixedSize: Size(300, 30),
                  ),
                  onPressed: validateRegister,
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
      ),
    );
  }

  void validateRegister() async {
    if (_formkey.currentState!.validate()) {
      setState(() => loading = true);
      dynamic result = await _cAuth.registerEmailAndPassword(
          nameController.text, emailController.text, passwordController.text);
      if (result == null) {
        setState(() {
          error = 'Invalid email';
          loading = false;
        });
      } else {
        setState(() => Navigator.pop(context));
      }
    }
  }
}
