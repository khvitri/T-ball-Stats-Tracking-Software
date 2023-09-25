import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeacherFeedback extends StatefulWidget {
  String? studentid = '';
  var feedbackMap;
  var feedbackList;
  var dateOfFeedbackList;
  int? index;
  TeacherFeedback(
      {this.studentid,
      this.feedbackMap,
      this.feedbackList,
      this.dateOfFeedbackList,
      this.index});
  @override
  _TeacherFeedbackState createState() => _TeacherFeedbackState();
}

class _TeacherFeedbackState extends State<TeacherFeedback> {
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  String? feedback = '';
  @override
  Widget build(BuildContext context) {
    final studentdata = Provider.of<StudentData?>(context);

    var mapfeedback = studentdata?.feedback;

    if (loading == true) {
      return Loading();
    }
    return Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        title: Text(widget.feedbackMap != null ? 'Edit Feedback' : 'Feedback'),
        backgroundColor: Colors.grey[800],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: _formkey,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 725.0),
                  child: TextFormField(
                    style: TextStyle(color: Colors.amber),
                    initialValue: widget.feedbackMap != null
                        ? widget.feedbackList[widget.index]
                        : null,
                    onChanged: (val) {
                      feedback = val;
                    },
                    validator: (val) {
                      return val!.isEmpty ? "Please Write a Feedback" : null;
                    },
                    decoration: textInputDecoration.copyWith(
                        hintText: "Type feedback here"),
                    minLines: 35,
                    maxLines: 35,
                    keyboardType: TextInputType
                        .multiline, // user can press enter to move to the next line
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Container(
              width: double.infinity,
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.amber),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    )),
                  ),
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      if (widget.feedbackMap != null) {
                        mapfeedback[widget.index] = {
                          widget.dateOfFeedbackList[widget.index]: feedback
                        };
                      } else {
                        mapfeedback.add({
                          DateFormat('yyyyMMdd').format(DateTime.now()):
                              feedback!
                        });
                      }
                      await DatabaseService(uid: widget.studentid)
                          .adddeleteFeedback(mapfeedback);

                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.feedbackMap != null
                        ? "Save Changes"
                        : "Send Feedback",
                    style: TextStyle(color: Colors.black),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
