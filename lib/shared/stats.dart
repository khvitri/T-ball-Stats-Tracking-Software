import 'package:cstballprogram/models/user.dart';
import 'package:cstballprogram/screens/teacher/input/InputData.dart';
import 'package:cstballprogram/shared/constant.dart';
import 'package:cstballprogram/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cstballprogram/models/datapoints.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  //The Options User Could Select To Filter Data Based on Different Dates
  final dataperiod = [
    '30-days Average',
    '60-days Average',
    '90-days Average',
    '180-days Average',
    '365-days Average',
    'All-time Average',
  ];

  //The Options User Could Select To View What Specific Visual Data They Would Like To See
  final datadisplayed = ['Ball Location', 'Effectiveness', 'Accuracy', 'Speed'];

  //Initial Selected Data Displayed Is "Ball Location"
  String? selecteddatadisplayed = 'Ball Location';

  //Initial Selected Period Is "30-days Average"
  String? selectedperiod = '30-days Average';

  //Filter Function
  List filter(int selectedperiod, data) {
    var filter = [];
    try {
      DateTime latestdate = DateTime.parse(data[0]
          .keys
          .toString()
          .substring(1, data.last.keys.toString().length - 1));
      //If Selected Period Is Not "All-Time" Then The FOR LOOP Will Proceed To Filter Out The Data
      if (selectedperiod != 1000) {
        for (var z = 0; z < data.length; z++) {
          if (latestdate
                  .difference(DateTime.parse(data[z]
                      .keys
                      .toString()
                      .substring(1, data[z].keys.toString().length - 1)))
                  .inDays
                  .abs() <=
              selectedperiod) {
            filter.add(data[z]);
          }
        }
        return filter;
      } else {
        return data;
      }
    } catch (e) {
      return data;
    }
  }

  //Averages The Data
  double average(data) {
    double total = 0.0;
    int n = 0;
    for (var z = 0; z < data.length; z++) {
      double value = double.parse(data[z]
          .values
          .toString()
          .substring(1, data[z].values.toString().length - 1));
      //If The Speed Value Is Not "N/A" Which Is Equivalent To Saying "-314", Then "total" Will Be Added As Well As "n"
      if (value != -314) {
        total += value;
        n++;
      }
    }
    //Returns The Average
    return (total / n);
  }

  //Converting Data Into A Data Point Model To Be Displayed On The Graph
  List<StatsData>? convertToStatData(data) {
    //Contains The Converted Version Of The Data
    List<StatsData> statdatalist = [];

    //Contains A List Of Non-Overlapping Dates From The Data
    List<DateTime> recordeddates = [];

    //FOR LOOP To Loop Through The Dates Of The Data
    for (var x in data) {
      DateTime date = DateTime.parse(
          x.keys.toString().substring(1, x.keys.toString().length - 1));

      //IF Function To Prevent Data Point Inputted On The Same Day To Overlap
      if (!recordeddates.contains(date)) {
        recordeddates.add(date);
        double total = 0.0;
        int n = 0;

        //FOR LOOP To Find Overlapping Dates And Average Them
        for (var z in data) {
          DateTime compare = DateTime.parse(
              z.keys.toString().substring(1, z.keys.toString().length - 1));
          if (date == compare &&
              double.parse(z.values
                      .toString()
                      .substring(1, z.values.toString().length - 1)) !=
                  -314) {
            total += double.parse(z.values
                .toString()
                .substring(1, z.values.toString().length - 1));
            n++;
          }
        }
        statdatalist
            .add(StatsData(date, double.parse((total / n).toStringAsFixed(1))));
      }
    }
    return statdatalist;
  }

  @override
  Widget build(BuildContext context) {
    final studentdata = Provider.of<StudentData?>(context);
    final datainput = studentdata?.datainput;
    final provacc = studentdata?.accList;
    final provspeed = studentdata?.speedList;
    final provdistance = studentdata?.distanceList;
    final proveffect = studentdata?.effectList;
    var balllocation = [];
    double? avgaccuracy = 0.0;
    double? avgspeed = 0.0;
    double? avgdistance = 0.0;
    double? avgeffect = 0.0;
    var graphacc;
    var graphspeed;
    var grapheffect;

    //Get Data Function To Combine All Functions Above And Prevent Duplication Of Code
    void getData(int days) {
      for (var x in filter(days, datainput)) {
        balllocation.add(x.values
            .toString()
            .substring(2, x.values.toString().length - 2)
            .split(','));
      }
      avgaccuracy =
          double.parse((average(filter(days, provacc))).toStringAsFixed(2));
      avgspeed =
          double.parse((average(filter(days, provspeed))).toStringAsFixed(1));
      avgdistance = double.parse(
          (average(filter(days, provdistance))).toStringAsFixed(1));
      avgeffect =
          double.parse((average(filter(days, proveffect))).toStringAsFixed(2));
      graphacc = convertToStatData(filter(days, provacc));
      graphspeed = convertToStatData(filter(days, provspeed));
      grapheffect = convertToStatData(filter(days, proveffect));
    }

    if (studentdata == null) {
      return Loading();
    } else {
      if (selectedperiod == '30-days Average') {
        getData(30);
      }
      if (selectedperiod == '60-days Average') {
        getData(60);
      }
      if (selectedperiod == '90-days Average') {
        getData(90);
      }
      if (selectedperiod == '180-days Average') {
        getData(180);
      }
      if (selectedperiod == '365-days Average') {
        getData(365);
      }
      if (selectedperiod == 'All-time Average') {
        getData(1000);
      }

      return Column(
        children: [
          Container(
              padding: EdgeInsets.all(8.0),
              height: 50,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    value: selecteddatadisplayed,
                    onChanged: (String? value) {
                      setState(() {
                        selecteddatadisplayed = value;
                      });
                    },
                    items: datadisplayed.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 40.0),
                  DropdownButton(
                    value: selectedperiod,
                    onChanged: (String? value) {
                      setState(() {
                        selectedperiod = value;
                      });
                    },
                    items: dataperiod.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              )),
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            height: 199.5,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Text(
                      'Accuracy',
                      style: lato.copyWith(fontSize: 25.0),
                    ),
                    Text(
                      '${double.parse((avgaccuracy! * 100).toStringAsFixed(1))} %',
                      style: lato.copyWith(fontSize: 30.0),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(
                      'Speed',
                      style: lato.copyWith(fontSize: 25.0),
                    ),
                    Text('${avgspeed!} ft/s',
                        style: lato.copyWith(fontSize: 30.0))
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                    Text(
                      'Effectiveness',
                      style: lato.copyWith(fontSize: 25.0),
                    ),
                    Text(
                      '${double.parse((avgeffect! * 100).toStringAsFixed(2))} %',
                      style: lato.copyWith(fontSize: 30.0),
                    ),
                    SizedBox(height: 40.0),
                    Text('Distance', style: lato.copyWith(fontSize: 25.0)),
                    Text('${avgdistance!} ft',
                        style: lato.copyWith(fontSize: 30.0))
                  ],
                )),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Divider(
              color: Colors.black,
              height: 3,
              thickness: 3,
              endIndent: 10.0,
              indent: 10.0,
            ),
          ),
          Container(
            color: Colors.white,
            height: 5.0,
          ),
          if (selecteddatadisplayed == 'Ball Location') //T-ball field
            Expanded(
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
                            border: Border.all(color: Colors.white, width: 5)),
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
                    padding: const EdgeInsets.only(bottom: 293, right: 290),
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
                    padding: const EdgeInsets.only(right: 45, bottom: 275),
                    child:
                        Align(alignment: Alignment.bottomRight, child: bases),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 270, bottom: 275),
                    child:
                        Align(alignment: Alignment.bottomRight, child: bases),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 270, bottom: 50),
                    child:
                        Align(alignment: Alignment.bottomRight, child: bases),
                  ),
                  for (var index = 0; index < balllocation.length; index++)
                    Positioned(
                      child: ClipOval(
                        child: Container(
                          height: 20,
                          width: 20,
                          color: int.parse(balllocation[index][2]) == 4
                              ? Colors.amber
                              : int.parse(balllocation[index][2]) == 3
                                  ? Colors.cyan
                                  : int.parse(balllocation[index][2]) == 2
                                      ? Colors.pink
                                      : int.parse(balllocation[index][2]) == 1
                                          ? Colors.purple
                                          : Colors.red,
                        ),
                      ),
                      left: double.parse(balllocation[index][4]),
                      top: double.parse(balllocation[index][5]),
                    ),
                ],
              ),
            ),
          if (selecteddatadisplayed == 'Effectiveness' ||
              selecteddatadisplayed == 'Accuracy' ||
              selecteddatadisplayed == 'Speed')
            Expanded(
                child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                        edgeLabelPlacement: EdgeLabelPlacement.shift),
                    primaryYAxis: NumericAxis(
                        maximum: selecteddatadisplayed == 'Effectiveness' ||
                                selecteddatadisplayed == 'Accuracy'
                            ? 1
                            : null,
                        numberFormat:
                            selecteddatadisplayed == 'Effectiveness' ||
                                    selecteddatadisplayed == 'Accuracy'
                                ? NumberFormat.percentPattern()
                                : NumberFormat.decimalPattern()),
                    series: <ChartSeries>[
                  // Renders line chart
                  LineSeries<StatsData, DateTime>(
                      dataSource: selecteddatadisplayed == 'Effectiveness'
                          ? grapheffect
                          : selecteddatadisplayed == 'Accuracy'
                              ? graphacc
                              : graphspeed,
                      xValueMapper: (StatsData stats, _) => stats.date,
                      yValueMapper: (StatsData stats, _) => stats.stat)
                ]))
        ],
      );
    }
  }
}
