import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/models/Model.dart';

class ViewCourse extends StatefulWidget{
  final String courseID;
  final String school;
  ViewCourse(this.school, this.courseID);
  @override
  State<StatefulWidget> createState() => new _ViewCourseState(school,courseID);

}

class _ViewCourseState extends State<ViewCourse> with SingleTickerProviderStateMixin{
  static final moduleKey = new GlobalKey<FormState>();
  static final courseGrpKey = new GlobalKey<FormState>();
  String _authHint;
  String _courseID;
  String _school;
  TabController tabController;
  String _moduleName;
  String _courseGrp;
  _ViewCourseState(this._school,this._courseID);
  FirebaseLink fblink = new FirebaseLink();

  
  @override
  void initState(){
    // TODO: implement initState
    tabController = new TabController(length: 2, vsync: this);
      super.initState();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        bottom: new TabBar(
          controller: tabController,
            tabs: <Widget>[
              new Tab(
                child: new Text("Groups",style: new TextStyle(color:Colors.indigoAccent,)),
              ),
              new Tab(
                child: new Text("Modules",style: new TextStyle(color:Colors.indigoAccent,)),
              ),
            ],
        ),
        backgroundColor: Colors.transparent,
        title: new Text("#$_courseID"  ,
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
            icon: Icon(Icons.group_add),
            tooltip: "Add new course group",
            onPressed: ()=>addCourseGrpDialog(),
          ),
          new IconButton(
            icon: Icon(Icons.add),
            tooltip: "Add new module",
            onPressed: ()=>addModuleDialog(),
          ),
          new IconButton(
            icon: Icon(Icons.refresh),
            onPressed: ()=> setState(() {   
            })
          )
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          courseGrps(),
          modules(),
        ],
      )
      
    );
  }


  Widget courseGrps(){
    return FutureBuilder(
      future: FirebaseLink.getCourseGrps(_school, _courseID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Assets.loader();
        }else{
          return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document){
            return ListTile(
              leading: Icon(Icons.group,color: Colors.indigoAccent,),
              title: new Text(document.documentID),
              trailing: new IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  confirmDelete(context, document.documentID,1);
                  setState(() {
                  });
                },
              ),
            );
          }).toList()
        );
        }
      },
    );
  }
  Widget modules(){
    return FutureBuilder(
      future: FirebaseLink.getCourseModules(_school, _courseID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Assets.loader();
        }else{
          return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document){
            _moduleName = document.data["moduleName"];
            return ListTile(
              leading: new Icon(Icons.book,color: Colors.indigoAccent,),
              title: new Text(document.documentID),
              trailing: new IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  confirmDelete(context, document.documentID,0);
                  setState(() {
                  });
                },
              ),
            );
          }).toList()
        );
        }
      },
    );
  }
  Widget moduleNameField() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        style: new TextStyle(color: Colors.white),
        key: new Key('ModuleName'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Module Name",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label),
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

  
  Widget courseGrpField() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        style: new TextStyle(color: Colors.white),
        key: new Key('CourseGrp'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Course Group",
          hintStyle: new TextStyle(
            color: Colors.white
          ),
          helperText: "SF1601,SF1602... etc",
          prefixIcon: new Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.label),
          ),
          fillColor: select,
          filled: true,
          border: new OutlineInputBorder(
            borderSide: BorderSide(color: select, width: 2.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.circular(50.0),
          )
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Course Group can\'t be empty.' : null,
        onSaved: (val) => _courseGrp = val,
      )
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  Future<Null> addModuleDialog()async{
    Color select = Colors.indigo[400];
    switch(
      await showDialog(
        context:  context,
        child: new SimpleDialog(
          contentPadding: EdgeInsets.all(15.0),
          title: new Text("Add Module",textAlign: TextAlign.center,),
          children: <Widget>[
            new Logo(150.0,"lib/Assets/AddModule.png"),
            new Form(
              key: moduleKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  moduleNameField(),
                  padded(
                    child: new RaisedButton(
                      textColor: Colors.white,
                      color: select,
                      padding: EdgeInsets.all(15.0),
                      shape: StadiumBorder(
                      ),
                      key: new Key('create'),
                      child: new Text('Create'),
                      onPressed:()=> confirmCreateModule(context)
                    )
                  ),
                ],
              ),
            )
          ],
        )
      )
    ){}
  }

  Future<Null> addCourseGrpDialog()async{
    Color select = Colors.indigo[400];
    switch(
      await showDialog(
        context:  context,
        child: new SimpleDialog(
          contentPadding: EdgeInsets.all(15.0),
          title: new Text("Add Course Group",textAlign: TextAlign.center,),
          children: <Widget>[
            new Logo(150.0,"lib/Assets/AddModule.png"),
            new Form(
              key: courseGrpKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  courseGrpField(),
                  padded(
                    child: new RaisedButton(
                      textColor: Colors.white,
                      color: select,
                      padding: EdgeInsets.all(15.0),
                      shape: StadiumBorder(
                      ),
                      key: new Key('create'),
                      child: new Text('Create'),
                      onPressed:()=> confirmCreateGrp(context)
                    )
                  ),
                ],
              ),
            )
          ],
        )
      )
    ){}
  }

  Future<Null> confirmDelete(BuildContext ct, String moduleName, int type) async{
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to delete $moduleName?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("This item will be deleted. It will not be retrievable!"),
              ),
            new FlatButton( 
               onPressed:((){
                Navigator.pop(context);
                switch(type){
                  case 0: 
                  FirebaseLink.removeModules(_school, _courseID, moduleName);
                  break;
                  case 1:
                  FirebaseLink.removeCourseGrp(_school, _courseID, moduleName);
                  break;
                }
                setState(() {
                                  
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.red),),
            )
          ],
        )
      )
    ){}
  }
  
  Future<Null> confirmCreateModule(BuildContext ct) async{
    validateAndSave(moduleKey);
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to add $_moduleName?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("This module will be created. You may delete it later."),
              ),
            new FlatButton( 
               onPressed:((){
                validateAndSubmit(ct,moduleKey,0);
                Navigator.pop(ct);
                Navigator.pop(context);
                setState(() {
                                  
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.green),),
            )
          ],
        )
      )
    ){}
  }

  Future<Null> confirmCreateGrp(BuildContext ct) async{
    validateAndSave(courseGrpKey);
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to add $_courseGrp?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("This group will be created. You may delete it later."),
              ),
            new FlatButton( 
               onPressed:((){
                validateAndSubmit(ct,courseGrpKey,1);
                Navigator.pop(ct);
                Navigator.pop(context);
                setState(() {
                                  
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.green),),
            )
          ],
        )
      )
    ){}
  }

  
  bool validateAndSave(GlobalKey<FormState> key) {
    final form = key.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(BuildContext context, GlobalKey<FormState> key, int type) async {
    if (validateAndSave(key)) {
      try {
        try {
          switch(type){
            case 0:{
              await FirebaseLink.addModules(_school,_courseID, _moduleName).then((CourseCreationResult ccr){
                if(ccr.success){
                  _authHint = ccr.error;
                  final form = key.currentState;
                  setState(() {
                    form.reset();
                    SnackBar bar = new SnackBar(content:new Text(_authHint),);
                    Scaffold.of(context).showSnackBar(bar);
                  });
                }else{
                  _authHint = ccr.error;
                  final form = key.currentState;
                  setState(() {
                    form.reset();
                    SnackBar bar = new SnackBar(content:new Text(_authHint),);
                    Scaffold.of(context).showSnackBar(bar);
                  });
                }
              });
            }
            break;
            case 1:{
              await FirebaseLink.addCourseGrps(_school,_courseID,_courseGrp).then((CourseCreationResult ccr){
                if(ccr.success){
                  _authHint = ccr.error;
                  final form = key.currentState;
                  setState(() {
                    form.reset();
                    SnackBar bar = new SnackBar(content:new Text(_authHint),);
                    Scaffold.of(context).showSnackBar(bar);
                  });
                }else{
                  _authHint = ccr.error;
                  final form = key.currentState;
                  setState(() {
                    form.reset();
                    SnackBar bar = new SnackBar(content:new Text(_authHint),);
                    Scaffold.of(context).showSnackBar(bar);
                  });
                }
              });
            }
          }
          
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
}