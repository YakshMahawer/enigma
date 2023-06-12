import 'package:app_androids/reusable_widgets.dart';
import 'package:app_androids/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{

  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/login.png', width: 220, height: 150,),
              const SizedBox(
                child: Text("Welcome Back, ", style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800, fontFamily: 'Ubuntu'),),
              ),
              const SizedBox(
                child: Text("Remembering Alan Turing", style: TextStyle(fontSize: 15, fontFamily: 'Ubuntu'),),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: reusableTextField("Enter Username", Icons.account_circle, false, _usernameTextController, Colors.black54, (String value){}
                  )),
              Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: reusableTextField("Enter Password", Icons.badge_outlined, true, _passwordTextController, Colors.black54, (String value){}
                  )),
              SignInSignUpButton(context, true, (){
                FirebaseFirestore.instance.collection("userInfo").where("restaurant_email", isEqualTo: _usernameTextController.text).get().then(
                      (querySnapshot) async {
                    print("Successfully completed");
                    for (var docSnapshot in querySnapshot.docs) {
                      Map<String, dynamic> details = docSnapshot.data();
                      details["doc_id"] = docSnapshot?.id;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyHomePage('',details))
                      );
                    }
                  },
                  onError: (e) => print("Error completing: $e"),
                );
              }),
              signUpOption()
            ],
          ),
        ),
      ),
    );
  }
  Container signUpOption(){
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account ? ",
              style: TextStyle(fontSize: 14, fontFamily: 'Ubuntu', color: Colors.black54)),
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignUpScreen())
              );
            },
            child: Text(" Sign Up",
                style: TextStyle(decoration: TextDecoration.underline , decorationThickness: 5,fontSize: 12, fontFamily: 'Ubuntu', color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}