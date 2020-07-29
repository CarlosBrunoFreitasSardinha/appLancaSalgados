import 'package:applancasalgados/views/SplashScreen.dart';
import 'package:flutter/material.dart';

import 'RouteGenerator.dart';

void main() {

  final ThemeData temaPadrao = ThemeData(
      primaryColor: Color(0xff5c3838), accentColor: Color(0xffd19c3c));

  runApp(MaterialApp(
    title: "Lança Salgados",
    home: SplashScreen(),
    theme: temaPadrao,
    // ignore: missing_return
    onGenerateRoute: RouteGenerator.generateRoute,
    initialRoute: "/",
    debugShowCheckedModeBanner: false,
  ));
}
