import 'package:app_androids/home_screen.dart';
import 'package:app_androids/login_screen.dart';
import 'package:app_androids/reusable_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  Map<String,int> category_map = {};

  createUser(){
    DocumentReference documentReference = FirebaseFirestore.instance.collection("userInfo").doc();
    Map<String, dynamic> userDetails = {
      "restaurant_name": _usernameTextController.text,
      "restaurant_email": _emailTextController.text,
      "restaurant_categories": category_map
    };
    documentReference.set(userDetails);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/signup.png', width: 220, height: 150,),
              const SizedBox(
                child: Text("Get On Board", style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800, fontFamily: 'Ubuntu'),),
              ),
              const SizedBox(
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text("Those who can imagine anything, can create IMPOSSIBLE", style: TextStyle(fontSize: 15, fontFamily: 'Ubuntu'),),
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: reusableTextField("Enter Your Name", Icons.account_circle, false, _usernameTextController, Colors.black54, (String value){}
                  )),
              Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: reusableTextField("Enter E-Mail", Icons.mail, false, _emailTextController, Colors.black54, (String value){}
                  )),
              Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: reusableTextField("Enter Password", Icons.badge_outlined, true, _passwordTextController, Colors.black54, (String value){}
                  )),
              SignInSignUpButton(context, false, (){
                createUser();
                FirebaseFirestore.instance.collection("userInfo").where("restaurant_email", isEqualTo: _emailTextController.text).get().then(
                      (querySnapshot) {
                    print("Successfully completed");
                    for (var docSnapshot in querySnapshot.docs) {
                      Map<String, dynamic> _details = docSnapshot.data();
                      _details["doc_id"] = docSnapshot?.id;
                      FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailTextController.text, password: _passwordTextController.text).then((value){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyHomePage('Yaksh', _details))
                        );
                      });
                    }
                  },
                  onError: (e) => print("Error completing: $e"),
                );
              }),
              logInOption()
            ],
          ),
        ),
      ),
    );
  }

  Container logInOption(){
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Go Back To ",
              style: TextStyle(fontSize: 14, fontFamily: 'Ubuntu', color: Colors.black54)),
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen())
              );
            },
            child: Text(" Log In",
                style: TextStyle(decoration: TextDecoration.underline , decorationThickness: 5,fontSize: 12, fontFamily: 'Ubuntu', color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
