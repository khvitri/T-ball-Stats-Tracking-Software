import 'package:cstballprogram/customWidgets/NonMtInputForm.dart';
import 'package:cstballprogram/models/classroom.dart';
import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/services/auth.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:provider/provider.dart';

class TeacherHome extends StatelessWidget {
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
          actions: [_logoutButton()],
        ),
        body: StreamProvider<TeacherData?>.value(
            value: DatabaseService(uid: loginuseruid?.uid).teacherdata,
            initialData: null,
            child: ClassroomList()));
  }

  // button to logout
  Widget _logoutButton() {
    final AuthService _auth = AuthService();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),
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
              textStyle: TextStyle(color: Colors.grey[800], fontSize: 15.0),
            )),
      ),
    );
  }
}

// Displays a list of the teacher's classrooms
class ClassroomList extends StatefulWidget {
  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  bool loading = true;
  final _formkey = GlobalKey<FormState>();
  String error = '';

  late List<ClassDocData>? teacherClassList;

  @override
  Widget build(BuildContext context) {
    final teacher = Provider.of<TeacherData?>(context);

    if (loading || teacher == null || teacherClassList == null) {
      _loadClassList();
      return Loading();
    } else {
      return Stack(children: [
        ListView.builder(
            itemCount: teacherClassList!.length,
            itemBuilder: (BuildContext context, int index) {
              return _classroomTile(index);
            }),
        _addNewClassroomButton(teacher)
      ]);
    }
  }

  // load teacherClassList variable
  void _loadClassList() async {
    teacherClassList =
        await DatabaseService.teacherId(AuthService().getUserUid())
            .getClassList();
    setState((() => loading = false));
  }

  // Returns a classroom tile given the index
  Widget _classroomTile(int index) {
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
                onPressed: () => _deleteClassroom(index),
              ),
            ),
            title: Text("${teacherClassList![index].classname}"),
            subtitle: Text("ID: ${teacherClassList![index].id}"),
          ),
        ),
      ),
    );
  }

  // button to delete classroom
  void _deleteClassroom(int index) {
    String? _teacherId = AuthService().getUserUid();
    ClassDocData classroom = teacherClassList![index];

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete?"),
              content: Text("Classroom will be permanently deleted."),
              actions: [
                TextButton(
                    onPressed: () async {
                      setState(() => teacherClassList!.remove(classroom));
                      Navigator.pop(context);
                      await DatabaseService(uid: _teacherId)
                          .deleteUserClassroom(classroom.id);
                      for (String studentId in classroom.studentidsMap!.keys) {
                        await DatabaseService(uid: studentId)
                            .deleteUserClassroom(studentId);
                      }
                      await DatabaseService()
                          .deleteClassroomDocument(classroom.id);
                    },
                    child: Text("Yes")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No"))
              ],
            ));
  }

  // A button to add new classrooms
  Widget _addNewClassroomButton(TeacherData teacher) {
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
                  onPressed: (() => _newClassroomName(
                      context,
                      teacher.numofclass,
                      AuthService().getUserUid(),
                      teacher.name)),
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
            ])));
  }

  // Pop-up for adding new classroom
  Future<void> _newClassroomName(BuildContext context, int? numOfClass,
      String? teacherId, String? teacherName) {
    final classNameController =
        TextEditingController(text: "New Classroom $numOfClass");
    return showDialog(
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
                    NonMtInputForm(
                        textColor: Colors.grey[750],
                        hintText: "Class Name",
                        validationMsg: "Please enter a name",
                        controller: classNameController,
                        isTextObscure: false),
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
                      onPressed: () => _processClassnameInput(
                          classNameController.text,
                          numOfClass,
                          teacherId,
                          teacherName),
                      child: Text("Create New Classroom"))
                ],
              ),
            );
          });
        });
  }

  // validates the classname input and creates a new classroom document on
  // firebase
  void _processClassnameInput(String inputName, int? numOfClass,
      String? teacherId, String? teacherName) async {
    String classId = new DateTime.now().millisecondsSinceEpoch.toString();
    _formkey.currentState!.validate();
    if (teacherClassList!
        .map((classroom) => classroom.classname)
        .contains(inputName)) {
      setState(() => error = 'Classroom Name Already Exist!');
    }
    ClassDocData newClass = ClassDocData(
        classname: inputName,
        id: classId,
        studentidsMap: Map<String, String>(),
        teachername: teacherName,
        teacherId: teacherId);
    setState(() => teacherClassList?.add(newClass));
    Navigator.pop(context);
    await DatabaseService(uid: teacherId).addTNewClass(classId, numOfClass);
    await DatabaseService().createClassroomData(
        teacherName, classId, inputName, Map<String, String>(), teacherId!);
  }
}
