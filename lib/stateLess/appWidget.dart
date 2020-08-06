import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/views/viewSplashScreen.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData temaPadrao = ThemeData(
        primaryColor: Color(0xff5c3838), accentColor: Color(0xffd19c3c));

    return StreamBuilder<Object>(
        stream: AppModel.to.bloc<AppBloc>().theme,
        initialData: false,
        builder: (context, snapshot) {
          return MaterialApp(
            title: "Lança Salgados",
            home: SplashScreen(),
            theme: temaPadrao,
            // ignore: missing_return
            onGenerateRoute: RouteGenerator.generateRoute,
            initialRoute: "/",
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
