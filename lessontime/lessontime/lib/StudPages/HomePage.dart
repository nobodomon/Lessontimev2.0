import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/models/Model.dart';
import 'package:lessontime/CommonAssets/Assets.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'package:map_view/map_view.dart';


class HomePage extends StatefulWidget{
  HomePage(this.fbUser);
  final FirebaseUser fbUser;
  @override
  State<StatefulWidget> createState() =>new _HomePageState(fbUser);

}

class _HomePageState extends State<HomePage>{
  _HomePageState(this.fbuser);
  final String apiKey = 'AIzaSyCDB6x7-YkbRBcfw6xfmLtKaEBc5GTVrpI';
  FirebaseUser fbuser;
  Users nUser;
  MapView mapView = new MapView();
  //final BaseAuth _auth;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MapView.setApiKey(apiKey);
    //getUser();
  }
  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
      future: FirebaseLink.getUserOnceFs(fbuser.email),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        
        if(snapshot.hasData){
          nUser = Users.fromSnapshot(snapshot.data);
          return new Scaffold(
            backgroundColor: Colors.white,
            body: new Stack(
              children: <Widget>[
                new ListView(
                  children: <Widget>[
                    new Container(
                      color: Colors.indigo,
                      child: Center(
                        child: new Logo(250.0,"lib/Assets/LessonTime.png"),
                      ),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.person, color: Colors.indigoAccent,),
                      title: const Text("Welcome to school"),
                      subtitle: Text(nUser.adminNo),
                    ),
                    new Divider(),
                    ipCheck(nUser.logonIP, context),
                    new Divider(),
                    locationCheck(context)
                  ],
                )
              ],
            )
          );
        }else{
          return Assets.loader();
        }
      });
    }
  

  Widget pwWarningGen(Users nUser){
    if(nUser.lastLogin == null){
      return new ListTile(
        leading: Icon(Icons.info, color: Colors.red),
        title: new Text("Please change your password!"),
        subtitle: new Text("You can reset it by clicking the settings icon on the app bar."),
        
      );
    }else{
      return new Container();
    }
  }

  Widget ipCheck(String ip, BuildContext context){
    if(ip != null){
      if(FirebaseLink.checkIfAcceptableIP(ip, true)){
        return new ListTile(
          leading: new Icon(Icons.network_check, color: Colors.indigoAccent,),
          title: const Text("Your logged in IP"),
          subtitle: Text(ip),
          onLongPress: ()=>setState(() {
                          
          }),
        );
      }else{
        return new ListTile(
          leading: new Icon(Icons.network_check, color: Colors.indigoAccent,),
          title: const Text("Your logged in IP"),
          subtitle: Text(ip, style: TextStyle(color: Colors.red,)),
          trailing: IconButton(
            icon: Icon(Icons.warning),
            onPressed: ()=> displayWarning(context,"Are you sure you are on the school's network?", "We suggest that you connect to school's wifi and try logging in again to be able to join your class."),
          ),
          onLongPress: ()=>setState(() {
            FirebaseLink.setLogonIP(nUser.email);
          }),
        );
      }
    }else{
        return new ListTile(
          leading: new Icon(Icons.network_check, color: Colors.indigoAccent,),
          title: const Text("Your logged in IP"),
          subtitle: Text("Never logged on before."),
          onLongPress: ()=>setState(() {
                          
          }),
        );
    }
    
  }

  Future<Null> openMap(BuildContext context, AsyncSnapshot<Map<String, double>> location)async{
    
    double latitude = location.data.values.toList()[1];
    String lat = latitude.toStringAsFixed(3);
    latitude = double.parse(lat);
    double longtitude = location.data.values.toList()[5];
    String long = longtitude.toStringAsFixed(3);
    longtitude = double.parse(long);
    List<Marker> _markers = <Marker>[
    new Marker(
      "1",
      "Something fragile!",
      latitude,
      longtitude,
      color: Colors.indigoAccent,
      draggable: false, //Allows the user to move the marker.
      
    ),
    ];
    Location mapLoc = new Location(latitude, longtitude);
    var staticMapProvider = new StaticMapProvider(apiKey);
    var uri = staticMapProvider.getStaticUriWithMarkers(_markers,width:450,height: 300, center: mapLoc,maptype: StaticMapViewType.terrain);
    MapView.setApiKey(apiKey);
    switch(
      showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Your approximate location",textAlign: TextAlign.center,),
          contentPadding: EdgeInsets.all(0.0),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(15.0),
              child: new Container(
                height: 200.0,
                width: 300.0,
                color: Colors.white,
                child: new Center(
                  child: new Image.network(uri.toString()),
                )
               ),
            ),
          ],
        )
      )
    ){}
    
  }

  
  Widget locationCheck(BuildContext context){
    return FutureBuilder(
      future: FirebaseLink.getLocation(),
      builder:(BuildContext context,AsyncSnapshot<Map<String, double>> location){
        if(!location.hasData){
          return new ListTile(
            title: new LinearProgressIndicator(),
          );
        }else{
          LocationResult res = FirebaseLink.checkIfAcceptableLocationRange(location.data, true);
          if(res.success){
            return new ListTile(
              leading: Icon(Icons.location_on,color: Colors.indigoAccent),
              title: new Text("Your location "),
              subtitle: new Text(res.error),
              onTap: (){
                openMap(context,location);
              },
              onLongPress: ()=>setState(() {
                              
              }),
            );
          }else{
            return new ListTile(
              leading: Icon(Icons.location_on,color: Colors.indigoAccent,),
              title: new Text("Your location"),
              subtitle: new Text(res.error, style: TextStyle(color: Colors.red),),
              onTap: (){
                openMap(context, location);
                  //buildMap(asset.data, location, controller);
              },
              trailing: new IconButton(
                    icon: Icon(Icons.warning),
                    onPressed: () => displayWarning(context,"Your location seems shady", "Are you sure you are in school?")
              ),
              onLongPress: ()=>setState(() {
                              
              }),
              /* new IconButton(
                icon: Icon(Icons.warning),
                onPressed: () => displayWarning(context,"Your location seems shady", "Are you sure you are in school?")
              ), */
            );
          }
        }
      }
    );
  }

  Future<Null> displayWarning(BuildContext context,String titleTxt, String warningTxt) async{
    switch(
      await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text(titleTxt),
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(25.0),
              child: new Text(warningTxt),
              ),
            
          ],
        ) 
      )
    ){}
  }

  /* void getUser() async{
    Future<FirebaseUser> fbUsr = _auth.currentUserAct();
    setState(() {
      if(fbUsr == null){
        print("its null");
      }else{
        fbUsr.then((FirebaseUser user){
          if(user != null){
            fbuser = user;
          }else{
          }
        });
      }
    });
  } */
}