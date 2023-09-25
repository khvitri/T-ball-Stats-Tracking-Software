import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cstballprogram/models/classroom.dart';
import 'package:cstballprogram/screens/teacher/classroom/ViewStudentStat.dart';
import 'package:cstballprogram/services/database.dart';

class TeacherClassroom extends StatefulWidget {
  @override
  _TeacherClassroomState createState() => _TeacherClassroomState();
}

class _TeacherClassroomState extends State<TeacherClassroom> {
  @override
  Widget build(BuildContext context) {
    final classroomData = Provider.of<ClassDocData>(context);
    final studentsData = classroomData.studentidsMap;

    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: Text('${classroomData.classname}'),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView.builder(
        itemCount: studentsData!.length,
        itemBuilder: (context, index) {
          final studentId = studentsData.keys.elementAt(index);
          final studentName = studentsData[studentId]!;

          return Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              child: Card(
                margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                child: ListTile(
                  trailing: _deleteButton(index, studentsData, classroomData),
                  leading: CircleAvatar(
                    radius: 25.0,
                    child: Icon(Icons.person),
                  ),
                  title: Text(studentName),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewStudentStat(
                    studentname: studentName,
                    studentid: studentId,
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _deleteButton(int index, Map<String, String>? studentsData,
      ClassDocData classroomData) {
    final studentId = studentsData!.keys.elementAt(index);
    final studentName = studentsData[studentId]!;

    return FloatingActionButton(
      heroTag: "deletebtn$index",
      elevation: 0,
      foregroundColor: Colors.red,
      backgroundColor: Colors.white,
      child: Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Remove $studentName from ${classroomData.classname}?"),
            content: Text("Student will be removed from class."),
            actions: [
              TextButton(
                onPressed: () =>
                    _runDeleteStudent(index, studentsData, classroomData),
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("No"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _runDeleteStudent(int index, Map<String, String>? studentsData,
      ClassDocData classroomData) async {
    final studentId = studentsData!.keys.elementAt(index);
    setState(() => studentsData.remove(studentId));
    Navigator.pop(context);
    await DatabaseService(uid: studentId).deleteUserClassroom(classroomData.id);
    await DatabaseService(classId: classroomData.id)
        .deleteStudentFromClassroomList(studentId);
  }
}
