import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/teacher/edit/EditFeedback.dart';
import 'package:cstballprogram/screens/teacher/edit/EditInputData.dart';
import 'package:cstballprogram/screens/teacher/input/InputFeedback.dart';
import 'package:cstballprogram/screens/teacher/input/InputData.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:cstballprogram/shared/stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewStudentStat extends StatefulWidget {
  String? studentname;
  String? studentid;
  ViewStudentStat({this.studentname, this.studentid});
  @override
  _ViewStudentStatState createState() => _ViewStudentStatState();
}

class _ViewStudentStatState extends State<ViewStudentStat> {
  String? page = '';

  @override
  Widget build(BuildContext context) {
    if (widget.studentname == null || widget.studentid == null) {
      return Loading();
    }
    return StreamProvider<StudentData?>.value(
      value: DatabaseService(uid: widget.studentid).studentdata,
      catchError: (context, error) => null,
      initialData: null,
      child: Scaffold(
        backgroundColor: Colors.grey[400],
        appBar: AppBar(
          title: Text('${widget.studentname}'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                dropdownColor: Colors.grey[800],
                underline: Container(
                  color: Colors.transparent,
                ),
                onChanged: (String? pageinput) {
                  if (pageinput == 'Input Data') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StreamProvider<StudentData?>.value(
                                    value:
                                        DatabaseService(uid: widget.studentid)
                                            .studentdata,
                                    initialData: null,
                                    catchError: (context, error) => null,
                                    child: InputData())));
                  }
                  if (pageinput == 'Input Feedback') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StreamProvider<StudentData?>.value(
                                    value:
                                        DatabaseService(uid: widget.studentid)
                                            .studentdata,
                                    initialData: null,
                                    catchError: (context, error) => null,
                                    child: TeacherFeedback(
                                      studentid: widget.studentid,
                                    ))));
                  }
                  if (pageinput == 'Edit Input Data') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditInputData()));
                  }
                  if (pageinput == 'Edit Feedback') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditFeedback(
                                  studentid: widget.studentid,
                                  studentname: widget.studentname,
                                )));
                  }
                },
                items: [
                  'Input Data',
                  'Input Feedback',
                  'Edit Input Data',
                  "Edit Feedback"
                ].map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                icon: Icon(
                  Icons.menu_rounded,
                  color: Colors.amber,
                  size: 35.0,
                ),
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        ),
        body: Stats(),
      ),
    );
  }
}
