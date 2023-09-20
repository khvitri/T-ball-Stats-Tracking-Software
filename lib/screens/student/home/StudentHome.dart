import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/student/feedback/ViewFeedback.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:cstballprogram/shared/stats.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StudentHome extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final loginuseruid = Provider.of<cUser?>(context);

    return MultiProvider(
      providers: [
        StreamProvider<StudentData?>.value(
            value: DatabaseService(uid: loginuseruid?.uid).studentdata,
            initialData: null,
            catchError: (context, error) => null),
        StreamProvider<QuerySnapshot?>.value(
          value: DatabaseService().classroomCollectionData,
          initialData: null,
          catchError: (context, error) => null,
        )
      ],
      child: Scaffold(
        drawer: SideBar(),
        backgroundColor: Colors.grey[400],
        appBar: AppBar(
          title: Text(
            'Swing',
            style: TextStyle(
              color: Colors.amber,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.grey[800],
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.amber),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StreamProvider<StudentData?>.value(
                                  value: DatabaseService(uid: loginuseruid?.uid)
                                      .studentdata,
                                  initialData: null,
                                  catchError: (context, error) => null,
                                  child: StudentFeedbackPage())));
                },
                child: Icon(Icons.remove_red_eye_outlined),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.amber),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  )),
                ),
                onPressed: () async {
                  await _auth.logOut();
                },
                icon: Icon(
                  Icons.person,
                  color: Colors.grey[800],
                ),
                label: Text('Logout',
                    style: GoogleFonts.lato(
                      textStyle:
                          TextStyle(color: Colors.grey[800], fontSize: 15.0),
                    )),
              ),
            ),
          ],
        ),
        body: Stats(),
      ),
    );
  }
}

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String inputid = '';
  String error = '';
  bool samedata = false;
  bool match = false;
  final _formkey = GlobalKey<FormState>();

  Future<void> joinClassroom(BuildContext context, var studentclassidlist,
      classroomdatadoc, uid, studentname) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Form(
              key: _formkey,
              child: AlertDialog(
                title: Text("Enter Class ID Below"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      style: TextStyle(color: Colors.amber),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter an ID' : null,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Class ID'),
                      onChanged: (val) {
                        inputid = val;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        samedata = false;
                        match = false;
                        if (_formkey.currentState!.validate()) {
                          if (studentclassidlist.length != 0) {
                            for (var x in studentclassidlist) {
                              if (inputid == x) {
                                setState(() {
                                  error = 'Classroom ID already exist';
                                  samedata = true;
                                });
                              }
                            }
                          }
                          if (samedata == false) {
                            if (classroomdatadoc != null) {
                              for (var x in classroomdatadoc) {
                                if (inputid == x.get('id')) {
                                  await DatabaseService(uid: uid)
                                      .addSNewClass(inputid);
                                  await DatabaseService(
                                          uid: uid, classId: inputid)
                                      .addNewStudent(studentname);
                                  match = true;
                                  Navigator.of(context).pop();
                                }
                                if (match == false) {
                                  setState(() {
                                    error = 'Classroom ID does not exist';
                                  });
                                }
                              }
                            }
                          }
                        }
                      },
                      child: Text("Join"))
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentData?>(context);
    final classroomdataquery = Provider.of<QuerySnapshot?>(context);
    final loginuseruid = Provider.of<cUser?>(context);

    final classroomdatadoc = classroomdataquery?.docs;

    var studentclassidlist = student?.classid == null ? [] : student?.classid;
    var studentclassnamelist = [];

    if (classroomdatadoc != null) {
      for (var x in classroomdatadoc) {
        for (var y = 0; y < studentclassidlist.length; y++) {
          if (x.get('id') == studentclassidlist[y]) {
            studentclassnamelist.add(x.get('classname'));
            break;
          }
        }
      }
    }

    String? studentname = student?.name.toString();
    if (student == null || classroomdataquery == null || loginuseruid == null) {
      return Loading();
    }
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.grey[400]),
      child: Drawer(
        child: Stack(
          children: [
            Container(
              height: 125.0,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                ),
                child: Text(
                  'Classrooms',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 30.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 70),
              child: ListView.builder(
                  itemCount: studentclassidlist.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        child: Card(
                          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                          child: ListTile(
                              leading: CircleAvatar(
                                radius: 25.0,
                                child: Icon(Icons.sports_baseball),
                              ),
                              title: Text('${studentclassnamelist[index]}')),
                        ),
                      ),
                    );
                  }),
            ),
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      child: FloatingActionButton(
                        foregroundColor: Colors.grey[800],
                        backgroundColor: Colors.amber,
                        onPressed: () async {
                          await joinClassroom(context, studentclassidlist,
                              classroomdatadoc, loginuseruid.uid, studentname);
                        },
                        child: Icon(
                          Icons.add,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
