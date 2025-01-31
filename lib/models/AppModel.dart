import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/services/AuthService.dart';
import 'package:applancasalgados/stateLess/appWidget.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/src/widgets/framework.dart';

class AppModel extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => AppBloc()),
        Bloc((i) => UserBloc()),
        Bloc((i) => AuthService()),
        Bloc((i) => CarrinhoBloc()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => AppWidget();

  static Inject get to => Inject<AppModel>.of();
}
