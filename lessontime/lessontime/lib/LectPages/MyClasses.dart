import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'ViewLesson.dart';
class MyClasses extends StatefulWidget{
  final String lectIC;
  MyClasses(this.lectIC);
  @override
  State<StatefulWidget> createState() => new _MyClassesState(lectIC);
  
}

class _MyClassesState extends State<MyClasses>{
  String lectIC;
  FirebaseLink fblink = new FirebaseLink();
  _MyClassesState(this.lectIC);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new StreamBuilder(
      stream: Firestore.instance.collection("Lessons").where("lectInCharge", isEqualTo: lectIC).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Assets.loader();
        }else{
          return new Scaffold(
          backgroundColor: Colors.white,
          body: 
          new ListView(
            children: snapshot.data.documents.reversed.map((DocumentSnapshot document){
              return ListTile(
                leading: new Icon(Icons.class_, color:  Colors.indigoAccent,),
                title: new Text("ID: " + document["lessonID"].toString()),
                subtitle: new Row(
                  children: <Widget>[
                    new Text("Is this class open? "),
                    classStatus(document["isOpen"]),
                  ],
                  
                ),
                trailing: new IconButton(
                  icon:Icon(Icons.delete),
                  onPressed: (){
                    FirebaseLink.deleteClass(document["lessonID"]);
                    Scaffold.of(context).showSnackBar(
                      new SnackBar(
                        content: new Text("Class successfully deleted."),
                        )
                      );
                  }),
                onTap: (){Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder:(context) => ViewLesson(document["lessonID"],lectIC)));
              });
            }).toList()
          ) 
          );
        }
      });
  }
  
  Widget classStatus(bool isOpen){
    double size = 15.0;
    if(isOpen){
      return new Icon(Icons.check, size: size, color: Colors.green,);
    }else{
      return new Icon(Icons.block, size: size, color: Colors.redAccent);
    }
  }
}