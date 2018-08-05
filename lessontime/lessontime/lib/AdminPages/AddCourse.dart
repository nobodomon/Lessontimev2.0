import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lessontime/AdminPages/ViewCourse.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/auth.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/models/Model.dart';

class AddCourse extends StatefulWidget {
  AddCourse( this.fbuser, this.user, {Key key, this.title, this.auth,}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final Users user;
  final FirebaseUser fbuser;
  @override
  _AddCourseState createState() => new _AddCourseState(user,fbuser);
}

enum FormType {
  login,
  register
}

class _AddCourseState extends State<AddCourse> {
  static final formKey = new GlobalKey<FormState>();
  List<String> _schoolList = <String>[
    "SBM","SCL","SDN","SEG","SHS","SIT","SIDM","GSM","PFP"
  ];
  Users user;
  FirebaseUser fbuser;
  String _school;
  String _courseID;
  String _courseName;
  String _authHint = '';
  _AddCourseState(this.user, this.fbuser);
  TextEditingController courseNameCtrl = new TextEditingController();


  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    courseNameCtrl.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndView(BuildContext context) async{
    setState(() {
      courseNameCtrl.text = "prevent check only";      
    });
    if(validateAndSave()){
      try{
        await FirebaseLink.checkIfCourseExist(_school,_courseID).then((bool result){
          if(result == true){
              _authHint = 'Course $_courseID found, opening viewer.';
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCourse(_school,_courseID)));
          }else{
              _authHint = 'Course $_courseID not found!';
          }
          final form = formKey.currentState;
          setState(() {
              form.reset();
              setState(() {
              courseNameCtrl.text = "";                
              });
              SnackBar bar = new SnackBar(content:new Text(_authHint),);
              Scaffold.of(context).showSnackBar(bar);
          });
        });
      }catch(error){
        print(error.toString());
      }
    }else{
      setState(() {
        _authHint = ' ';
      });
    }
    
  }

  Future<Null> confirmJoin(BuildContext ct) async{
    
    validateAndSave();
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to create $_courseID?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("This course will be created. You may add modules later."),
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
  }

  void validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        try {
          await FirebaseLink.createCourse(_school,_courseID, _courseName).then((CourseCreationResult ccr){
            if(ccr.success){
              _authHint = ccr.error;
              final form = formKey.currentState;
              setState(() {
                form.reset();
                SnackBar bar = new SnackBar(content:new Text(_authHint),);
                Scaffold.of(context).showSnackBar(bar);
              });
            }else{
              _authHint = ccr.error;
              final form = formKey.currentState;
              setState(() {
                form.reset();
                SnackBar bar = new SnackBar(content:new Text(_authHint),);
                Scaffold.of(context).showSnackBar(bar);
              });
            }
          });
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

  Widget courseIDField() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        style: new TextStyle(color: Colors.white),
        key: new Key('CourseID'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Course ID",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.chevron_right, color: Colors.white),
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
        onSaved: (val) => _courseID = val,
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
          helperText: "SBM,SEG,SDN,SIDM...",
          hintText: "School",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.school, color: Colors.white),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val){
          val.isEmpty ? 'School can\'t be empty.' : null;
          if(_schoolList.contains(val)){
            return null;
          }else{
            return "Invalid school input.";
          }
        },
        onSaved: (val) => _school = val.toUpperCase(),
      )
    );
  }

  Widget courseNameField() {
    
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        controller: courseNameCtrl,
        style: new TextStyle(color: Colors.white),
        key: new Key('CourseName'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Course Name",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label, color: Colors.white),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Course Name can\'t be empty.' : null,
        onSaved: (val) => _courseName = val,
      )
    );
  }

  List<Widget> submitWidgets(BuildContext context){
    Color select = Colors.indigo[400];
    return [
      padded(
        child: new RaisedButton(
          textColor: Colors.white,
          color: select,
          padding: EdgeInsets.all(15.0),
          shape: StadiumBorder(
          ),
          child: new Text('View'),
          onPressed:()=> validateAndView(context)
        )
      ),
      padded(
        child: new RaisedButton(
          textColor: Colors.white,
          color: select,
          padding: EdgeInsets.all(15.0),
          shape: StadiumBorder(
          ),
          key: new Key('create'),
          child: new Text('Create'),
          onPressed:()=> confirmJoin(context)
        )
      ),
    ];
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
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.indigo,
      body : new SingleChildScrollView(
        child: Center(
        child: new Card(
          margin: EdgeInsets.all(50.0),
          color: Colors.white,
          elevation: 2.0,
          child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Logo(150.0,"lib/Assets/AddCourses.png"),
                new Center(
                  child: new Text("Create a course", style: TextStyle(fontWeight: FontWeight.w900),),
                ),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                      key: formKey,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          schoolField(),
                          courseIDField(),
                          courseNameField(), 
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: submitWidgets(context)
                          ),
                        ],
                        
                      ),
                  )
                ),
              ]
          )
        ),
      ),
      ) 
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

}
