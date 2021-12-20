import 'dart:convert';

import 'package:dashboard/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'constant.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'dart:math' as math;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
//linechart
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;

  Future<void> fetchLatestRecord() async {
   final response = await http
      .get(
        Uri.http("192.168.1.9:8080","latestrecords")
      );

  if(response.statusCode == 200)
  {
    var jsonData = jsonDecode(response.body);
    //print(jsonData);
    setState(() {
      temp = double.parse(jsonData["Temp"]);
      humdity = double.parse(jsonData["humidity"]);
      pressure = double.parse(jsonData["Pressure"]);
    });
  }
  else{
    throw Exception('Failed to load data');
  }
}

  @override
  void initState() {
    chartData = getChartData();
    //Timer.periodic(const Duration(seconds: 1),updateDataSource);
    fetchLatestRecord();
    super.initState();
  }
//linechartend

  Material MyItems(String heading, int color, String type, double val) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      shadowColor: Color(0x802196F3),
      borderRadius: BorderRadius.circular(24.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //text
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        heading,
                        style:
                            TextStyle(color: new Color(color), fontSize: 20.0),
                      ),
                    ),
                  ),
                  //icon
                  type == gaugeGraph
                      ? Center(
                          child: SafeArea(
                            child: SfRadialGauge(
                              // title: GaugeTitle(
                              //    text: 'Speedometer',
                              //   textStyle: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                              // ),
                              enableLoadingAnimation: true,
                              animationDuration: 4500,
                              axes: <RadialAxis>[
                                RadialAxis(
                                  minimum: 0,
                                  maximum: 150,
                                  //pointers:<GaugePointer>[WidgetPointer(value:90)],
                                  // pointers:<GaugePointer>[RangePointer(value: 90,enableAnimation: true,)],
                                  //pointers:<GaugePointer>[MarkerPointer(value: 90,enableAnimation: true,)],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                      value: val,
                                      enableAnimation: true,
                                    )
                                  ],
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                        startValue: 0,
                                        endValue: 50,
                                        color: Colors.green),
                                    GaugeRange(
                                        startValue: 50,
                                        endValue: 100,
                                        color: Colors.orange),
                                    GaugeRange(
                                        startValue: 100,
                                        endValue: 150,
                                        color: Colors.red)
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                      widget: Text(
                                        val.toString() +' MPH',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      positionFactor: 0.5,
                                      angle: 90,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
//linechart
                  type == linechart
                      ? Center(
                          child: SafeArea(
                            child: SfCartesianChart(
                              series: <LineSeries<LiveData, int>>[
                                LineSeries<LiveData, int>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    _chartSeriesController = controller;
                                  },
                                  dataSource: chartData,
                                  color: const Color.fromARGB(192, 108, 132, 1),
                                  xValueMapper: (LiveData sales, _) =>
                                      sales.time,
                                  yValueMapper: (LiveData sales, _) =>
                                      sales.speed,
                                ),
                              ],
                              primaryXAxis: NumericAxis(
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                  interval: 3,
                                  title: AxisTitle(text: 'Time(seccond)')),
                              primaryYAxis: NumericAxis(
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                title: AxisTitle(text: 'Internet speed(Mbps)'),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StaggeredGridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          MyItems("Temperature", 0xffed622b, gaugeGraph, temp),
          MyItems("Humidity", 0xff26cb3c, gaugeGraph , humdity),
          MyItems("Pressure", 0xffff3266, gaugeGraph, pressure),
          // MyItems("Graph", 0xff3399fe, linechart , 0),
          // MyItems("Graph", 0xfff4c83f, linechart , 0),
          // MyItems("Graph", 0xfff4c83f, linechart, 0),
          // MyItems("Table", 0xfff4c83f, "Yas", 0),
        ],
        staggeredTiles: [
          StaggeredTile.extent(1, 450.0),
          StaggeredTile.extent(1, 450.0),
          StaggeredTile.extent(1, 450.0),
          // StaggeredTile.extent(1, 450.0),
          // StaggeredTile.extent(1, 450.0),
          // StaggeredTile.extent(1, 450.0),
          // StaggeredTile.extent(3, 650.0),
        ],
      ),
    );
  }
}

// nav bar
class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final isCollapse = false;

    return Container(
      child: Drawer(
        child: Container(
          color: Color(0xff1a2f45),
          child: Column(
            children: [
              buildHeader(isCollapse),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(bool isCollapse) => Row(children: [
        const SizedBox(width: 24),
        FlutterLogo(size: 48),
        const SizedBox(width: 16),
        Text(
          'Demo',
          style: TextStyle(fontSize: 32, color: Colors.white),
        ),
      ]);
}

//navbar end

//linechart

// int time=19;
// void updateDataSource(Timer timer){
//   chartData.add(LiveData(time++, (math.Random().nextInt(60)+30)));
//   chartData.removeAt(0);
//   _chartSeriesController.updateDataSource(
//    addedDataIndex: chartData.length-1,
//     removedDataIndex: 0,
//   );
// }

List<LiveData> getChartData() {
  return <LiveData>[
    LiveData(0, 42),
    LiveData(1, 47),
    LiveData(2, 43),
    LiveData(3, 49),
    LiveData(4, 54),
    LiveData(5, 41),
    LiveData(6, 58),
    LiveData(7, 51),
    LiveData(8, 98),
    LiveData(9, 41),
    LiveData(10, 53),
    LiveData(11, 72),
    LiveData(12, 86),
    LiveData(13, 52),
    LiveData(14, 94),
    LiveData(15, 92),
    LiveData(16, 86),
    LiveData(17, 42),
    LiveData(18, 94),
  ];
}

class LiveData {
  int speed, time;
  LiveData(this.time, this.speed);
}
//linechart end
