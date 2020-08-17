import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/views/viewSplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OneSignal.shared.init(
      '5bec8cb7-2a5e-419f-aa7e-147bfaa031d7',
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false,
      },
    );

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    // Ao criar a instancia (que deve acontecer apenas uma vez)
    // o sistema ja deve guardar o playerID do OneSignal
    OneSignal.shared.getPermissionSubscriptionState().then((status) {
      AppModel.to.bloc<UserBloc>().playId = status.subscriptionStatus.userId;
    });

    final ThemeData temaPadrao = ThemeData(
        primaryColor: Color(0xff5c3838), accentColor: Color(0xffd19c3c));

    return StreamBuilder<Object>(
        stream: AppModel.to.bloc<AppBloc>().theme,
        initialData: false,
        builder: (context, snapshot) {
          return MaterialApp(
            title: "Lança Salgados",
            home: ViewSplashScreen(),
            theme: temaPadrao,
            // ignore: missing_return
            onGenerateRoute: RouteGenerator.generateRoute,
            initialRoute: "/",
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
