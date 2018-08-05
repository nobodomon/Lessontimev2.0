import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lessontime/root_page.dart';
import 'package:lessontime/auth.dart';

final FirebaseApp app = FirebaseApp(
  name: 'LessonTime',

);



void main() => runApp(new LessonTime());

class LessonTime extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseApp.configure(name: "LessonTime", options: FirebaseOptions(
      googleAppID: '1:722159833325:android:afc176d451740c7b',
      apiKey: 'AIzaSyDqKqv_GgOohKy7u1PhEKj83demcXuFDr8',
      databaseURL: "https://lessontime-b3a25.firebaseio.com",
    ));

    return new MaterialApp(
        title: 'Lesson Time',
        theme: new ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          primarySwatch: Colors.indigo,
          accentColor: Colors.indigoAccent,
          scaffoldBackgroundColor: Colors.white70,
          bottomAppBarColor: Colors.indigoAccent,
          primaryIconTheme: new IconThemeData(color: Colors.indigoAccent),
        ),
        //home: new MyHomePage(title: 'Lesson Time'),
        //home: new MyHomePage(title: 'LessonTime'),
        home: new RootPage(auth: new MyAuth(),));
  }
}