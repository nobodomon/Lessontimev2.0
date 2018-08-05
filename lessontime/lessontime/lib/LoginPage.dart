import 'package:flutter/material.dart';
import 'package:lessontime/Logo.dart';
import 'package:lessontime/auth.dart';
import 'package:validator/validator.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.auth, this.onSignIn}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  static final formKey = new GlobalKey<FormState>();
  String _adminNo;
  String _email;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = '';
  bool _obscureText = true;
  Icon visibility = new Icon(Icons.visibility);

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
      if(_obscureText == true){
        visibility = new Icon(Icons.visibility);
      }else{
        visibility = new Icon(Icons.visibility_off);
      }
    });
  }

  void validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        String userId = _formType == FormType.login
            ? await widget.auth.signIn(_email, _password)
            : await widget.auth.createUser(_adminNo,_email, _password,0,true);
        setState(() {
          _authHint = 'Signed In\n\nUser id: $userId';
        });
        widget.onSignIn();
      }
      catch (e) {
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  List<Widget> usernameAndPassword() {
    switch(_formType){
      case FormType.login: {
        return [
          padded(child: new TextFormField(
            key: new Key('email'),
            style: TextStyle(color: Colors.white),
            decoration: new InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color.fromRGBO(63,81,181 , 70.0),
              prefixIcon: new Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.person,color: Colors.white,),
              ),
              hintText: "Email",
              hintStyle: TextStyle(
                color: Colors.white30
              ),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(50.0),
                borderSide: BorderSide.none
            )),
            autocorrect: false,
            validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
            onSaved: (val) => _email = val,
          )),
          padded(child: new TextFormField(
            style: TextStyle(color: Colors.white),
            key: new Key('password'),
            decoration: new InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color.fromRGBO(63,81,181 , 70.0),
              prefixIcon: new Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.lock,color: Colors.white,),
              ),
              suffixIcon: new Padding(
                padding: EdgeInsets.only(left:15.0),
                child: IconButton(
                  icon: visibility,
                  color: Colors.indigoAccent,
                  onPressed: ()=> _toggle(),
                )
              ),
              hintText: "Password",
              hintStyle: TextStyle(
                color: Colors.white30
              ),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(50.0),
                borderSide: BorderSide.none
              )),
            obscureText: _obscureText,
            autocorrect: false,
            
            validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => _password = val,
          )),
        ];
      }
      break;
      case FormType.register: {
        return [
          padded(child: new TextFormField(
            key: new Key('adminNo'),
            style: TextStyle(color: Colors.white),
            decoration: new InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color.fromRGBO(63,81,181 , 70.0),
              prefixIcon: new Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.person,color: Colors.white,),
              ),
              hintText: "Admin Number",
              hintStyle: TextStyle(
                color: Colors.white30
              ),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(50.0),
                borderSide: BorderSide.none
            )),
            autocorrect: false,
            validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
            onSaved: (val) => _email = val,
          )),
          padded(child: new TextFormField(
            key: new Key('email'),
            style: TextStyle(color: Colors.white),
            decoration: new InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color.fromRGBO(63,81,181 , 70.0),
              prefixIcon: new Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.person,color: Colors.white,),
              ),
              hintText: "Email",
              hintStyle: TextStyle(
                color: Colors.white30
              ),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(50.0),
                borderSide: BorderSide.none
            )),
            autocorrect: false,
            validator: (val){
              val.isEmpty ? 'Email can\'t be empty.' : null;
              if(isEmail(val)){
                null;
              }else{
                "Invalid email";
              }
            },

            onSaved: (val) => _email = val,
          )),
          padded(child: new TextFormField(
            style: TextStyle(color: Colors.white),
            key: new Key('password'),
            decoration: new InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color.fromRGBO(63,81,181 , 70.0),
              prefixIcon: new Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(Icons.lock,color: Colors.white,),
              ),
              hintText: "Password",
              hintStyle: TextStyle(
                color: Colors.white30
              ),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(50.0),
                borderSide: BorderSide.none
              )),
            obscureText: true,
            autocorrect: false,
            
            validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => _password = val,
          )),
        ];
      }
      default : {
        return [];
      }
    }
    
  }

  List<Widget> submitWidgets(BuildContext context) {
    switch (_formType) {
      case FormType.login:
        return [
          padded(child: new RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
            padding: EdgeInsets.all(15.0),
            shape: StadiumBorder(
            ),
            key: new Key('login'),
            child: new Text('Login'),
            onPressed:()=> validateAndSubmit(context)
          )),
          /* new FlatButton(
            
              key: new Key('need-account'),
              child: new Text("Need an account? Register", textAlign: TextAlign.right,),
              onPressed: moveToRegister
          ), */
        ];
      case FormType.register:
        return [
          padded(child: new RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
            padding: EdgeInsets.all(15.0),
            shape: StadiumBorder(
            ),
            key: new Key('register'),
            child: new Text('Register'),
            onPressed:()=> validateAndSubmit(context)
          )),
          /* new FlatButton(
              key: new Key('need-login'),
              child: new Text("Have an account? Login"),
              onPressed: moveToLogin
          ), */
        ];
    }
    return null;
  }

  Widget hintText() {
    return new Container(
        //height: 400.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(
            _authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center)
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          title: new Text(widget.title),
          backgroundColor: Colors.indigo,
          elevation: 0.0,
        ),
        backgroundColor: Colors.grey[300],
        body: new Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("lib/Assets/Background.png"), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            new SingleChildScrollView(
              child: new Container(
                padding: const EdgeInsets.all(16.0),
                child: new Column(
                  children: <Widget>[
                    new Logo(200.0, "lib/Assets/LessonTime.png"),
                    new Container(
                      padding: const EdgeInsets.all(16.0),
                      child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: usernameAndPassword() + submitWidgets(context),
                        )
                      )
                    ),
                    hintText()
                  ]
                )
              )
            )
          ],    
        )
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
