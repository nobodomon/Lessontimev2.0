import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/auth.dart';

class AddStud extends StatefulWidget {
  AddStud({Key key, this.title, this.auth}) : super(key: key);

  final String title;
  final BaseAuth auth;

  @override
  _AddStudState createState() => new _AddStudState();
}

enum FormType {
  login,
  register
}

class _AddStudState extends State<AddStud> {
  static final studKey = new GlobalKey<FormState>();
  String _school;
  String _courseID;
  String _moduleGrp;
  TextEditingController courseIDCtrl = new TextEditingController();
  TextEditingController moduleGrpCtrl = new TextEditingController();
  String _adminNo;
  String _email;
  String _authHint = '';
  List<String> _schoolList = <String>[
    "SBM","SCL","SDN","SEG","SHS","SIT","SIDM","GSM","PFP"
  ];

  bool validateAndSave() {
    final form = studKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        await widget.auth.createUser(_adminNo,_email, _email,0, false).then((String str){
          if(str == null || str.isEmpty){
            
          }else{
            FirebaseLink.setUserSchoolAndCourse(_adminNo, _school, _courseID,_moduleGrp);
            final form = studKey.currentState;
            setState(() {
              _moduleGrp = "";
              moduleGrpCtrl.text = "";
              _courseID = "";
              courseIDCtrl.text = "";
              form.reset();
              _authHint = 'Student Created\n\nUser id: $str';
              SnackBar bar = new SnackBar(content:new Text('Student Created\n\nUser id: $str'),);
              Scaffold.of(context).showSnackBar(bar);
            });
          }
        });
        
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

  Widget username() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
      style: new TextStyle(color: Colors.white),
        key: new Key('Admin number'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Admin Number",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.group_add),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Admin Number can\'t be empty.' : null,
        onSaved: (val){
          _adminNo = val;
          _email = val + "@mymail.nyp.edu.sg";
        }
      )
    );
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
                          _courseID = snapshot.documentID;
                          courseIDCtrl.text = snapshot.documentID;
                          _moduleGrp = "";
                          moduleGrpCtrl.text = "";
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

Widget moduleGrpField() {
    Color select = Colors.indigo[400];
    return padded(
      child: new TextFormField(

      controller: moduleGrpCtrl,
        style: new TextStyle(color: Colors.white),
        key: new Key('moduleGrp'),
        enabled: false,
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Module Group",
          hintStyle: new TextStyle(
            color: Colors.white30
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label,color: Colors.white,),
          ),
          suffixIcon: new IconButton(
            icon: Icon(Icons.clear),
            padding: EdgeInsets.only( left: 8.0),
            onPressed: ()=>setState(() {
              moduleGrpCtrl.text = "";
            }),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Module Group can\'t be empty.' : null,
        
        onSaved: (val){
          _moduleGrp = val;
        }
      )
    );
  }


    Widget allModuleGrp(){
    return FutureBuilder(
      future: FirebaseLink.getCourseGrps(_school,_courseID),
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
                      onTap: (){
                        setState(() {
                          _moduleGrp = snapshot.documentID;
                          moduleGrpCtrl.text = snapshot.documentID;
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


  Widget submitWidgets(BuildContext context){
    Color select = Colors.indigo[400];
    return new FlatButton(
        textColor: Colors.white,
          color: select,
          padding: EdgeInsets.all(15.0),
          shape: StadiumBorder(
          ),
        key: new Key('register'),
        child: new Text('Create'),
        onPressed: () => confirmJoin(context)
    );
  }

  Widget hintText() {
    return new Container(
      //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(
            _authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center)
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new SingleChildScrollView(
        child: Card(
          margin: new EdgeInsets.all(50.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Logo(150.0,"lib/Assets/JoinClass.png"),
                new Center(
                  child: new Text("Add a student", style: TextStyle(fontWeight: FontWeight.w900),),
                ),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                    onChanged: (){
                      setState(() {
                        
                        final form = studKey.currentState;
                        form.save();
                      });
                    },
                    key: studKey,
                      child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        username(),
                        schoolField(),
                        courseField(),
                        allCourse(),
                        moduleGrpField(),
                        allModuleGrp(),
                        submitWidgets(context),
                      ],
                    ),
                  )
                ),
              ]
            )
          ),
        ) 
      );
  }

  Future<Null> confirmJoin(BuildContext ct) async{
    if(validateAndSave()){
      switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to add $_email?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("$_email will be created."),
              ),
            new FlatButton( 
               onPressed:((){
                validateAndSubmit(ct);
                Navigator.pop(context);
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.green),),
            )
          ],
        )
      )
      ){}
    }else{
      
    }
    
  }
  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
