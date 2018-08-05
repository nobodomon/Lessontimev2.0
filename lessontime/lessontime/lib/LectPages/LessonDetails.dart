import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/LectPages/ViewLesson.dart';
import 'package:lessontime/models/Model.dart';

class LessonDetails extends StatefulWidget{
  final Users usr;
  LessonDetails(this.usr);
  @override
  State<StatefulWidget> createState() => new _LessonDetailsState(usr);

}

class _LessonDetailsState extends State<LessonDetails>{
  Users usr;
  _LessonDetailsState(this.usr);
  static final formKey = new GlobalKey<FormState>();
  TextEditingController moduleNameCtrl = new TextEditingController();
  TextEditingController courseIDCtrl = new TextEditingController();
  List<String> _schoolList = <String>[
    "SBM","SCL","SDN","SEG","SHS","SIT","SIDM","GSM","PFP"
  ];
  String lectIC;
  String _authHint = "";
  String _school;
  String _courseID;
  String _moduleName;
  Future<QuerySnapshot> courseList; 
  FirebaseLink fblink = new FirebaseLink();

  @override
  void dispose() {
    // TODO: implement dispose
    moduleNameCtrl.dispose();
    courseIDCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        title: new Text("Enter Class Details"  ,
          style: new TextStyle(color: Colors.indigoAccent)),
        leading:new FlatButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_downward, color: Colors.indigoAccent,),
        ),
        elevation: 0.0,
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: ()=> setState(() {
                final form = formKey.currentState;
                form.reset();
                courseIDCtrl.text = "";
                moduleNameCtrl.text = "";
            }),
            tooltip: "Clear All Fields",
          )
        ],
      ),
      body:new SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            
            new Form(
              key: formKey,
              onChanged: (){
                setState(() {
                  
                  final form = formKey.currentState;
                  form.save();
                });
              },
              child: new Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: fieldColumn(context),
                ),
              ) 
            )
          ],
        ),
      )
    );
  }

  List<Widget> fieldColumn(BuildContext detailsContext){
    return <Widget>[
      schoolField(),
      Divider(),
      courseField(),
      Divider(),
      allCourse(),
      Divider(),
      moduleNameField(),
      Divider(),
      allModules(),
      Divider(),
      padded(child: new RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
            padding: EdgeInsets.all(15.0),
            shape: StadiumBorder(
            ),
            key: new Key('register'),
            child: new Text('Create'),
            onPressed:()=> validateAndSubmit(context)
          )),
    ];
  }

  Widget schoolField() {
    Color select = Colors.indigo[400];
    return padded(
      child: new TextFormField(
        style: new TextStyle(color: Colors.white),
        key: new Key('School'),
        decoration: new InputDecoration(
          isDense: true,
          helperText: "SBM,SDN,SEG,SIDM...",
          hintText: "School e.g. [SBM, SDN, SEG, SIDM...]",
          hintStyle: new TextStyle(
            color: Colors.white30
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label,color: Colors.white,),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        autovalidate: true,
        validator: (val){
          val.isEmpty ? 'School can\'t be empty.' : null;
          if(_schoolList.contains(val.toUpperCase())){
            return null;
          }else{
            return "Invalid school input.";
          }
        },
        onSaved: (val){
          setState(() {
            _school = val.toUpperCase();
          });
        } ,
      )
    );
  }
  
  Widget allCourse(){
    return FutureBuilder(
      future: FirebaseLink.getAllCourses(_school),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> sc){
        if(!sc.hasData || sc.data.documents.length == 0){
          return new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new LinearProgressIndicator(),
              new Padding(
                child: new Text("Loading...", textAlign: TextAlign.right,),
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              )
            ],
          );
        }else{
          return new Container(
            height: 100.0,
            child: ListView(
              cacheExtent: 0.0,
              children: sc.data.documents.map((DocumentSnapshot snapshot){
                return new Column(
                  children: <Widget>[
                    new ListTile(
                      dense: true,
                      leading: Icon(Icons.school,color: Colors.indigoAccent,),
                      title: new Text(snapshot.documentID),
                      subtitle: new Text(snapshot["courseName"]),
                      onTap: (){
                        setState(() {
                          courseIDCtrl.text = snapshot.documentID;
                          moduleNameCtrl.text = "";
                          _courseID = snapshot.documentID;
                        });
                      },
                    ),
                    new Divider(),
                  ],
                );
              }).toList(),
            )
          );
        }
      }
    );
  }

  Widget allModules(){
    return FutureBuilder(
      future: FirebaseLink.getCourseModules(_school, _courseID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> sc){
        if(!sc.hasData || courseIDCtrl.text == "" || sc.data.documents.length == 0){
          return new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new LinearProgressIndicator(),
              new Padding(
                child: new Text("Loading...", textAlign: TextAlign.right,),
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              )
            ],
          );
        }else{
          return new Container(
            height: 100.0,
            child: ListView(
              cacheExtent: 0.0,
              children: sc.data.documents.map((DocumentSnapshot snapshot){
                return new Column(
                  children: <Widget>[
                    new ListTile(
                      dense: true,
                      leading: Icon(Icons.class_,color: Colors.indigoAccent,),
                      title: new Text(snapshot.documentID),
                      onTap: (){
                        setState(() {
                          moduleNameCtrl.text = snapshot.documentID;
                          _moduleName = snapshot.documentID;      
                        });
                      },
                    ),
                    new Divider(),
                  ],
                );
              }).toList(),
            )
          );
        }
      }
    );
  }

  Widget courseField() {
    Color select = Colors.indigo[400];
    return padded(
      child: new TextFormField(

      controller: courseIDCtrl,
        style: new TextStyle(color: Colors.white),
        key: new Key('CourseID'),
        enabled: false,
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Course ID",
          hintStyle: new TextStyle(
            color: Colors.white30
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label,color: Colors.white,),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Course ID can\'t be empty.' : null,
        
        onSaved: (val){
          _courseID = val;
        }
      )
    );
  }

  Widget moduleNameField() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        style: new TextStyle(color: Colors.white),
        key: new Key('ModuleName'),
        controller: moduleNameCtrl,
        enabled: false,
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Module Name",
          hintStyle: new TextStyle(
            color: Colors.white30
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label,color: Colors.white,),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Module name can\'t be empty.' : null,
        onSaved: (val) => _moduleName = val,
      )
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        try {
          confirmStart(context);
        }catch(error){
          print(error);
        }
        
      }catch (e) {
        setState(() {
          _authHint = 'Creation Error\n\n${e.toString()}';
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
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
              child: new Text("Are you sure the information is correct?"),
              ),
            new FlatButton( 
               onPressed:((){
                FirebaseLink.startClass(usr.adminNo,_school,_courseID,_moduleName).then((AddClassModel result){
                  if(result.success){
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewLesson(result.lessonID,usr.adminNo)));
                  }else{
                    Navigator.pop(context);
                    errorDialog(_school,_courseID,_moduleName);
                  }
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.red),),
            )
          ],
        )
      )
    ){}
  }
  Future<Null> errorDialog(String school, String courseID, String module) async{
    switch(
      await showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Error!", style: new TextStyle(color: Colors.red,),),
          content: new Text(module + " from " + courseID + " in " + school + " was not found!"),
          
        )
      )
    ){}
  }
}