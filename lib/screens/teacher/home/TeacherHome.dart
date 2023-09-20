import 'package:cstballprogram/models/classroom.dart';
import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:provider/provider.dart';

class TeacherHome extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final loginuseruid = Provider.of<cUser?>(context);
    Future<List<ClassDocData>> classListLoading =
        DatabaseService.teacherId(loginuseruid?.uid).getClassList();

    return Scaffold(
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
        body: StreamProvider<TeacherData?>.value(
            value: DatabaseService(uid: loginuseruid?.uid).teacherdata,
            initialData: null,
            child: ClassroomList(classListLoading: classListLoading)));
  }
}

class ClassroomList extends StatefulWidget {
  Future<List<ClassDocData>>? classListLoading;
  ClassroomList({this.classListLoading});

  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  bool loading = true;
  bool samedata = false;
  String inputname = '';
  String error = '';
  final _formkey = GlobalKey<FormState>();
  late List<ClassDocData>? teacherClassList;

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
                                ID, [], inputname, teachername, uid!);
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
    final teacher = Provider.of<TeacherData?>(context);
    String classId = new DateTime.now().millisecondsSinceEpoch.toString();

    if (loading || teacher == null || teacherClassList == null) {
      loadClassList();
      return Loading();
    } else {
      return Stack(
        children: [
          ListView.builder(
              itemCount: teacherClassList!.length,
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
                        title: Text('${teacherClassList![index].classname}'),
                        subtitle: Text("ID: ${teacherClassList![index].id}"),
                      ),
                    ),
                  ),
                );
              }),
        ],
      );
    }
  }

  void loadClassList() async {
    teacherClassList = await widget.classListLoading;
    setState((() => loading = false));
  }
}
