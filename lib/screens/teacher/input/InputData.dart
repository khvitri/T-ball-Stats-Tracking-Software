import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/services/database.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TeacherInputStudentData extends StatefulWidget {
  String? studentid;
  var dataList;
  var dateOfInputList;
  var dataInputList;
  var dataInputSelect;
  var index;
  TeacherInputStudentData(
      {this.studentid,
      this.dataList,
      this.dateOfInputList,
      this.dataInputList,
      this.dataInputSelect,
      this.index});
  @override
  _TeacherInputStudentDataState createState() =>
      _TeacherInputStudentDataState();
}

class _TeacherInputStudentDataState extends State<TeacherInputStudentData> {
  bool loading = false;
  final _formkey = GlobalKey<FormState>();
  int noofstrike = 0;
  double seconds = 0;
  int noofbaseran = 0;
  double distance = 0;
  String caughtout = '';
  double posx = 100.0;
  double posy = 100.0;
  bool changecolor = false;
  String error = '';
  double newaccuracy = 0.0;
  double newspeed = 0.0;
  double neweffect = 0.0;
  double newdistance = 0.0;
  double avgaccuracy = 0.0;
  double? avgspeed = 0.0;
  double avgdistance = 0.0;
  double avgeffect = 0.0;
  String? dateinput;
  int count = 0;

  void onTapDown(BuildContext context, TapDownDetails details) {
    setState(() {
      posx = details.localPosition.dx;
      posy = details.localPosition.dy;
      distance = double.parse(sqrt(
              pow(((379 - posx) * (1 / 4)), 2) + pow((512 - posy) * (1 / 4), 2))
          .toStringAsFixed(1));
      changecolor = true;
    });
  }

