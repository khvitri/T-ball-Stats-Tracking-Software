import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/teacher/input/InputData.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditInputData extends StatefulWidget {
  String? studentname;
  String? studentid;
  EditInputData({this.studentname, this.studentid});
  @override
  _EditInputDataState createState() => _EditInputDataState();
}

class _EditInputDataState extends State<EditInputData> {
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
            if (snapshot.data!.datainput != null) {
              var dataList = snapshot.data!.datainput;
              var dataInputList = [];
              var dateOfInputList = [];
              for (int x = 0; x < dataList.length; x++) {
                dateOfInputList.add(dataList[x]
                    .keys
                    .toString()
                    .substring(1, dataList[x].keys.toString().length - 1));
                dataInputList.add(dataList[x]
                    .values
                    .toString()
                    .substring(2, dataList[x].values.toString().length - 2)
                    .split(','));
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
                        itemCount: dataList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          '${DateFormat('dd-MM-yyyy').format(DateTime.parse(dateOfInputList[dataList.length - index - 1]))}'),
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
                                                    builder: (context) => StreamProvider<
                                                            StudentData?>.value(
                                                        value: DatabaseService(
                                                                uid: widget
                                                                    .studentid)
                                                            .studentdata,
                                                        initialData: null,
                                                        catchError:
                                                            (context, error) =>
                                                                null,
                                                        child:
                                                            TeacherInputStudentData(
                                                          studentid:
                                                              widget.studentid,
                                                          dataList: dataList,
                                                          dateOfInputList:
                                                              dateOfInputList,
                                                          dataInputList:
                                                              dataInputList,
                                                          dataInputSelect:
                                                              dataInputList[
                                                                  dataList.length -
                                                                      index -
                                                                      1],
                                                          index:
                                                              dataList.length -
                                                                  index -
                                                                  1,
                                                        ))));
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
                                                              snapshot
                                                                  .data!.accList
                                                                  .removeAt(dataList
                                                                          .length -
                                                                      index -
                                                                      1);
                                                              snapshot.data!
                                                                  .effectList
                                                                  .removeAt(dataList
                                                                          .length -
                                                                      index -
                                                                      1);
                                                              snapshot.data!
                                                                  .speedList
                                                                  .removeAt(dataList
                                                                          .length -
                                                                      index -
                                                                      1);
                                                              snapshot.data!
                                                                  .distanceList
                                                                  .removeAt(dataList
                                                                          .length -
                                                                      index -
                                                                      1);
                                                              dataList.removeAt(
                                                                  dataList.length -
                                                                      index -
                                                                      1);
                                                              await DatabaseService(
                                                                      uid: widget
                                                                          .studentid)
                                                                  .deleteDataInput(
                                                                snapshot.data!
                                                                    .accList,
                                                                snapshot.data!
                                                                    .effectList,
                                                                snapshot.data!
                                                                    .speedList,
                                                                snapshot.data!
                                                                    .distanceList,
                                                                dataList,
                                                              );
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
                                      'No. of Strikes: ${dataInputList[dataList.length - index - 1][0].toString().trim()}'),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                      'Time in seconds: ${dataInputList[dataList.length - index - 1][1].toString().trim()}'),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                      'No. of Base Ran: ${dataInputList[dataList.length - index - 1][2].toString().trim()}'),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                      'Caught Out?: ${dataInputList[dataList.length - index - 1][3].toString().trim()}'),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                      'Coordinates (X,Y): (${dataInputList[dataList.length - index - 1][4].toString().trim()}, ${dataInputList[dataList.length - index - 1][5].toString().trim()})'),
                                  SizedBox(
                                    height: 5.0,
                                  ),
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
