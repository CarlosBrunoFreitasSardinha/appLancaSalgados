import 'dart:async';

import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/BdService.dart';

class UserFirebase extends BlocBase {
  Usuario _usuario = Usuario();

  final StreamController<Usuario> _User$ = StreamController<Usuario>();

  Stream<Usuario> get isAdministrator => _User$.stream;

  Future recuperaDadosUsuarioLogado() async {
    String colection = "usuarios";
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null) {
      Map<String, dynamic> json =
          await BdService.recuperarUmObjeto(colection, usuarioLogado.uid);
      usuario = Usuario.fromJson(json);
      AppModel.to.bloc<AppBloc>().isLogged = true;
    }
    _User$.add(usuario);
  }

  Usuario get usuario => _usuario;

  set usuario(Usuario value) {
    _usuario = value;
    _User$.add(value);
  }

  @override
  dispose() {
    _User$.close();
    super.dispose();
  }
}
