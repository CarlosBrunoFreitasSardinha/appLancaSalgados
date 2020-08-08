import 'dart:async';

import 'package:applancasalgados/interfaces/ILocalStorageInterface.dart';
import 'package:applancasalgados/services/SharedLocalStorageService.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

class AppBloc extends BlocBase {
  bool isDark = false;

  final StreamController<bool> _theme$ = StreamController<bool>();
  final ILocalStorageInterface storage = SharedLocalStorageService();

  Stream<bool> get theme => _theme$.stream;


  Future recuperaUsuarioLogado() async {
    storage.get('isDark').then((value) {
      if (value != null) {
        isDark = value;
        _theme$.add(isDark);
      }
    });
  }

  changeTheme() {
    isDark = !isDark;
    _theme$.add(isDark);
    storage.put('isDark', isDark);
  }


  @override
  dispose() {
    _theme$.close();
    super.dispose();
  }
}
