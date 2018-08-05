import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/models/Model.dart';

class ViewLesson extends StatefulWidget{
  final String lessonID;
  final String lectIC;
  ViewLesson(this.lessonID, this.lectIC);
  @override
  State<StatefulWidget> createState() => new _ViewLessonState(lessonID, lectIC);

}

class _ViewLessonState extends State<ViewLesson>{
  static final formKey = new GlobalKey<FormState>();
  String lessonID;
  String ipAddr;
  String lectIC;
  String isOpen;
  String moduleName;
  String _adminNo;
  String _authHint = '';
  _ViewLessonState(this.lessonID, this.lectIC);
  FirebaseLink fblink = new FirebaseLink();
  @override
  Widget build(BuildContext context){
    return new StreamBuilder(
      stream: FirebaseLink.getClassList(lessonID).asStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Assets.loader();
        }else{
          return FutureBuilder(
            future: FirebaseLink.getClass(lessonID),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> qc){
              if(!qc.hasData){
                return Assets.loader();
              }else{
                ipAddr = qc.data.documents.first["ipAddr"];
                isOpen = qc.data.documents.first["isOpen"].toString();
                moduleName = qc.data.documents.first["moduleName"];
                return new Scaffold(
                  backgroundColor: Colors.white,
                  appBar: new AppBar(
                    backgroundColor: Colors.transparent,
                    title: new FlatButton(
                      child: new Text(
                        "#$lessonID"  ,
                        style: new TextStyle(color: Colors.indigoAccent)
                        ),
                        onPressed: ()=>showInfo(),
                    ),
                    leading:new FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_downward, color: Colors.indigoAccent,),
                    ),
                    elevation: 0.0,
                    actions: <Widget>[
                      stopButton(context),
                      addButton(context),
                      new IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: ()=> setState(() {
                                                  
                        })
                      )
                    ],
                  ),
                  body :ListView(
                    children: snapshot.data.documents.map((DocumentSnapshot document){
                      if(document["isLate"] == null){
                        return studentTile(document.documentID, context, false);
                      }else{
                        return studentTile(document.documentID, context, document["isLate"]);
                      }
                    }).toList()
                  ),
                );
              }
            },
          );
        }
      }
    );
  }

  Widget studentTile(String adminNo, BuildContext context, bool dbisLate){
    bool settings = dbisLate;
    return new FutureBuilder(
      future: FirebaseLink.getClass(lessonID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
       if(!snapshot.hasData){
         return new LinearProgressIndicator();
       }else{
         Lesson lesson = Lesson.fromSnapshot(snapshot.data.documents.first);
         if(lesson.lectInCharge == lectIC){
           return SwitchListTile(
            title: new Text(adminNo),
            subtitle: new Text("Toggle the switch if student is late."),
            value: settings,
            secondary: new Icon(Icons.people, color: Colors.indigoAccent,),
            onChanged: (bool x){
              setState(()async{
                await FirebaseLink.markLateness(lessonID, adminNo, x).then((JoinClassResult result){
                  setState(() { 
                    settings = x;
                  });
                  SnackBar bar = new SnackBar(content: new Text(result.error),);
                  Scaffold.of(context).showSnackBar(bar);
                });
              });
            },
          );
         }else{
           return new ListTile(
             leading: new Icon(Icons.people, color: Colors.indigoAccent),
             title: new Text(adminNo),
           );
         }
       }
      }
    );
  }

  Widget addButton(BuildContext scaffoldCt){
    return FutureBuilder(
      future: FirebaseLink.getClass(lessonID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Assets.loader();
        }else{
          if(snapshot.data.documents.first["lectInCharge"] == lectIC){
            if(snapshot.data.documents.first["isOpen"]){
              return new IconButton(
                icon: Icon(Icons.person_add),
                tooltip: "Manually add a student",
                onPressed: ()=>addUserDialog(scaffoldCt),
              );
            }else{
              return new IconButton(
                icon: Icon(Icons.person_add),
                tooltip: "Manually add a student",
                onPressed: null,
              );
            }
          }else{
            return new IconButton(
              icon: Icon(Icons.block),
              onPressed: null,
            );
          }
          
        }
      });
  }

  Future<Null> addUserDialog(BuildContext scaffoldCt) async{
    Color select = Colors.indigo[400];
    switch(
      await showDialog(
        context: context,
        child: SimpleDialog(
          contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
          title: new Text("Add student to class"),
          children: <Widget>[
            new Form(
              key:  formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  adminNoField(),
                  padded(
                    child: new RaisedButton(
                      textColor: Colors.white,
                      color: select,
                      padding: EdgeInsets.all(15.0),
                      shape: StadiumBorder(
                      ),
                      key: new Key('Add'),
                      child: new Text('Add'),
                      onPressed:()=> confirmAdd(scaffoldCt,context)
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

  Future<Null> confirmAdd(BuildContext scaffoldCt, BuildContext ct) async{
    if(validateAndSave()){
      switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm to add $_adminNo?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("This student will be manually added."),
              ),
            new FlatButton( 
               onPressed:((){
                validateAndSubmit(ct);
                Navigator.pop(ct);
                Navigator.pop(context);
                setState(() {
                  SnackBar snackBar = new SnackBar(content:new Text(_authHint),);
                  Scaffold.of(scaffoldCt).showSnackBar(snackBar);     
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.green),),
            )
          ],
        )
      )
    ){}
    }
    
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
          await FirebaseLink.addStudentToClassManually(_adminNo, lessonID).then((JoinClassResult jcr){
            print(jcr.error);
            if(jcr.success){
              _authHint = jcr.error;
              setState(() {
                _authHint = jcr.error;
                _adminNo = "";
              });
            }else{
              setState(() {
                _authHint = jcr.error;
              });
            }
          });
          
        }catch(error){
          print(error.toString());
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

  Widget adminNoField() {
    Color select = Colors.indigo[400];
    return padded(child: new TextFormField(
        style: new TextStyle(color: Colors.white),
        key: new Key('AdminNumber'),
        decoration: new InputDecoration(
          isDense: true,
          hintText: "Admin Number",
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
        validator: (val) => val.isEmpty ? 'Admin Number can\'t be empty.' : null,
        onSaved: (val) => _adminNo = val,
      )
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }


  Future<Null> showInfo() async{
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Class Information"),
          children: <Widget>[
            new ListTile(
              dense: true,
              leading: new Icon(Icons.book, color: Colors.indigoAccent,),
              title: const Text("Class ID"),
              subtitle: new Text("$lessonID")
            ),
            new ListTile(
              dense: true,
              leading: new Icon(Icons.class_, color: Colors.indigoAccent,),
              title:  const Text("Module Name"),
              subtitle: new Text(moduleName.toString()),
            ),
            new ListTile(
              dense: true,
              leading: new Icon(Icons.network_cell, color: Colors.indigoAccent,),
              title:  const Text("Class IP address"),
              subtitle: new Text("$ipAddr"),
            ),
            new ListTile(
              dense: true,
              leading: new Icon(Icons.lock, color: Colors.indigoAccent,),
              title:  const Text("Class is open?"),
              subtitle: new Text(isOpen.toString()),
            ),
          ],
        ))
    ){
    }
  }

  Future<Null> confirmStop(BuildContext ct) async{
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm stop?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("Students will not be able to join this class until resumed."),
              ),
            new FlatButton( 
               onPressed:((){
                FirebaseLink.stopClass(lessonID);
                Navigator.pop(context);
                setState(() {
                  SnackBar bar = new SnackBar(content:new Text("Lesson $lessonID has been stopped."),);
                  Scaffold.of(ct).showSnackBar(bar);
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.red),),
            )
          ],
        )
      )
    ){}
  }
  Future<Null> confirmResume(BuildContext ct) async{
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Confirm resume?"),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text("Students will be able to join this class again until resumed."),
              ),
            new FlatButton( 
               onPressed:((){
                FirebaseLink.resumeClass(lessonID);
                Navigator.pop(context);
                setState(() {
                  SnackBar bar = new SnackBar(content:new Text("Lesson $lessonID has been resumed."),);
                  Scaffold.of(ct).showSnackBar(bar);
                });
              }),
             child: new Text("Confirm", style: new TextStyle(color: Colors.green),),
            )
          ],
        )
      )
    ){}
  }

  Widget stopButton(BuildContext context){
    return new FutureBuilder(
      future: FirebaseLink.getClass(lessonID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
       if(!snapshot.hasData){
         return Assets.loader();
       } else{
         Lesson lesson = Lesson.fromSnapshot(snapshot.data.documents.first);
         if(lesson.lectInCharge == lectIC){
           if(lesson.isOpen == false){
             return new IconButton( 
               onPressed:((){
                confirmResume(context);
              }),
             icon: new Icon(Icons.play_arrow, color: Colors.greenAccent,),
           );
           }else{
            return new IconButton(
              onPressed:((){
                confirmStop(context);
              }),
              icon: new Icon(Icons.stop, color: Colors.redAccent,),
            );
           }
           
         }else{
           return new IconButton(
             icon: new Icon(Icons.block),
             onPressed: null,
           );
         }
       }
      }
    );
  }
}