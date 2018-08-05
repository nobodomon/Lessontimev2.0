import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lessontime/LectPages/LessonDetails.dart';
import 'package:lessontime/models/Model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SearchLesson.dart';
import 'package:lessontime/Logo.dart';

class Lessons extends StatefulWidget{
  final Users user;
  final FirebaseUser fbUser;
  Lessons(this.fbUser, this.user);
  @override
  State<StatefulWidget> createState() => new _LessonsState(fbUser,user);
}

class _LessonsState extends State<Lessons>{
  Users user;
  FirebaseUser fbUser;
  _LessonsState(this.fbUser, this.user);
  @override
  Widget build(BuildContext context) {
    Color select = Colors.indigo[400];
    return new Scaffold(
      backgroundColor: Colors.indigo,
      body: new Center(
        child: Card(
          margin: EdgeInsets.all(50.0),
          color: Colors.white,
          child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Logo(150.0,"lib/Assets/StartClass.png"),
                new Center(
                  child: new Text("Start a class", style: TextStyle(fontWeight: FontWeight.w900),),
                ),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new RaisedButton(
                            textColor: Colors.white,
                            color: select,
                            padding: EdgeInsets.all(15.0),
                            shape: StadiumBorder(
                            ),
                            key: new Key('register'),
                            child: new Text('Create'),
                            onPressed:()=> confirmStart(context)
                          )
                        ],
                        
                      ),
                  )
              ]
          )
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigoAccent,
              onPressed: ((){
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SearchLesson(user.adminNo)),
                );
              }),
              child: new Icon(Icons.search),
            ),
    );
  }

  Future<Null> confirmStart(BuildContext context) async{
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirmation"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("Are you sure you want to start a class?"),
              ),
            new FlatButton( 
               onPressed:((){
                Navigator.pop(context);
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LessonDetails(user)),
                );
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.red),),
            )
          ],
        )
      )
    ){}
  }
}