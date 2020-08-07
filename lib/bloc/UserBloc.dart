import 'dart:async';

import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/CarrinhoService.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {
  Usuario usuario = Usuario();

  /// Sinks
  Sink<Usuario> get userAddition => userLoggedController.sink;
  final userLoggedController = StreamController<Usuario>();

  /// Streams
  Stream<Usuario> get userLogged => _User$.stream;
  final _User$ = BehaviorSubject<Usuario>();

  UserBloc() {
    userLoggedController.stream.listen(recUser);
  }

  /// Logic for product removed from shopping cart.
  void recUser(Usuario thisUser) {
    usuario = thisUser;
    _User$.add(usuario);
    CarrinhoService.futureCarrinho();
    return;
  }

  @override
  dispose() {
    _User$.close();
    super.dispose();
  }
}
