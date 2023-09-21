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
            child: ClassroomList()));
  }
}

// Displays a list of the teacher's classrooms
class ClassroomList extends StatefulWidget {
  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  bool loading = true;
  bool samedata = false;
  String error = '';
  final _formkey = GlobalKey<FormState>();
  late List<ClassDocData>? teacherClassList;

  @override
  Widget build(BuildContext context) {
    final teacher = Provider.of<TeacherData?>(context);

    if (loading || teacher == null || teacherClassList == null) {
      loadClassList();
      return Loading();
    } else {
      return Stack(children: [
        ListView.builder(
            itemCount: teacherClassList!.length,
            itemBuilder: (BuildContext context, int index) {
              return classroomTile(index);
            }),
        addNewClassroomButton(teacher)
      ]);
    }
  }

  // A button to add new classrooms
  Widget addNewClassroomButton(TeacherData teacher) {
    String classId = new DateTime.now().millisecondsSinceEpoch.toString();

    return Positioned(
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
                  onPressed: (() => newClassroomName(
                      context,
                      teacher.numofclass,
                      AuthService().getUserUid(),
                      classId,
                      teacher.name)),
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
            ])));
  }

  // Returns a classroom tile given the index
  Widget classroomTile(int index) {
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
  }

  // load teacherClassList variable
  void loadClassList() async {
    teacherClassList =
        await DatabaseService.teacherId(AuthService().getUserUid())
            .getClassList();
    setState((() => loading = false));
  }

  //Pop-up for adding new classroom
  Future<void> newClassroomName(BuildContext context, int? numOfClass,
      String? teacherId, String classId, String? teacherName) async {
    final classNameController =
        TextEditingController(text: "New Classroom $numOfClass");
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
                      controller: classNameController,
                      style: TextStyle(color: Colors.amber),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter a name' : null,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Class Name'),
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
                          setState(() => samedata = false);
                          for (ClassDocData classroom in teacherClassList!) {
                            if (classNameController.text ==
                                classroom.classname) {
                              setState(() {
                                error = 'Classroom Name Already Exist!';
                                samedata = true;
                              });
                            }
                          }
                          if (samedata == false) {
                            ClassDocData newClass = ClassDocData(
                                classname: classNameController.text,
                                id: classId,
                                studentid: Map<String, String>(),
                                teachername: teacherName,
                                teacherId: teacherId);
                            setState(() => teacherClassList?.add(newClass));
                            await DatabaseService(uid: teacherId)
                                .addTNewClass(classId, numOfClass);
                            await DatabaseService().createClassroomData(
                                teacherName,
                                classId,
                                classNameController.text,
                                Map<String, String>(),
                                teacherId!);
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
}
