import 'dart:async';
import '../RouteGenerator.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/background.jpg"),
                fit: BoxFit.cover)),

        padding: EdgeInsets.all(60),
        child: SafeArea(
            child: Center(
              child: Image.asset("imagens/logo.png"),
        )),
      ),
    );
  }
}
