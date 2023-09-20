import 'package:cstballprogram/models/classroom.dart';
import 'package:cstballprogram/screens/teacher/classroom/ViewStudentStat.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';

class TeacherClassroom extends StatefulWidget {
  final String? name;
  final String? id;
  var student;
  TeacherClassroom({this.name, this.id, this.student});

  @override
  _TeacherClassroomState createState() => _TeacherClassroomState();
}

class _TeacherClassroomState extends State<TeacherClassroom> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    if (widget.name == null ||
        widget.id == null ||
        widget.student == null ||
        loading == true) {
      return Loading();
    }
    return StreamBuilder<ClassDocData>(
        stream: DatabaseService(classId: widget.id).classroomDocumentData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var studentList = snapshot.data!.studentid;
            String? classname = snapshot.data!.classname;
            return Scaffold(
              backgroundColor: Colors.grey[400],
              appBar: AppBar(
                title: Text('$classname'),
                backgroundColor: Colors.grey[800],
              ),
              body: widget.student.length != 0
                  ? ListView.builder(
                      itemCount: studentList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                            child: Card(
                              margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                              child: ListTile(
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
                                                    "Student will be permanently removed."),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        String studentid = studentList[
                                                                index]
                                                            .keys
                                                            .toString()
                                                            .substring(
                                                                1,
                                                                studentList[index]
                                                                        .keys
                                                                        .toString()
                                                                        .length -
                                                                    1);
                                                        String studentname = studentList[
                                                                index]
                                                            .values
                                                            .toString()
                                                            .substring(
                                                                1,
                                                                studentList[index]
                                                                        .values
                                                                        .toString()
                                                                        .length -
                                                                    1);
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        if (widget.student
                                                                .length !=
                                                            0) {
                                                          await DatabaseService(
                                                                  uid:
                                                                      studentid)
                                                              .deleteCIDfromUserCList(
                                                                  widget.id
                                                                      .toString());
                                                          await DatabaseService(
                                                                  classId:
                                                                      widget.id)
                                                              .deleteStudentFromClassroomList(
                                                                  studentid,
                                                                  studentname);
                                                        }
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
                                leading: CircleAvatar(
                                  radius: 25.0,
                                  child: Icon(Icons.sports_baseball),
                                ),
                                title: Text(
                                    '${studentList[index].values.toString().substring(1, studentList[index].values.toString().length - 1)}'),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TeacherStudentStat(
                                      studentname:
                                          '${widget.student[index][1]}',
                                      studentid:
                                          '${widget.student[index][0]}')));
                            },
                          ),
                        );
                      })
                  : null,
            );
          } else {
            return Loading();
          }
        });
  }
}
