import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/auth.dart';
import 'package:validator/validator.dart';

class AddAdmin extends StatefulWidget {
  AddAdmin({Key key, this.title, this.auth}) : super(key: key);

  final String title;
  final BaseAuth auth;

  @override
  _AddAdminState createState() => new _AddAdminState();
}

enum FormType {
  login,
  register
}

class _AddAdminState extends State<AddAdmin> {
  static final adminKey = new GlobalKey<FormState>();

  String _username;
  String _email;
  String _authHint = '';


  bool validateAndSave() {
    final form = adminKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        var userId = 
        await widget.auth.createUser(_username, _email, _email,2,false);
            
        final form = adminKey.currentState;
        setState(() {
          form.reset();
          _authHint = 'Admin Created\n\nUser id: $userId';
          SnackBar bar = new SnackBar(content:new Text('Admin Created\n\nUser id: $userId'),);
          Scaffold.of(context).showSnackBar(bar);
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
          hintText: "AdminID",
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
        validator: (val) => val.isEmpty ? 'Admin Number can\'t be empty.' : null,
        onSaved: (val) => _username = val,
      )
    );
  }

  Widget email() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
      style: new TextStyle(color: Colors.white),
        key: new Key('Admin number'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Admin Email",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.email, color: Colors.white),
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
          val.isEmpty ? 'Email can\'t be empty.' : null;
          if(isEmail(val)){
            null;
          }else{
            "Email is not valid";
          }
        },
        onSaved: (val) => _email = val,
      )
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

  Future<Null> confirmJoin(BuildContext ct) async{
  if(validateAndSave()){
    switch(
    await showDialog(
      context: context,
      child: new SimpleDialog(
        title: new Text("Confirm to add $_username?"),
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.all(25.0),
            child: new Text("$_username will be created."),
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
                  child: new Text("Add an Admin", style: TextStyle(fontWeight: FontWeight.w900),),
                ),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Form(
                    key: adminKey,
                      child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        username(),
                        email(),
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

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
