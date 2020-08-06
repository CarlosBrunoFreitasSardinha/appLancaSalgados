import 'dart:async';

import 'package:applancasalgados/interfaces/ILocalStorageInterface.dart';
import 'package:applancasalgados/services/SharedLocalStorageService.dart';
import 'package:bloc_pattern/bloc_pattern.dart';

class AppBloc extends BlocBase {
  bool _isLogged = false;
  bool isDark = false;

  final StreamController<bool> _theme$ = StreamController<bool>();
  final StreamController<bool> _UserLogged$ = StreamController<bool>();
  final ILocalStorageInterface storage = SharedLocalStorageService();

  Stream<bool> get theme => _theme$.stream;

  Stream<bool> get isAdministrator => _UserLogged$.stream;

  Future recuperaUsuarioLogado() async {
    storage.get('isLogged').then((value) {
      if (value != null) {
        isLogged = value;
        _UserLogged$.add(isLogged);
      }
    });
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

  bool get isLogged => _isLogged;

  set isLogged(bool value) {
    _isLogged = value;
    storage.put('isLogged', isLogged);
  }

  @override
  dispose() {
    _theme$.close();
    _UserLogged$.close();
    super.dispose();
  }
}
