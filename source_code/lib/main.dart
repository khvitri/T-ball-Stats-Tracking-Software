import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/authenticate/register.dart';
import 'package:cstballprogram/screens/authenticate/sign_in.dart';
import 'package:cstballprogram/Redirect.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamProvider<cUser?>.value(
          initialData: null,
          value: AuthService().loginstatus, // stream you want to listen to
          child: Wrapper()),
      routes: {
        '/sign_in': (context) => SignIn(),
        '/register': (context) => Register(),
      },
    );
  }
}
