import 'dart:async';
import 'package:app_androids/login_screen.dart';
import 'package:app_androids/main.dart';
import 'package:flutter/material.dart';
import 'package:app_androids/home_screen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    Timer(const Duration(milliseconds: 1600), (){
      Navigator.pushReplacement(context,
          MaterialPageRoute(
          builder:(context) => LoginScreen(),
      ));
    });



     _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this
    );

    _animation = Tween<double>(begin: 5, end: 0).animate(_controller);

    _controller.forward();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: 500,
            height: 900,
            color: Colors.redAccent
          ),

          Center(
            child: Container(
              child: ScaleTransition(
                scale: _animation,
                child:  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/enigma.png', width: 150, height: 150,),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}