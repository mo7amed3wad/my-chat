import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../componates/roundedBotton.dart';
import '../constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showSpinner =false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
              child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                  tag: 'logo',
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                 
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    //Do something with the user input.
                    email=value;
                  },
                  decoration: kMessageTtextfieldDecoration.copyWith(hintText: "Enter your Email" ,) 
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                  password=value;
                  },
                  decoration:kMessageTtextfieldDecoration.copyWith(hintText: "Enter your Password") 
                ),
                SizedBox(
                  height: 24.0,
                ),
               RoundedButton(
                color: Colors.cyan,
                title: "LogIn",
                onpressed: () async{
                   setState(() {
                          showSpinner =true;
                        });
                  try{
                  final user =await _auth.signInWithEmailAndPassword(email: email, password: password);
                if(user!=null){
                  Navigator.pushReplacementNamed(context, ChatScreen.id);
                  setState(() {
                          showSpinner =false;
                        });
                }
                  }catch(e){
                    print(e.toString());
                  }
                },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
