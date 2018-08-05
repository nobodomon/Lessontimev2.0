import 'package:flutter/material.dart';

class Logo extends StatelessWidget{
  final double height;
  final String assetPath;
  Logo(this.height,this.assetPath);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: new Image.asset(
        assetPath,
        fit: BoxFit.cover,
        height: height,
      ),
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 16.0),
    );
  }
}
