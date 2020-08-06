import 'dart:async';

import 'package:applancasalgados/bloc/UserFireBaseBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/services/BdFireBase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Autenticacao {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static Future<Usuario> recuperaDadosUsuario() async {
    String colection = "usuarios";
    FirebaseUser usuarioLogado = await auth.currentUser();
    Usuario usuario = Usuario();

    if (usuarioLogado != null) {
      Map<String, dynamic> json =
          await UtilFirebase.recuperarUmObjeto(colection, usuarioLogado.uid);
      usuario = Usuario.fromJson(json);
      AppModel.to.bloc<AppBloc>().isLogged = true;
      AppModel.to.bloc<UserFirebase>().usuario = usuario;
    }
    return usuario;
  }

  static deslogar() async {
    await auth.signOut();
    AppModel.to.bloc<AppBloc>().isLogged = false;
    AppModel.to.bloc<UserFirebase>().usuario = Usuario();
  }

  static Future<bool> logarUsuario(Usuario user) async {
    bool result = false;
    String colection = "usuarios";
    Usuario usuario = Usuario();
    auth
        .signInWithEmailAndPassword(email: user.email, password: user.senha)
        .then((userFirebase) async {
      if (userFirebase != null) {
        Map<String, dynamic> json = await UtilFirebase.recuperarUmObjeto(
            colection, userFirebase.user.uid);
        usuario = Usuario.fromJson(json);
        AppModel.to.bloc<AppBloc>().isLogged = true;
        AppModel.to.bloc<UserFirebase>().usuario = usuario;
      }
      result = true;
      return;
    }).catchError((onError) {
      print("Erro: " + onError.toString());
    });
    print("ServiceAutenticacao result = 3 " + result.toString());
    return result;
  }
}
