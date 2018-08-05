import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:lessontime/StudPages/UserLessons.dart';
import 'package:lessontime/models/Model.dart';

class ViewModuleAttendance extends StatefulWidget{
  final String adminNo;
  final String module;
  final Attendance attendanceInfo;
  ViewModuleAttendance(this.adminNo,this.module,this.attendanceInfo);
  @override
  State<StatefulWidget> createState() => new _ViewModuleAttendanceState(adminNo,module,attendanceInfo);
}

class _ViewModuleAttendanceState extends State<ViewModuleAttendance>{
  String adminNo;
  String module;
  Attendance attendanceInfo;
  _ViewModuleAttendanceState(this.adminNo,this.module,this.attendanceInfo);
  @override
  Widget build(BuildContext context){
  int totalLessons = attendanceInfo.lessonsAttended + attendanceInfo.lessonsLate + attendanceInfo.lessonsAbsent;
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: Icon(Icons.keyboard_arrow_down,color: Colors.indigoAccent,),
          onPressed:()=>Navigator.pop(context),
        ),
        title: new Text(module, style: new TextStyle(color: Colors.indigoAccent),),
        
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        
        children: <Widget>[
          new Container(
            padding: EdgeInsets.all(25.0),
            width: 250.0,
            height: 250.0,
            child: new charts.BarChart(createData(attendanceInfo), animate: true, vertical: true, 
              defaultRenderer: new charts.BarRendererConfig(
                groupingType: charts.BarGroupingType.grouped, strokeWidthPx: 0.0,
              ),
            ),
          ),
          new Divider(),
          new ListTile(
            leading: Icon(Icons.check, color: Colors.green,),
            title: new Text("Lessons Attended "),
            subtitle: new Text(attendanceInfo.lessonsAttended.toString() + " out of " + totalLessons.toString() + " lessons."),
          ),
          new Divider(),
          new ListTile(
            leading: Icon(Icons.access_alarm, color: Colors.amber,),
            title: new Text("Lessons Late "),
            subtitle: new Text(attendanceInfo.lessonsLate.toString() + " out of " + totalLessons.toString() + " lessons."),
          ),
          new Divider(),
          new ListTile(
            leading: Icon(Icons.help, color: Colors.red),
            title: new Text("Lessons Absent "),
            subtitle: new Text(attendanceInfo.lessonsAbsent.toString() + " out of " + totalLessons.toString() + " lessons."),
          ),
          new Divider(),
        ],
      ),
    );
  }

  static List<charts.Series<AttendanceSection, String>> createData(
      Attendance attendanceInfo) {
    final attendedData = [
      new AttendanceSection("Attended", attendanceInfo.lessonsAttended),
    ];
    final lateData = [
      new AttendanceSection("Late", attendanceInfo.lessonsLate),
    ];
    final absentData = [
      new AttendanceSection("Absent", attendanceInfo.lessonsAbsent),
    ];
    return [
      new charts.Series<AttendanceSection, String>(
        id: "Module Attendance",
        data: attendedData,
        domainFn: (AttendanceSection info, _) => info.title,
        measureFn: (AttendanceSection info, _) => info.count,
        labelAccessorFn: (AttendanceSection row, _) =>
            '${row.title}: ${row.count}',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
      new charts.Series<AttendanceSection, String>(
        id: "Module Attendance",
        data: lateData,
        domainFn: (AttendanceSection info, _) => info.title,
        measureFn: (AttendanceSection info, _) => info.count,
        labelAccessorFn: (AttendanceSection row, _) =>
            '${row.title}: ${row.count}',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
      ),
      new charts.Series<AttendanceSection, String>(
        id: "Module Attendance",
        data: absentData,
        domainFn: (AttendanceSection info, _) => info.title,
        measureFn: (AttendanceSection info, _) => info.count,
        labelAccessorFn: (AttendanceSection row, _) =>
            '${row.title}: ${row.count}',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,

      )
    ];
  }
}