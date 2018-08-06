import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/models/Model.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/FirebaseLink.dart';

class HomePanel extends StatefulWidget{
  HomePanel(this.fbUser);
  final FirebaseUser fbUser;
  @override
  State<StatefulWidget> createState() =>new _HomePanelState(fbUser);

}

class _HomePanelState extends State<HomePanel>{
  _HomePanelState(this.fbuser);
  FirebaseUser fbuser;
  Users nUser;
  //final BaseAuth _auth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getUser();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseLink.getUserOnceFs(fbuser.email),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        if(snapshot.hasData){
          nUser = Users.fromSnapshot(snapshot.data);
          return new Scaffold(
            backgroundColor: Colors.white,
            body: new ListView(
              children: <Widget>[
                new Container(
                  color: Colors.indigo,
                  child: Center(
                    child: new Logo(250.0,"lib/Assets/LessonTime.png"),
                  ),
                ),
                new ListTile(
                  leading: new Icon(Icons.person, color: Colors.indigoAccent,),
                  title: const Text("Welcome back"),
                  subtitle: Text(nUser.adminNo),
                ),
                new Divider(),
              ],
            )
          );
        }else{
          return Assets.loader();
        }
      });
  }
}