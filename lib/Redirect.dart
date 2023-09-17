import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/authenticate/authenticate.dart';
import 'package:cstballprogram/screens/student/home/StudentHome.dart';
import 'package:cstballprogram/screens/teacher/home/TeacherHome.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userloginuid = Provider.of<cUser?>(context);

    //return either home or authenticate
    if (userloginuid == null) {
      return Authenticate();
    } else {
      return StreamBuilder<UserRole?>(
          stream: DatabaseService(uid: userloginuid.uid.toString()).userrole,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            }
            if (snapshot.data?.teacher == true) {
              return Home();
            }
            if (snapshot.data?.teacher == false) {
              return SHome();
            }
            return Loading();
          });
    }
  }
}
