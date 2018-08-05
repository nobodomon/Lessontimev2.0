import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' ;
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/StudPages/ViewModuleAttendance.dart';
import 'package:lessontime/models/Model.dart';

class UserLesson extends StatefulWidget {
  final FirebaseUser fbUser;
  final Users user;

  UserLesson(this.fbUser, this.user);

  @override
  State<StatefulWidget> createState() => new _UserLessonState(fbUser, user);
}

class _UserLessonState extends State<UserLesson> {
  FirebaseUser fbUser;
  Users user;
  _UserLessonState(this.fbUser, this.user);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new FutureBuilder(
      future: FirebaseLink.getModulesTakenByStudent(user.adminNo),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Assets.loader();
        } else {
          return new Scaffold(
            backgroundColor: Colors.indigo,
            body: new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot data) {
                return moduleAttendance(
                    data.data["moduleName"], user.adminNo.toUpperCase());
              }).toList(),
            )
          );
        }
      },
    );
  }

  Widget moduleAttendance(String module, String adminNo) {
    FirebaseLink fbLink = new FirebaseLink();
    return new FutureBuilder(
      future: fbLink.getClassAttendanceOfUserByModule(adminNo, module),
      builder: (BuildContext context, AsyncSnapshot<Attendance> snapshot) {
        if (!snapshot.hasData) {
          return new Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: new ListTile(
                leading: new Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                    border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24)
                    )
                  ),
                  child: Icon(Icons.class_, color: Colors.indigoAccent,),
                ),
                title: new LinearProgressIndicator(),
                subtitle: new Text("Loading..."),
              )
            ),);
        } else if(snapshot.data.lessonsAbsent == 0 &&
            snapshot.data.lessonsAttended == 0 &&
            snapshot.data.lessonsLate == 0) {
          Attendance attendanceInfo = new Attendance(snapshot.data.lessonsAbsent, snapshot.data.lessonsAttended, snapshot.data.lessonsLate);
          return new Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: new ListTile(
                leading: new Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                    border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24)
                    )
                  ),
                  child: Icon(Icons.class_, color: Colors.indigoAccent,),
                ),
                title: new Text(module),
                subtitle: new Text("No module information."),
                trailing: IconButton(
                  icon: Icon(Icons.keyboard_arrow_right, color: Colors.indigoAccent,size: 30.0,),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewModuleAttendance(user.adminNo,module,attendanceInfo))), 
                ),
              )
            ),);
        } else {
          Attendance attendanceInfo = new Attendance(snapshot.data.lessonsAbsent, snapshot.data.lessonsAttended, snapshot.data.lessonsLate);
          return new Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: new ListTile(
                leading: new Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                    border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24)
                    )
                  ),
                  child: Icon(Icons.class_, color: Colors.indigoAccent,),
                ),
                title: new Text(module),
                subtitle: new Row(
                  children: <Widget>[
                    Icon(Icons.done, color:Colors.greenAccent,size: 15.0,),
                    new Text("  " + attendanceInfo.lessonsAttended.toString()),
                    RotatedBox(quarterTurns: 1,child: Divider(color: Colors.indigoAccent,),),
                    Icon(Icons.access_alarm, color: Colors.amberAccent, size: 15.0,),
                    new Text("  " + attendanceInfo.lessonsLate.toString()),
                    RotatedBox(quarterTurns: 1,child: Divider(),),
                    Icon(Icons.help_outline,color: Colors.redAccent,size: 15.0,),
                    new Text("  " + attendanceInfo.lessonsAbsent.toString()),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.keyboard_arrow_right, color: Colors.indigoAccent,size: 30.0,),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewModuleAttendance(user.adminNo,module,attendanceInfo))), 
                ),
              )
            ),
          );
        }
      },
    );
  }

  static List<charts.Series<AttendanceSection, String>> createData(
      int hosted, int attended, int late) {
    print(hosted.toString() + " - absent");
    print(attended.toString() + " - attended");
    print(late.toString() + " - late");
    final data = [
      new AttendanceSection("Attended", attended),
      new AttendanceSection("Late", late),
      new AttendanceSection("Absent", hosted),
    ];
    return [
      new charts.Series<AttendanceSection, String>(
        id: "Module Attendance",
        data: data,
        domainFn: (AttendanceSection info, _) => info.title,
        measureFn: (AttendanceSection info, _) => info.count,
        labelAccessorFn: (AttendanceSection row, _) =>
            '${row.title}: ${row.count}',
      )
    ];
  }
}

class AttendanceSection {
  String title;
  int count;

  AttendanceSection(this.title, this.count);
}
