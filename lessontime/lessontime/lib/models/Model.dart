
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lessontime/FirebaseLink.dart';
import 'RandomString.dart';
import 'package:http/http.dart';

class Users {
  String key;
  String adminNo;
  String email;
  String lastLogin;
  int userType;
  String logonIP;
  String school = '-';
  String course = '-';
  String group = '-';

  Users(this.email, this.userType){
    this.adminNo = email.substring(0, email.length-18);
    this.lastLogin = null;
  }

  Users.fromSnapshot(DocumentSnapshot snapshot){
    if(snapshot["lastLogin"] == null){
        this.key = snapshot.documentID;
        this.email = snapshot["email"];
        this.adminNo = snapshot["adminNo"];
        this.userType = snapshot['userType'];
    }else{
        this.key = snapshot.documentID;
        this.email = snapshot["email"];
        this.adminNo = snapshot["adminNo"];
        this.userType = snapshot['userType'];
        this.lastLogin = snapshot['lastLogin'];
        this.logonIP = snapshot["logonIP"];
        this.school = snapshot["school"];
        this.course = snapshot["course"];
        this.group = snapshot["group"];
    }
  }
      



  toJson() {
    return {
      "adminNo": adminNo,
      "email": email,
      "userType": userType,
      "school": school,
      "course": course,
      "group": group
    };
  }

  Users.fromJson(Map data){
    email = data["email"];
    adminNo = data["adminNo"];
    userType = data["userType"];
    school = data["school"];
    course = data["course"];
    group = data["group"];
  }
}


class Device{
  String key;
  String deviceName;
  String identifier;

  Device(this.deviceName, this.identifier);

  Device.fromSnapshot(DocumentSnapshot snapshot)
    : key = snapshot.documentID,
      deviceName = snapshot.data["deviceName"],
      identifier = snapshot.data["identifier"];

  toJson(){
    return{
      "deviceName" : deviceName,
      "identifier" : identifier,
    };
  }

}

class CompleteUser{
  String key;
  FirebaseUser fbUser;
  Users nUser;

  CompleteUser(this.fbUser, this.nUser);

}

class Lesson{
  String key;
  String lessonID;
  String lectInCharge;
  bool isOpen;
  String ipAddr;
  String school;
  String courseID;
  String moduleName;


  Lesson(this.lectInCharge,this.school,this.courseID,this.moduleName){
    this.isOpen = true;
    String rand = randomAlphaNumeric(6).toUpperCase();
    bool dupe;
    FirebaseLink.checkifClassExist(rand).then((bool){
      dupe = bool;
    });
    while(dupe == true){
      rand = randomAlphaNumeric(6).toUpperCase();
      FirebaseLink.checkifClassExist(rand).then((bool){
        dupe = bool;
      });
    }
    this.lessonID = rand;
  }

  toJson() {
    return {
      "lessonID" : lessonID,
      "lectInCharge": lectInCharge,
      "isOpen": isOpen,
      "ipAddr": ipAddr,
      "moduleName": moduleName,
      "courseID": courseID,
      "school": school,
    };
  }

  Lesson.fromJson(Map data){
    lessonID = data["lessonID"];
    lectInCharge = data["lectInCharge"];
    isOpen = data["isOpen"];
    ipAddr = data["ipAddr"];
    moduleName = data["moduleName"];
    courseID = data["courseID"];
    school = data["school"];
  }

  Lesson.fromSnapshot(DocumentSnapshot snapshot){
    this.lessonID = snapshot["lessonID"];
    this.lectInCharge = snapshot["lectInCharge"];
    this.isOpen = snapshot["isOpen"];
    this.ipAddr = snapshot["ipAddr"];
    this.key = snapshot.documentID;
    this.moduleName = snapshot["moduleName"];
    this.courseID = snapshot["courseID"];
    this.school = snapshot["school"];
  }

  Future<String> getIP() async{
    final url = 'https://httpbin.org/ip';
    var httpClient = new Client();
    
    var response = await httpClient.get(url);
    return json.decode(response.body)["origin"];
  }
}

class JoinClassResult{
  bool success;
  String error;
  JoinClassResult(this.success, this.error);
}

class LocationResult{
  bool success;
  String error;
  LocationResult(this.success,this.error);
}

class AddClassModel{
  bool success;
  String lessonID;
  AddClassModel(this.success, this.lessonID);
}

class SettingsModel{
  bool ipCheck;
  bool locationCheck;
  String settingsLastSetBy;

  toJson(){
    return{
      "ipCheck" : ipCheck,
      "locationCheck" : locationCheck,
      "settingsLastSetBy" : settingsLastSetBy
    };
  }

  SettingsModel.fromJson(Map data){
    ipCheck = data["ipCheck"];
    locationCheck = data["locationCheck"];
    settingsLastSetBy = data["settingsLastSetBy"];
  }

  SettingsModel.fromSnapshot(AsyncSnapshot snapshot){
    this.ipCheck = snapshot.data["ipCheck"];
    this.locationCheck = snapshot.data["locationCheck"];
    this.settingsLastSetBy = snapshot.data["settingsLasetSetBy"];
  }
}

class CourseCreationResult{
  bool success;
  String error;
  CourseCreationResult(this.success,this.error);
}



class Course{
  String courseName;

  Course(this.courseName);
  toJson(){
    return{
      "courseName" : courseName,
    };
  }

  Course.fromJson(Map data){
    courseName = data["courseName"];
  }

  Course.fromSnapshot(AsyncSnapshot snapshot){
    this.courseName = snapshot.data["courseName"];
  }
}

class Module{
  String moduleName;

  Module(this.moduleName);
  toJson(){
    return{
      "moduleName" : moduleName,
    };
  }

  Module.fromJson(Map data){
    moduleName = data["moduleName"];
  }

  Module.fromSnapshot(AsyncSnapshot snapshot){
    this.moduleName = snapshot.data["moduleName"];
  }
}

class CourseGrp{
  String courseGrp;

  CourseGrp(this.courseGrp);
  toJson(){
    return{
      "courseGrp" : courseGrp,
    };
  }

  CourseGrp.fromJson(Map data){
    courseGrp = data["courseGrp"];
  }

  CourseGrp.fromSnapshot(AsyncSnapshot snapshot){
    this.courseGrp = snapshot.data["courseGrp"];
  }
}

class Attendance{
  int lessonsAbsent;
  int lessonsAttended;
  int lessonsLate;

  Attendance(this.lessonsAbsent,this.lessonsAttended, this.lessonsLate);
}