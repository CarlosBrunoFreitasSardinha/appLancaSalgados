import 'dart:async';

import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/CarrinhoService.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {
  UsuarioModel usuario = UsuarioModel();
  bool isLogged = false;

  /// Sinks
  Sink<UsuarioModel> get userAddition => userLoggedController.sink;
  final userLoggedController = StreamController<UsuarioModel>();

  /// Streams
  Stream<UsuarioModel> get userLogged => _User$.stream;
  final _User$ = BehaviorSubject<UsuarioModel>();

  UserBloc() {
    userLoggedController.stream.listen(recUser);
  }

  /// Logic for product removed from shopping cart.
  void recUser(UsuarioModel thisUser) {
    usuario = thisUser;
    _User$.add(usuario);
    CarrinhoService.futureCarrinho();
    return;
  }

  @override
  dispose() {
    userLoggedController.close();
    super.dispose();
  }
}