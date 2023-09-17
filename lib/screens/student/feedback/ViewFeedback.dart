import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        backgroundColor: Colors.grey[800],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[400],
      body: StudentFeedbackCard(),
    );
  }
}

class StudentFeedbackCard extends StatefulWidget {
  @override
  _StudentFeedbackCardState createState() => _StudentFeedbackCardState();
}

class _StudentFeedbackCardState extends State<StudentFeedbackCard> {
  @override
  Widget build(BuildContext context) {
    final studentdata = Provider.of<StudentData?>(context);
    if (studentdata == null) {
      return Loading();
    }
    return ListView.builder(
      itemCount: studentdata.feedback.length,
      itemBuilder: (context, int index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                    '${DateFormat('dd-MM-yyyy').format(DateTime.parse(studentdata.feedback[index].keys.toString().substring(1, studentdata.feedback[index].keys.toString().length - 1)))}'),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                    '${studentdata.feedback[index].values.toString().substring(1, studentdata.feedback[index].values.toString().length - 1)}')
              ],
            ),
          ),
        );
      },
    );
  }
}
