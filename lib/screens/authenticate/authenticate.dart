import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool teacher = false;

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10.0),
            SafeArea(
              child: Container(
                child: Text(
                  'Swing',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: Colors.amber,
                      fontSize: 50,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 200.0),
            Container(
              height: 50,
              width: 300,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.amber),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/sign_in');
                  });
                },
                child: Text(
                  "Sign In",
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 50,
              width: 300,
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.amber))),
                ),
                onPressed: () {
                  setState(() {
                    teacher = false;
                    Navigator.pushNamed(context, '/register');
                  });
                },
                child: Text(
                  "Register as Student",
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                    color: Colors.amber,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 50,
              width: 300,
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.amber))),
                ),
                onPressed: () {
                  setState(() {
                    teacher = true;
                    Navigator.pushNamed(context, '/register');
                  });
                },
                child: Text(
                  "Register as Teacher",
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                    color: Colors.amber,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
