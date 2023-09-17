import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/teacher/classroom/SelectedClass.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final loginuseruid = Provider.of<cUser?>(context);

    return MultiProvider(
        providers: [
          StreamProvider<TeacherData?>.value(
            value: DatabaseService(uid: loginuseruid?.uid).teacherdata,
            initialData: null,
            catchError: (context, error) => null,
          ),
          StreamProvider<QuerySnapshot?>.value(
            value: DatabaseService().classroomCollectionData,
            initialData: null,
            catchError: (context, error) => null,
          ),
        ],
        child: Scaffold(
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
            actions: [
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
              )
            ],
          ),
          body: ClassroomList(),
        ));
  }
}

class ClassroomList extends StatefulWidget {
  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  bool loading = false;
  bool samedata = false;
  String inputname = '';
  String error = '';
  final _formkey = GlobalKey<FormState>();

  //Pop-up for adding new classroom
  Future<void> newClassroomName(
      BuildContext context,
      var classlist,
      String defaultname,
      String? uid,
      String ID,
      int numofclass,
      String teachername) async {
    inputname = defaultname;
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Form(
              key: _formkey,
              child: AlertDialog(
                title: Text("Enter Class Name Below"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: defaultname,
                      style: TextStyle(color: Colors.amber),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter a name' : null,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Class Name'),
                      onChanged: (val) {
                        inputname = val;
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
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            samedata = false;
                          });
                          for (var x in classlist) {
                            if (inputname == x[0]) {
                              setState(() {
                                error = 'Classroom Name Already Exist!';
                                samedata = true;
                              });
                            }
                          }
                          if (samedata == false) {
                            await DatabaseService(uid: uid)
                                .addTNewClass(ID, numofclass);
                            await DatabaseService().createClassroomData(
                                ID, [], inputname, teachername);
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text("Create New Classroom"))
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final loginuseruid = Provider.of<cUser?>(context);
    final teacher = Provider.of<TeacherData?>(context);
    final classroomdataquery = Provider.of<QuerySnapshot?>(context);

    final classroomdatadoc = classroomdataquery?.docs;

    var classidlist = teacher?.classid == null ? [] : teacher?.classid;
    var student = List.generate(
        classidlist.length, (i) => List.filled(0, [], growable: true),
        growable: true); // "student" is a dynamic multi-dimensional arrays
    var class2dlist = [];
    int index = 0;

    if (classroomdatadoc != null) {
      for (var x in classroomdatadoc) {
        for (var y = 0; y < classidlist.length; y++) {
          if (x.get('id') == classidlist[y]) {
            /* if teacher's classroom id ("classidlist[y]") matches with 
            a classroom id stored in the database ("x.get('id')") then add to array "class2dlist"*/
            class2dlist.add([
              x.get('classname'),
              classidlist[y]
            ]); //class2dlist: [[class name, class id], [..., ...]]
            var studentidlist = x.get(
                'studentid'); // "studentidlist" contains the id of students that are within the classroom
            for (var z in studentidlist) {
              //converting from an array of maps to an array of arrays for ease of access
              student[index].add([
                z.keys.toString().substring(1, z.keys.toString().length - 1),
                z.values.toString().substring(1, z.values.toString().length - 1)
              ]);
            }
            index++; //to move onto the next "slot" everytime student data is added to dynamic multi-dimensional array "student",
          }
        }
      }
    }

    String? teachername = teacher?.name;
    int? numofclass = teacher?.numofclass;
    final String ID = new DateTime.now().millisecondsSinceEpoch.toString();

    if (teacher == null || classroomdataquery == null || loading == true) {
      return Loading();
    } else {
      return Stack(
        children: [
          ListView.builder(
              itemCount: class2dlist.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    child: Card(
                      margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25.0,
                          child: Icon(Icons.sports_baseball),
                        ),
                        trailing: Container(
                          height: 40,
                          width: 40,
                          child: FloatingActionButton(
                            heroTag: "deletebtn$index",
                            elevation: 0,
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Delete?"),
                                        content: Text(
                                            "Classroom will be permanently deleted."),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                setState(() {
                                                  loading = true;
                                                });
                                                await DatabaseService(
                                                        uid: loginuseruid!.uid)
                                                    .deleteCIDfromUserCList(
                                                        class2dlist[index][1]
                                                            .toString());
                                                if (student[index].length !=
                                                    0) {
                                                  for (var studentid
                                                      in student[index]) {
                                                    await DatabaseService(
                                                            uid: studentid[0]
                                                                .toString())
                                                        .deleteCIDfromUserCList(
                                                            class2dlist[index]
                                                                    [1]
                                                                .toString());
                                                  }
                                                }

                                                await DatabaseService()
                                                    .deleteClassroomDocument(
                                                        class2dlist[index][1]
                                                            .toString());
                                                setState(() {
                                                  loading = false;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text("Yes")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No"))
                                        ],
                                      ));
                            },
                          ),
                        ),
                        title: Text('${class2dlist[index][0]}'),
                        subtitle: Text("ID: ${class2dlist[index][1]}"),
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TeacherClassroom(
                                name: class2dlist[index][0],
                                id: class2dlist[index][1],
                                student: student[
                                    index], //Student's info in the classroom
                              )));
                    },
                  ),
                );
              }),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    child: FloatingActionButton(
                      foregroundColor: Colors.grey[800],
                      backgroundColor: Colors.amber,
                      onPressed: () async {
                        await newClassroomName(
                            context,
                            class2dlist,
                            "New Classroom $numofclass",
                            loginuseruid!.uid,
                            ID,
                            numofclass!,
                            teachername!);
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
      );
    }
  }
}
