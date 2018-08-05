import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:lessontime/auth.dart';
import 'package:lessontime/models/Model.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettings extends StatefulWidget{
  final FirebaseUser fbuser;
  AdminSettings(this.fbuser);
  @override
  State<StatefulWidget> createState() => new _AdminSettingsState(fbuser);
}

class _AdminSettingsState extends State<AdminSettings>{
  _AdminSettingsState(this.fbuser);

  FirebaseUser fbuser;
  static final formKey = new GlobalKey<FormState>();
  FirebaseLink fblink = new FirebaseLink();
  bool ipCheckToggle;
  bool locationCheckToggle;
  String txMsg;
  @override
  Widget build(BuildContext context) {
    // TODO: implement builds
    MyAuth auth = new MyAuth();
    return FutureBuilder(
      future: FirebaseLink.getSettings(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        if(!snapshot.hasData){
          return Assets.loader();
        }else{
          SettingsModel model = SettingsModel.fromSnapshot(snapshot);
          ipCheckToggle = model.ipCheck;
          locationCheckToggle = model.locationCheck;
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
            body: new Form(
              key:  formKey,
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.lock, color: Colors.indigoAccent,),
                    title: new Text("Reset Password"),
                    subtitle: new Text("Send password reset email"),
                    onTap: ()=> auth.editUser(),
                  ),
                  new Divider(),
                  new SwitchListTile(
                    key: new Key("ipCheck"),
                    title: const Text("Check IP Toggle"),
                    subtitle: const Text("Make the system check for user IP?"),
                    value: model.ipCheck,
                    onChanged: (bool value) {
                      setState(() {
                        model.ipCheck = value;
                        model.settingsLastSetBy = fbuser.email;
                        FirebaseLink.setSettings(model).then((bool value){
                          if(value){
                            txMsg = "IP settings has been changed successfully.";
                          }else{
                            txMsg = "IP settings has failed to change check your network.";
                          }
                          SnackBar bar = new SnackBar(content:new Text(txMsg),);
                          Scaffold.of(context).showSnackBar(bar);
                        });
                      });
                    },
                    secondary: const Icon(Icons.network_check,color: Colors.indigoAccent,),
                  ),
                  new Divider(),
                  new SwitchListTile(
                    key: new Key("locationCheck"),
                    title: const Text("Check Location Toggle"),
                    subtitle: const Text("Make the system check for user's Location?"),
                    value: model.locationCheck,
                    onChanged: (bool value) {
                      setState(() {
                        model.locationCheck = value;
                        model.settingsLastSetBy = fbuser.email;
                        FirebaseLink.setSettings(model).then((bool value){
                          if(value){
                            txMsg = "Location settings has been changed successfully.";
                          }else{
                            txMsg = "Location settings has failed to change check your network.";
                          }
                          SnackBar bar = new SnackBar(content:new Text(txMsg),);
                          Scaffold.of(context).showSnackBar(bar);
                        });
                      });
                    },
                    secondary: const Icon(Icons.location_searching,color: Colors.indigoAccent,),
                    
                  ),
                ],
              ),
            )
          );
        }
      },
    );
  }

}