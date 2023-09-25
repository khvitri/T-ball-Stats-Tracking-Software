import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/teacher/input/InputFeedback.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditFeedback extends StatefulWidget {
  String? studentname;
  String? studentid;
  EditFeedback({this.studentname, this.studentid});
  @override
  _EditFeedbackState createState() => _EditFeedbackState();
}

class _EditFeedbackState extends State<EditFeedback> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    if (widget.studentname == null || widget.studentid == null) {
      return Loading();
    }
    return StreamBuilder<StudentData>(
        stream: DatabaseService(uid: widget.studentid).studentdata,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.feedback != null) {
              var feedbackMap = snapshot.data!.feedback;
              var feedbackList = [];
              var dateOfFeedbackList = [];
              for (int x = 0; x < feedbackMap.length; x++) {
                dateOfFeedbackList.add(feedbackMap[x]
                    .keys
                    .toString()
                    .substring(1, feedbackMap[x].keys.toString().length - 1));
                feedbackList.add(feedbackMap[x]
                    .values
                    .toString()
                    .substring(1, feedbackMap[x].values.toString().length - 1));
              }
              return loading == true
                  ? Loading()
                  : Scaffold(
                      backgroundColor: Colors.grey[400],
                      appBar: AppBar(
                        title: Text('${widget.studentname}'),
                        centerTitle: true,
                        backgroundColor: Colors.grey[800],
                      ),
                      body: ListView.builder(
                        itemCount: feedbackList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          '${DateFormat('dd-MM-yyyy').format(DateTime.parse(dateOfFeedbackList[feedbackList.length - index - 1]))}'),
                                      SizedBox(width: 210),
                                      DropdownButton(
                                        dropdownColor: Colors.grey[800],
                                        underline: Container(
                                          color: Colors.transparent,
                                        ),
                                        onChanged: (String? optioninput) {
                                          if (optioninput == 'Edit Data') {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StreamProvider<
                                                            StudentData?>.value(
                                                          value: DatabaseService(
                                                                  uid: widget
                                                                      .studentid)
                                                              .studentdata,
                                                          initialData: null,
                                                          catchError: (context,
                                                                  error) =>
                                                              null,
                                                          child:
                                                              TeacherFeedback(
                                                            studentid: widget
                                                                .studentid,
                                                            feedbackMap:
                                                                feedbackMap,
                                                            feedbackList:
                                                                feedbackList,
                                                            dateOfFeedbackList:
                                                                dateOfFeedbackList,
                                                            index: feedbackMap
                                                                    .length -
                                                                index -
                                                                1,
                                                          ),
                                                        )));
                                          }
                                          if (optioninput == 'Delete Data') {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text("Delete?"),
                                                      content: Text(
                                                          "Data will be permanently deleted."),
                                                      actions: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                loading = true;
                                                              });
                                                              feedbackMap.removeAt(
                                                                  feedbackMap
                                                                          .length -
                                                                      index -
                                                                      1);
                                                              DatabaseService(
                                                                      uid: widget
                                                                          .studentid)
                                                                  .adddeleteFeedback(
                                                                      feedbackMap);
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("Yes")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("No"))
                                                      ],
                                                    ));
                                          }
                                        },
                                        items: [
                                          'Edit Data',
                                          'Delete Data',
                                        ].map((String value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        icon: Icon(
                                          Icons.menu,
                                        ),
                                        style: TextStyle(color: Colors.amber),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                      '${feedbackList[feedbackMap.length - index - 1].trim()}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            } else {
              return Scaffold(
                backgroundColor: Colors.grey[400],
                appBar: AppBar(
                  title: Text('${widget.studentname}'),
                  centerTitle: true,
                  backgroundColor: Colors.grey[800],
                ),
              );
            }
          } else {
            return Loading();
          }
        });
  }
}