  void onDoubleTap() {
    setState(() {
      posx = 100.0;
      posy = 100.0;
      distance = 0.0;
      changecolor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentdata = Provider.of<StudentData?>(context);

    //This is to allow the client to change data as it prevents the variables from returning to the original data when changing
    if (count < 1) {
      if (widget.dataList != null) {
        noofstrike = int.parse((widget.dataInputSelect[0]));
        seconds = double.parse(widget.dataInputSelect[1]);
        noofbaseran = int.parse(widget.dataInputSelect[2]);
        caughtout = widget.dataInputSelect[3].trim();
        posx = double.parse(widget.dataInputSelect[4]);
        posy = double.parse(widget.dataInputSelect[5]);
        distance = double.parse(sqrt(pow(((379 - posx) * (1 / 4)), 2) +
                pow((512 - posy) * (1 / 4), 2))
            .toStringAsFixed(1));
        changecolor = true;
        count++;
      }
    }

    final mapacc = studentdata?.accList;
    final mapspeed = studentdata?.speedList;
    final mapdistance = studentdata?.distanceList;
    final mapeffect = studentdata?.effectList;
    final mapdatainput = studentdata?.datainput;

    double acctotal = 0.0;
    double speedtotal = 0.0;
    double distancetotal = 0.0;
    double effecttotal = 0.0;
    int noofspeed = 0;

    //Totalling for averages
    if (mapacc != null &&
        mapspeed != null &&
        mapdistance != null &&
        mapeffect != null) {
      for (var z = 0; z < mapacc.length; z++) {
        //totalling for accuracy
        acctotal += double.parse(mapacc[z]
            .values
            .toString()
            .substring(1, mapacc[z].values.toString().length - 1));
        //totalling for distance
        distancetotal += double.parse(mapdistance[z]
            .values
            .toString()
            .substring(1, mapdistance[z].values.toString().length - 1));
        //totalling for effectiveness
        effecttotal += double.parse(mapeffect[z]
            .values
            .toString()
            .substring(1, mapeffect[z].values.toString().length - 1));
        //If they were eliminated before they ran, speed = -314 and therefore it doesn't count in the totalling and averages
        if (double.parse(mapspeed[z]
                .values
                .toString()
                .substring(1, mapspeed[z].values.toString().length - 1)) !=
            -314) {
          speedtotal += double.parse(mapspeed[z]
              .values
              .toString()
              .substring(1, mapspeed[z].values.toString().length - 1));
          noofspeed++;
        }
      }
    }

    return loading == true
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.grey[400],
            appBar: AppBar(
              title: widget.dataList != null
                  ? Text('Edit data')
                  : Text('Input data'),
              backgroundColor: Colors.grey[800],
              elevation: 0.0,
              actions: [
                //The "Add/Change" Button
                ElevatedButton(
                  child: widget.dataList != null
                      ? Text('Change',
                          style: TextStyle(color: Colors.grey[900]))
                      : Text(
                          'Add',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.all(8.0)),
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      //Checks if there is input position of ball
                      if (changecolor == false) {
                        setState(() {
                          loading = false;
                          error = "Please enter the position of the ball below";
                        });
                      } else {
                        //Checks if the ball is land in the correct spots for a hit to count
                        if (noofstrike < 3 &&
                            (distance < 14.8 ||
                                512 - posy < 0 ||
                                379 - posx < 0)) {
                          setState(() {
                            loading = false;
                            error =
                                "A proper hit cannot land there at $noofstrike ${noofstrike == 2 ? 'strikes' : 'strike'}!";
                          });
                        } else {
                          /* 
                          Calculation from input section 
                          */

                          //calculates accuracy
                          newaccuracy = double.parse(
                              (1 - noofstrike / 3).toStringAsFixed(2));
                          //If seconds = 0 then can't calculate speed and assign it to -314
                          newspeed = seconds == 0
                              ? -314
                              : double.parse(((noofbaseran * 60) / seconds)
                                  .toStringAsFixed(1));
                          //Assigns effectiveness based on the no. of base ran
                          if (noofbaseran != 4 && noofbaseran != 0) {
                            if (caughtout == 'Y') {
                              if (noofbaseran == 1) {
                                neweffect = 0.15;
                              }
                              if (noofbaseran == 2) {
                                neweffect = 0.45;
                              }
                              if (noofbaseran == 3) {
                                neweffect = 0.75;
                              }
                            } else {
                              if (noofbaseran == 1) {
                                neweffect = 0.30;
                              }
                              if (noofbaseran == 2) {
                                neweffect = 0.60;
                              }
                              if (noofbaseran == 3) {
                                neweffect = 0.90;
                              }
                            }
                          } else {
                            if (noofbaseran == 4) {
                              neweffect = 1;
                            } else {
                              neweffect = 0;
                            }
                          }
                          //Assigns 'distance' to 'newdistance'
                          newdistance = distance;

                          /*
                          Average Calculation Section 
                          */

                          //Calculates new average accuracy
                          avgaccuracy = double.parse(((acctotal + newaccuracy) /
                                  (mapacc.length +
                                      1 -
                                      count)) //Since if there is no change, n data would not increase by one
                              .toStringAsFixed(2));
                          //Calculates new average speed only if > 0
                          if (newspeed != -314) {
                            avgspeed = double.parse(((speedtotal + newspeed) /
                                    (noofspeed + 1 - count))
                                .toStringAsFixed(1));
                          } else {
                            avgspeed = studentdata?.speed;
                          }
                          //Calculates average distance
                          avgdistance = double.parse(
                              ((distancetotal + newdistance) /
                                      (mapdistance.length + 1 - count))
                                  .toStringAsFixed(1));
                          //Calculates average effect
                          avgeffect = double.parse(((effecttotal + neweffect) /
                                  (mapeffect.length + 1 - count))
                              .toStringAsFixed(2));

                          /* 
                          Date, Storing Data Input, and Finalizing data section
                          */

                          //Stores date input
                          dateinput = widget.dataList != null
                              ? widget.dateOfInputList[widget.index]
                              : DateFormat('yyyyMMdd').format(DateTime.now());

                          //Adds new data inputted or edit the data
                          if (widget.dataList == null) {
                            mapacc.add({dateinput: newaccuracy});
                            mapspeed.add({dateinput: newspeed});
                            mapdistance.add({dateinput: newdistance});
                            mapeffect.add({dateinput: neweffect});
                            mapdatainput.add({
                              dateinput: [
                                noofstrike,
                                seconds,
                                noofbaseran,
                                caughtout,
                                double.parse((posx).toStringAsFixed(2)),
                                double.parse((posy).toStringAsFixed(2))
                              ]
                            });
                          } else {
                            mapacc[widget.index] = ({dateinput: newaccuracy});
                            mapspeed[widget.index] = ({dateinput: newspeed});
                            mapdistance[widget.index] =
                                ({dateinput: newdistance});
                            mapeffect[widget.index] = ({dateinput: neweffect});
                            mapdatainput[widget.index] = ({
                              dateinput: [
                                noofstrike,
                                seconds,
                                noofbaseran,
                                caughtout,
                                double.parse((posx).toStringAsFixed(2)),
                                double.parse((posy).toStringAsFixed(2))
                              ]
                            });
                          }
                          //Updates new data inputted to the database
                          await DatabaseService(uid: widget.studentid)
                              .updateStudentStatsFromInput(
                                  mapacc,
                                  mapspeed,
                                  mapeffect,
                                  mapdistance,
                                  avgaccuracy,
                                  avgspeed!,
                                  avgeffect,
                                  avgdistance,
                                  mapdatainput);
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Form(
                  key: _formkey,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          color: Colors.grey[800],
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(minHeight: 78.0),
                                child: TextFormField(
                                    initialValue: widget.dataList != null
                                        ? widget.dataInputSelect[0]
                                        : null,
                                    style: TextStyle(color: Colors.amber),
                                    decoration: textInputDecoration.copyWith(
                                        hintText: 'No.of Strikes'),
                                    onChanged: (val) {
                                      try {
                                        int.parse(val);
                                        setState(() {
                                          noofstrike = int.parse(val);
                                          if (noofstrike == 3) {
                                            seconds = 0.0;
                                            noofbaseran = 0;
                                            caughtout = 'N';
                                          }
                                        });
                                      } catch (e) {
                                        setState(() {
                                          noofstrike = 0;
                                        });
                                      }
                                    },
                                    validator: (val) {
                                      if (val!.isNotEmpty) {
                                        try {
                                          noofstrike = int.parse(val);
                                          if (noofstrike < 0 ||
                                              noofstrike > 3) {
                                            return 'Please Enter a No. from 0-3';
                                          }
                                        } catch (e) {
                                          return 'Please Input an Integer!';
                                        }
                                      } else {
                                        return "Please Enter a Value!";
                                      }
                                      return null;
                                    }),
                              ),
                              SizedBox(height: 5.0),
                              //Text Form Field for Running Time
                              ConstrainedBox(
                                constraints: BoxConstraints(minHeight: 78.0),
                                child: TextFormField(
                                    initialValue: widget.dataList != null
                                        ? widget.dataInputSelect[1]
                                        : null,
                                    readOnly: noofstrike == 3 ? true : false,
                                    style: TextStyle(color: Colors.amber),
                                    decoration: textInputDecoration.copyWith(
                                        hintText: noofstrike == 3
                                            ? 'N/A'
                                            : 'Time in seconds',
                                        hintStyle: noofstrike == 3
                                            ? TextStyle(color: Colors.amber)
                                            : TextStyle(
                                                color: Color(0xFFBDBDBD))),
                                    onChanged: (val) {
                                      try {
                                        double.parse(val);
                                        seconds = double.parse(val);
                                      } catch (e) {}
                                    },
                                    validator: (val) {
                                      if (noofstrike != 3) {
                                        if (val!.isNotEmpty) {
                                          try {
                                            double.parse(val);
                                            if (double.parse(val) <= 0) {
                                              return 'Input a time greater than 0';
                                            }
                                          } catch (e) {
                                            return 'Please Input an Number!';
                                          }
                                        } else {
                                          return "Please Enter a Value!";
                                        }
                                      }
                                      return null;
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          color: Colors.grey[800],
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(minHeight: 78.0),
                                child: TextFormField(
                                    initialValue: widget.dataList != null
                                        ? widget.dataInputSelect[2]
                                        : null,
                                    readOnly: noofstrike == 3 ? true : false,
                                    style: TextStyle(color: Colors.amber),
                                    decoration: textInputDecoration.copyWith(
                                        hintText: noofstrike == 3
                                            ? '0'
                                            : 'No.of Base Ran',
                                        hintStyle: noofstrike == 3
                                            ? TextStyle(color: Colors.amber)
                                            : TextStyle(
                                                color: Color(0xFFBDBDBD))),
                                    onChanged: (val) {
                                      try {
                                        int.parse(val);
                                        noofbaseran = int.parse(val);
                                      } catch (e) {}
                                    },
                                    validator: (val) {
                                      if (noofstrike != 3) {
                                        if (val!.isNotEmpty) {
                                          try {
                                            noofbaseran = int.parse(val);
                                            if (noofbaseran < 0 ||
                                                noofbaseran > 4) {
                                              return 'Please Enter a No. from 0-4';
                                            }
                                          } catch (e) {
                                            return 'Please Input an Integer!';
                                          }
                                        } else {
                                          return "Please Enter a Value!";
                                        }
                                      }
                                      return null;
                                    }),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(minHeight: 78.0),
                                child: TextFormField(
                                    initialValue: widget.dataList != null
                                        ? widget.dataInputSelect[3]
                                        : null,
                                    readOnly: noofstrike == 3 ? true : false,
                                    style: TextStyle(color: Colors.amber),
                                    decoration: textInputDecoration.copyWith(
                                        hintText: noofstrike == 3
                                            ? 'N'
                                            : 'Caught Out?',
                                        hintStyle: noofstrike == 3
                                            ? TextStyle(color: Colors.amber)
                                            : TextStyle(
                                                color: Color(0xFFBDBDBD))),
                                    onChanged: (val) {
                                      caughtout = val.trim();
                                    },
                                    validator: (val) {
                                      if (noofstrike != 3) {
                                        if (val!.isNotEmpty) {
                                          if (val.trim() != 'Y' &&
                                              val.trim() != 'N') {
                                            return "Please enter either (Y/N)";
                                          }
                                        } else {
                                          return "Please enter either (Y/N)";
                                        }
                                      }
                                      return null;
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: Column(
                        children: [
                          Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: 15.0),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Divider(
                            color: Colors.grey[400],
                            indent: 8.0,
                            endIndent: 8.0,
                            height: 8.0,
                            thickness: 3.0,
                          ),
                          SizedBox(height: 5.0),
                          Center(
                            child: Text(
                              "Input Position of Ball Below by Tapping",
                              style: TextStyle(
                                  color: Colors.amber, fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  flex: 10,
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) =>
                        onTapDown(context, details),
                    onDoubleTap: () => onDoubleTap(),
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.green,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 45, bottom: 50),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 475,
                              width: 5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 50, right: 40),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 5,
                              width: 375,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 45, bottom: 50),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 240,
                              width: 240,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 5)),
                              child: Padding(
                                padding: const EdgeInsets.all(102.0),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.brown[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 293, right: 290),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 100,
                              height: 100,
                              child: CustomPaint(
                                painter: OpenPainter(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 45, bottom: 275),
                          child: Align(
                              alignment: Alignment.bottomRight, child: bases),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 270, bottom: 275),
                          child: Align(
                              alignment: Alignment.bottomRight, child: bases),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 270, bottom: 50),
                          child: Align(
                              alignment: Alignment.bottomRight, child: bases),
                        ),
                        Positioned(
                          child: Container(
                            height: 50,
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "$distance ft",
                                  style: TextStyle(
                                      color: changecolor == false
                                          ? Colors.green
                                          : Colors.black,
                                      fontSize: 13.0),
                                ),
                                SizedBox(height: 5.0),
                                ClipOval(
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    color: changecolor == false
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          left: posx - 50,
                          top: posy - 28,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    //draw arc
    canvas.drawArc(
        Offset(0, 0) & Size(400, 400),
        (3 * pi) / 4, //radians
        pi, //radians
        false,
        paint1);
    canvas.drawArc(
        Offset(280.8, 280.8) & Size(118.4, 118.4),
        pi, //radians
        pi / 2, //radians
        false,
        paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
