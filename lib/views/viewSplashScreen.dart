import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/services/CarrinhoService.dart';
import 'package:applancasalgados/services/UserService.dart';
import 'package:flutter/material.dart';


class ViewSplashScreen extends StatefulWidget {
  @override
  _ViewSplashScreenState createState() => _ViewSplashScreenState();
}

Future<void> recuperarUser() async {
  await UserService.recuperaDadosUsuarioLogado();
  CarrinhoService.futureCarrinho();
  return;
}

class _ViewSplashScreenState extends State<ViewSplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();

    recuperarUser();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    ).drive(Tween(begin: 0, end: 1));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
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
            child: GestureDetector(
          onTap: () {
            controller
              ..reset()
              ..forward();
          },
          child: RotationTransition(
            turns: animation,
            child: Center(
              child: Image.asset("imagens/logo.png"),
            ),
          ),
        )),
      ),
    );
  }
}
