import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:lessontime/models/Model.dart';
import 'package:device_info/device_info.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';


class FirebaseLink{
  Device device;

  static Future<DocumentSnapshot> getUserOnceFs(String email) async{
    Firestore _fs = Firestore.instance;
    String trimmed = email.split("@")[0];
    print(trimmed + " is the search string");
    return _fs.collection("Users").document(trimmed.toUpperCase()).get();
  }

  
  static Future<DocumentSnapshot> getUserOnceFsNoTrim(String email) async{
    Firestore _fs = Firestore.instance;
    String touppercase = email.toUpperCase();
    print(touppercase + " is the search string");
    return _fs.collection("Users").document(touppercase.toUpperCase()).get();
  }


  static Future<Stream<DocumentSnapshot>> getUserStreamFs(String email) async{
    Firestore _fs = Firestore.instance;
      String trimmed = email.substring(0,email.length-18).toUpperCase();
    return _fs.collection("Users").document(trimmed).snapshots();
  }

  static Future<Stream<DocumentSnapshot>> getUserStreamFsAdminNo(String email) async{
    Firestore _fs = Firestore.instance;
      String trimmed = email.substring(0,email.length-18).toUpperCase();
    return _fs.collection("Users").document(trimmed).snapshots();
  }
  

  static void setLastLogin(String adminNo){
      String trimmed = adminNo.substring(0,adminNo.length-18).toUpperCase();
      Firestore.instance.collection("Users").document(trimmed).setData({"lastLogin": DateTime.now().toIso8601String()}, merge: true);
  }

  static void setLogonIP(String adminNo) async{
      String trimmed = adminNo.substring(0,adminNo.length-18).toUpperCase();
      String ip = await getIP();
      Firestore.instance.collection("Users").document(trimmed).setData({"logonIP": ip}, merge: true);
  }

  static Future<String> createUserFs(String adminNo, int userType, bool setDeviceDetails) async{
    if(setDeviceDetails){
      return await getDeviceDetails().then((Device dev){
        adminNo.toUpperCase();
        String trimmed = adminNo.substring(0,adminNo.length-18).toUpperCase();
        Users toAdd = new Users(adminNo, userType);

        Firestore.instance.collection("Users").document(trimmed).setData(toAdd.toJson());
        Firestore.instance.collection("Users").document(trimmed).collection("device").add(dev.toJson());
        return adminNo;
      });
    }else{
      adminNo.toUpperCase();
        String trimmed = adminNo.substring(0,adminNo.length-18).toUpperCase();
        Users toAdd = new Users(adminNo, userType);

        Firestore.instance.collection("Users").document(trimmed).setData(toAdd.toJson());
        return adminNo;
    }
  }


  static void setUserSchoolAndCourse(String adminNo, String school, String course, String group){
    Firestore.instance.collection("Users").document(adminNo).setData({"school": school, "course": course, "group": group}, merge:  true);
  }

  static Future<Device> getDeviceDetails() async {
    String deviceName;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        identifier = build.id;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        identifier = data.identifierForVendor;//UUID for iOS
      }
    } on Exception {
      print('Failed to get platform version');
    }

