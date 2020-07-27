import 'dart:io';
import 'package:flutter/material.dart';

import 'RouteGenerator.dart';
import 'package:applancasalgados/views/SplashScreen.dart';

void main() {

  final ThemeData temaPadrao = ThemeData(
      primaryColor: Color(0xff5c3838), accentColor: Color(0xffd19c3c));

  final ThemeData temaIOS =
      ThemeData(primaryColor: Colors.grey[200], accentColor: Color(0xffd19c3c));

  runApp(MaterialApp(
    title: "Lança Salgados",
    home: SplashScreen(),
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    // ignore: missing_return
    onGenerateRoute: RouteGenerator.generateRoute,
    initialRoute: "/",
    debugShowCheckedModeBanner: false,
  ));
}
