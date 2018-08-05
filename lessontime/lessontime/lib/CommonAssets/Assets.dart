import 'package:flutter/material.dart';

class Assets{
  static Scaffold loader(){
    return new Scaffold(
      body: new Container(
        child: new Center(
          widthFactor: 100.0,
          heightFactor:  100.0,
          child: new Card(
            child: new Padding(
              padding: new EdgeInsets.all(15.0),
              child: new CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