//if (!mounted) return;
    print(deviceName);
    print (identifier);
  return new Device(deviceName, identifier);
  }

  static Future<AddClassModel> startClass(String lectIC,String school, String courseID, String module) async{
    Lesson lesson = new Lesson(lectIC,school,courseID,module);
    return await checkIfModuleExists(school, courseID, module).then((bool res){
      if(res){
        return getIP().then((string){
        lesson.ipAddr = string;
        Firestore.instance.collection("Lessons").add(lesson.toJson());
        return new AddClassModel(true, lesson.lessonID);
        });
      }else{
        return new AddClassModel(false, "Module does not exist");
      }
      
    });
    
    
  }

  

  static void resumeClass(String key) async{
    key = key.toUpperCase();
    Firestore.instance.collection("Lessons").where("lessonID", isEqualTo: key).getDocuments().then((QuerySnapshot snapshot){
      String docID = snapshot.documents.first.documentID;
      if(docID == null){
        return false;
      }
      Firestore.instance.collection("Lessons").document(docID).setData({'isOpen' : true},merge:  true);
      return true;
    });
  }
  static void stopClass(String key) async{
    key = key.toUpperCase();
     Firestore.instance.collection("Lessons").where("lessonID", isEqualTo: key).getDocuments().then((QuerySnapshot snapshot){
      String docID = snapshot.documents.first.documentID;
      if(docID == null){
        return false;
      }
      Firestore.instance.collection("Lessons").document(docID).setData({'isOpen' : false},merge:  true);
      return true;
    });
  }

  static Future<bool> deleteClass(String key) async{
    key = key.toUpperCase();
    return Firestore.instance.collection("Lessons").where("lessonID", isEqualTo: key).getDocuments().then((QuerySnapshot snapshot){
      snapshot.documents.first.reference.delete();
      return true;
    });
  }

  static Future<JoinClassResult> markLateness(String key, String adminNo, bool yesNo) async {
    if(yesNo){ 
      return await markAsLate(key, adminNo).then((JoinClassResult res){
        return new JoinClassResult(true, "Student is marked as late.");
      });
    }else{
      return await unMarkLate(key, adminNo).then((JoinClassResult res){
        return new JoinClassResult(true, "Student is not late.");
      });
    }
  }

  static Future<JoinClassResult> markAsLate(String key, String adminNo) async{
    return getClassList(key).then((QuerySnapshot classList){
        classList.documents.forEach((DocumentSnapshot student){
          if(student.documentID == adminNo){
            return student.reference.setData({"isLate": true}, merge:  true).then((_){
              return Firestore.instance.collection("Users").document(adminNo).collection("Attended").document(key).setData({"isLate": true},merge: true).then((_){
                
              return new JoinClassResult(true, "Student is marked as late.");
              });
            });
          }else{
            return new JoinClassResult(false, "Unable to mark as late.");
          }
        });
    });
  }

  
  static Future<JoinClassResult> unMarkLate(String key, String adminNo) async{
    return getClassList(key).then((QuerySnapshot classList){
        classList.documents.forEach((DocumentSnapshot student){
          if(student.documentID == adminNo){
            return student.reference.setData({"isLate": false}, merge:  true).then((_){
              return Firestore.instance.collection("Users").document(adminNo).collection("Attended").document(key).setData({"isLate": false},merge: true).then((_){
                return new JoinClassResult(true, "Student is marked as late.");
              });
            });
          }else{
            return new JoinClassResult(false, "Unable to mark as late.");
          }
        });
    });
  }


  static Future<bool> checkifClassExist(String key) async{
    key = key.toUpperCase();
    try{
      return await Firestore.instance.collection("Lessons").where("lessonID", isEqualTo: key).getDocuments().then((QuerySnapshot snapshot){
        int count = snapshot.documents.length;
        if(count > 0 && count != null){
          return true;
        }else{
          return false;
        }
      });
    }catch(error){
      print(error.toString());
      return false;
    }
  }

  static Future<String> getIP() async{
    final url = 'https://httpbin.org/ip';
    var httpClient = new Client();
    
    var response = await httpClient.get(url);
    return json.decode(response.body)["origin"];
  }

  static Future<JoinClassResult> checkIfStudentSupposedToJoin(String adminNo, String key){
    return getUserOnceFsNoTrim(adminNo).then((DocumentSnapshot student){
      return getClass(key).then((QuerySnapshot lessonQuery){
        if(lessonQuery.documents.length < 1){
          return new JoinClassResult(false, "Class wasn't found");
        }else{
          if(lessonQuery.documents.first.data["courseID"] == student.data["course"]){
            return new JoinClassResult(true, "Student is in the right course");
          } 
        }
      });
    });
  }

  static bool checkIfAcceptableIP(String usrIP, bool toggle){
    if(toggle){
      List<String> split = usrIP.split('.');
      //Acceptable range of 3rd subnet 94-95
      //Acceptable range of 4th subnet 0-255
      //Using this as we did a whois on nyp domain
      //Nyp owns 202.12.94.0 - 202.12.95.255
      int firstNum = int.parse(split[0]);
      int secondNum = int.parse(split[1]);
      int thirdNum = int.parse(split[2]);
      int fourthNum = int.parse(split[3]);
      if(firstNum == 202 && secondNum == 12){
        if(thirdNum == 94 || thirdNum == 95){
          if(fourthNum >= 0  && fourthNum <= 255){
            return true;
          }else{
            return false;
          }
        }else{
          return false;
        }
      }else{
        return false;
      }
    }else{
      return true;
    }
  }
  
  static Future<Map<String,double>> getLocation() async{
    Location location = new Location();
    try{
      return location.getLocation.then((Map<String,double> val){
        return val;
      });
    }catch(PlatformException){
      return null;
    }
  }

  static LocationResult checkIfAcceptableLocationRange(Map<String, double> location, bool toggle){
    if(toggle){
      if(location == null){
        return new LocationResult(false, "Failed to get location, are you sure your location is on?");
      }else{
        //NYP Coordinates 1.3801° N, 103.8490° E
        //estimated acceptable range latitude 1.377 > 1.3802
        //estimated acceptable range longtitude 103.848 > 103.851
        double latitude = location.values.toList()[1];
        String lat = latitude.toStringAsFixed(3);
        double longtitude = location.values.toList()[5];
        String long = longtitude.toStringAsFixed(3);
        longtitude = double.parse(long);
        latitude = double.parse(lat);
        if((latitude >= 1.377 && latitude <= 1.382) && (longtitude >= 103.848 && longtitude <= 103.851)){
          return new LocationResult(true, "You are within boundaries.");
        }else{
          return new LocationResult(false, "You are not within boundaries.");
        }
      }
    }else{
      return new LocationResult(true, "Location check bypassed.");
    }
  }

  static Future<JoinClassResult> addStudentToClassManually(String adminNo, String key)async{
    key = key.toUpperCase();
    try{
      return await getUserOnceFsNoTrim(adminNo).then((DocumentSnapshot snapshot){
        if(snapshot.exists){
          return checkIfInClass(key, adminNo).then((bool isInClass){
            if(isInClass == false){
              return Firestore.instance.collection("Lessons").where("lessonID", isEqualTo:  key).getDocuments().then((QuerySnapshot classes){
                if(classes.documents.length > 0){
                  String docID = classes.documents.first.documentID;
                  print(docID);
                  return Firestore.instance.collection("Lessons").document(docID).collection("Students").document(adminNo).setData(Users.fromSnapshot(snapshot).toJson()).then((_){
                    Firestore.instance.collection("Users").document(adminNo).collection("Attended").document(key).setData({"isLate": false,"moduleName": classes.documents.first.data["moduleName"]},merge: true);
                    return unMarkLate(key, adminNo).then((JoinClassResult mark){
                      return new JoinClassResult(true, "Student successfully added");
                    });
                  });
                }else{
                  return new JoinClassResult(false, "Class not found.");
                }
              });
            }else{
              return new JoinClassResult(false, "This student is already in this class!");
            }
          });
        }else{
          return new JoinClassResult(false, "This Student does not exist!");
        }
      });
    }catch(error){
      print(error.toString());
      return new JoinClassResult(false, error.toString());
    }
  }

  static Future<JoinClassResult> joinClass(Users user, String key) async{
    key = key.toUpperCase();
    bool existQuery;
    try{
      return await getIP().then((String value){
        //get IP first
        return getSettings().then((DocumentSnapshot settingsSc){
          //get Settings from db
          if(checkIfAcceptableIP(value, settingsSc["ipCheck"])){
            //check if ip is in range
            return getLocation().then((Map<String, double> location){
              //get Location coordinates
              LocationResult locationcheck = checkIfAcceptableLocationRange(location, settingsSc["locationCheck"]);
              if(locationcheck.success){
                //check for conditions
                return checkIfInClass(key, user.adminNo).then((bool result){
                //check if student is already in class
                print("joinClass result: " + result.toString());
                existQuery = result;
                  return Firestore.instance.collection("Lessons").where("lessonID", isEqualTo: key).getDocuments().then((QuerySnapshot snapshot){
                    //check if class exist
                    if(snapshot.documents.length == 0){
                      return new JoinClassResult(false, "Class #$key not found.");
                    }else{
                      String docID = snapshot.documents.first.documentID;
                      if(docID == null){
                        return new JoinClassResult(false, "Class #$key not found.");
                      }else{
                        return checkIfStudentSupposedToJoin(user.adminNo, key).then((JoinClassResult suppose){
                          if(suppose.success){
                            if(existQuery == true){
                              return new JoinClassResult(false, "You have already joined this class.");
                            }else if(existQuery == false){
                              bool isOpen = snapshot.documents.first.data["isOpen"];
                              if(isOpen){
                                Firestore.instance.collection("Lessons").document(docID).collection("Students").document(user.adminNo).setData(user.toJson());
                                Firestore.instance.collection("Lessons").document(docID).collection("Students").document(user.adminNo).setData({"isLate": false},merge: true);
                                Firestore.instance.collection("Users").document(user.adminNo).collection("Attended").document(key).setData({"isLate": false,"moduleName": snapshot.documents.first.data["moduleName"]},merge: true);
                                print("Added to class: " + docID);
                                return new JoinClassResult(true,"You have successfully joined class #$key.");
                              }else{
                                print("Class is closed");
                                return new JoinClassResult(false, "Class #$key has been closed.");
                              }
                            }else{
                              return new JoinClassResult(false, "Error, Please contact an admin.");
                            }
                          }else{
                            return new JoinClassResult(suppose.success, suppose.error);
                          }
                        });
                      }
                    }
                  });
                });
              }else{
                return new JoinClassResult(false, locationcheck.error);
              }
            });
          }else{
            return new JoinClassResult(false, "You did not satisfy the join conditions. Please connect to the school's wifi and try again!");
          }
        });
      });
    }catch(error){
      print(error);
      return new JoinClassResult(false, error.toString());
    }
  }

  static Future<QuerySnapshot> getClass(String key) async{
    key = key.toUpperCase();
    return Firestore.instance.collection("Lessons").where("lessonID", isEqualTo:  key).snapshots().first;
  }

  static Future<QuerySnapshot> getClassList(String key) async{
    key = key.toUpperCase();
    return Firestore.instance.collection("Lessons").where("lessonID", isEqualTo: key).snapshots().first.then((QuerySnapshot snapshot){
      return snapshot.documents.first.reference.collection("Students").getDocuments();
    });
  }

  static Future<Stream<QuerySnapshot>> getClassListSnapshot(String key) async{
    key = key.toUpperCase();
    return Firestore.instance.collection("Lessons").where("lessonID",isEqualTo: key).snapshots().first.then((QuerySnapshot snapshot){
      return snapshot.documents.first.reference.collection("Students").snapshots();
    });

  }

  
  static Future<CourseCreationResult> createCourse(String school, String courseID, String courseName)async{
    try{
      Course toAdd = new Course(courseName);
      return await checkIfCourseExist(school, courseID).then((bool res){
        if(res){
          return new CourseCreationResult(false, "A course with that ID already exists!");
        }else{
          return  Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).setData(toAdd.toJson()).
          then((_){
            return new CourseCreationResult(true, "Course successfully created.");
          });
        }
      });
    }catch(error){
      return new CourseCreationResult(false, error.toString());
    }
  }
  
  static Future<QuerySnapshot> getAllCourses(String school) async{
    return await Firestore.instance.collection("School").document(school).collection("Courses").getDocuments();
  }

  static Future<CourseCreationResult> addModules(String school, String courseID, String moduleName)async{
    try{
      Module toAdd = new Module(moduleName);
      return await Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Modules").document(toAdd.moduleName).setData(toAdd.toJson()).then((_){
        return new CourseCreationResult(true, "Module added");
      });
    }catch(error){
      return new CourseCreationResult(false, error.toString());
    }
  }

  static Future<CourseCreationResult> removeModules(String school, String courseID, String moduleName)async{
    try{
      return await Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Modules").document(moduleName).delete().then((_){
        return new CourseCreationResult(true, "Module Successfully deleted");
      });
    }catch(error){
      return new CourseCreationResult(false, error.toString());
    }
  }

  static Future<CourseCreationResult> addCourseGrps(String school, String courseID, String moduleGrp)async{
    try{
      CourseGrp toAdd = new CourseGrp(moduleGrp);
      return await Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Groups").document(moduleGrp).setData(toAdd.toJson()).then((_){
        return new CourseCreationResult(true, "Module Group successfully added");
      });
    }catch(error){
      return new CourseCreationResult(false, error.toString());
    }
  }

  static Future<CourseCreationResult> removeCourseGrp(String school, String courseID, String moduleGrp)async{
    try{
      return await Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Groups").document(moduleGrp).delete().then((_){
        return new CourseCreationResult(true, "Module Group successfully deleted");
      });
    }catch(error){
      return new CourseCreationResult(false, error.toString());
    }
  }

  static Future<DocumentSnapshot> getCourse(String school, String courseID) async{
    return Firestore.instance.collection("School").document(school).collection("courses").document(courseID).get();
  }

  static Future<QuerySnapshot> getCourseModules(String school, String courseID) async{
    return Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Modules").getDocuments();
  }

  static Future<QuerySnapshot> getModulesTakenByStudent(String adminNo){
    return getUserOnceFsNoTrim(adminNo).then((DocumentSnapshot user){
      return getCourseModules(user.data["school"], user.data["course"]).then((QuerySnapshot modules){
        return modules;
      });
    });
  }

  static Future<QuerySnapshot> getCourseGrps(String school, String courseID) async{
    return Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Groups").getDocuments();
  }
  
  static Future<bool> checkIfCourseExist(String school, String courseID) async{
    return await Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).get().then((DocumentSnapshot ss){
      if(ss.exists){
        return true;
      }else{
        return false;
      }
    });
  }

  static Future<bool> checkIfModuleExists(String school, String courseID, String moduleID)async{
    return await Firestore.instance.collection("School").document(school).collection("Courses").document(courseID).collection("Modules").document(moduleID).get().then((DocumentSnapshot sc){
      if(sc.exists){
        return true;
      }else{
        return false;
      }
    });
  }

  static Future<List<DocumentSnapshot>> getClassListOfUser(String adminNo) async{
    List<DocumentSnapshot> snapshots = new List<DocumentSnapshot>();
    await Firestore.instance.collection("Lessons").getDocuments().then((QuerySnapshot snapshot){
      snapshot.documents.forEach((DocumentSnapshot dc){
        if(dc.reference.collection("Students").document(adminNo).get() != null){
          snapshots.add(dc);
        }
      });
    });
    return snapshots;
  }
 
  Future<Attendance> getClassAttendanceOfUserByModule(String adminNo,String module) async{
    int attended = 0;
    int lateSnapshots = 0;
    int absent;
    absent = await getLessonCountByModule(module);
    attended = await getUserParticipation(adminNo, module);
    lateSnapshots = await getlateUserParticipation(adminNo, module);
    absent = absent - attended - lateSnapshots;
    return new Attendance(absent, attended, lateSnapshots);
  }

  Future<int> getUserParticipation(String adminNo,String module)async {
    return await Firestore.instance.collection("Users").document(adminNo).collection("Attended").where("moduleName" ,isEqualTo:  module).where("isLate", isEqualTo:  false).getDocuments().then((QuerySnapshot lessons){
      return lessons.documents.length;
    });
  }

  Future<int> getlateUserParticipation(String adminNo,String module)async {
    return await Firestore.instance.collection("Users").document(adminNo).collection("Attended").where("moduleName" ,isEqualTo:  module).where("isLate", isEqualTo:  true).getDocuments().then((QuerySnapshot lessons){
      return lessons.documents.length;
    });
  }


  static Future<int> getLessonCountByModule(String module) async{
    return await Firestore.instance.collection("Lessons").where("moduleName", isEqualTo:  module).getDocuments().then((QuerySnapshot snapshot){
      return snapshot.documents.length;
    });
  }

  static Future<bool> checkIfInClass(String key, String adminNo) async{
    key = key.toUpperCase();
    try{
      return await Firestore.instance.collection("Lessons").where("lessonID",isEqualTo: key).snapshots().first.then((QuerySnapshot snapshot){
        return snapshot.documents.first.reference.collection("Students").where("adminNo", isEqualTo: adminNo).limit(1).getDocuments().then((QuerySnapshot snapshot){
          int found = snapshot.documents.length;
          if(found > 0){
            return true;
          }else{
            return false;
          }
        });
        
      });
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  static Future<JoinClassResult> assignGroupForStudent(String adminNo, String courseID, String school, String groupID) async{
    return await getUserOnceFsNoTrim(adminNo).then((DocumentSnapshot userSnap){
      Users retrieve = Users.fromSnapshot(userSnap);
      retrieve.school = school;
      retrieve.course = courseID;
      retrieve.group = groupID;
      return Firestore.instance.collection("Users").document(adminNo).setData(retrieve.toJson(),merge: false).then((_){
        return new JoinClassResult(true, "Successfully assigned");
      });
    });
  }

  static Future<DocumentSnapshot> getSettings() async{
    return Firestore.instance.collection("Settings").document("Settings").get();
  }

  static Future<bool> setSettings(SettingsModel model) async{
    try{
      Firestore.instance.collection("Settings").document("Settings").setData(model.toJson());
      return true;
    }catch(error){
      return false;
    }
  }
}