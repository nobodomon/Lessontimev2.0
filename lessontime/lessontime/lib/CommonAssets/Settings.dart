import 'package:flutter/material.dart';
import 'package:lessontime/auth.dart';

class Settings extends StatelessWidget{
  final MyAuth auth = new MyAuth();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading:new FlatButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_downward, color: Colors.indigoAccent,),
        ),
        title: new Text("Settings", style: new TextStyle(color:  Colors.indigoAccent)),
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.lock),
            title: new Text("Reset Password"),
            subtitle: new Text("Send password reset email"),
            onTap: ()=> auth.editUser(),
          ),
          
        ],
      )
    );
  }
}
