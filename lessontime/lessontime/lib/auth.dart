import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebaselink.dart';

abstract class BaseAuth {

  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String username, String email, String password, int userType, bool deviceDetails);
  Future<FirebaseUser> currentUserAct();
  Future<void> signOut();
}

class MyAuth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    FirebaseLink.setLastLogin(email);
    FirebaseLink.setLogonIP(email);
    return user.uid;
  }

  Future<String> createUser(String username, String email, String password, int userType, bool deviceDetails) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((FirebaseUser usr){
      if(usr.uid != null){
        return FirebaseLink.createUserFs(email, userType,deviceDetails).then((String adminNo){
          
          return usr.uid;
        });
      }else{

      }
    });
/*     return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((FirebaseUser usr){
      if(usr.uid != null){
      }else{

      }
    }); */
  }

  void editUser() async{
    String _email;
    _firebaseAuth.currentUser().then((FirebaseUser user){
      _email = user.email;
      FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    });
  }

  Future<FirebaseUser> currentUserAct() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user : null;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }


  Future<void> signOut() async {
    print("Logged out");
    return _firebaseAuth.signOut();
  }
}