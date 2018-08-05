import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/auth.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/models/Model.dart';
import 'package:lessontime/LectPages/ViewLesson.dart';

class QRPage extends StatefulWidget {
  QRPage( this.fbuser, this.user, {Key key, this.title, this.auth,}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final Users user;
  final FirebaseUser fbuser;
  @override
  _QRPageState createState() => new _QRPageState(user,fbuser);
}

enum FormType {
  login,
  register
}

class _QRPageState extends State<QRPage> {
  static final formKey = new GlobalKey<FormState>();
  Users user;
  FirebaseUser fbuser;
  String _lessonID;
  String _authHint = '';
  _QRPageState(this.user, this.fbuser);

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndView(BuildContext context) async{
    if(validateAndSave()){
      try{
        await FirebaseLink.checkifClassExist(_lessonID).then((bool result){
          if(result == true){
              _authHint = 'Lesson $_lessonID found, opening viewer.';
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewLesson(_lessonID,user.adminNo)));
          }else{
              _authHint = 'Lesson $_lessonID not found!';
          }
          final form = formKey.currentState;
          setState(() {
              form.reset();
              SnackBar bar = new SnackBar(content:new Text(_authHint),);
              Scaffold.of(context).showSnackBar(bar);
          });
        });
      }catch(error){
        print(error.toString());
      }
    }
  }

  Future<Null> confirmJoin(BuildContext ct) async{
    validateAndSave();
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to join $_lessonID?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("You will be added to this lesson."),
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
          await FirebaseLink.joinClass(user, _lessonID).then((JoinClassResult result){
            print("QRPage result: " + result.toString());
            if(result.success == false){
              _authHint = result.error;
            }else if(result.success == true){
              _authHint = result.error;
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewLesson(_lessonID,user.adminNo)));
            }else{
              Navigator.push(context, MaterialPageRoute(builder: (context) => Assets.loader()));
            }
            final form = formKey.currentState;
            setState(() {
              form.reset();
              SnackBar bar = new SnackBar(content:new Text(_authHint),);
              Scaffold.of(context).showSnackBar(bar);
            });
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

  Widget classIDField() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        key: new Key('LessonID'),
        style: new TextStyle(
          color: Colors.white
        ),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Lesson ID",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.group_add, color: Colors.white,),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Code can\'t be empty.' : null,
        onSaved: (val) => _lessonID = val,
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
          key: new Key('register'),
          child: new Text('Join'),
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
      body :new SingleChildScrollView(
        child: Center(
          child: new Card(
            margin: EdgeInsets.all(50.0),
            color: Colors.white,
            elevation: 2.0,
            child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Logo(150.0,"lib/Assets/JoinClass.png"),
                  new Center(
                    child: new Text("Join a class", style: TextStyle(fontWeight: FontWeight.w900),),
                  ),
                  new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            classIDField(), 
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
