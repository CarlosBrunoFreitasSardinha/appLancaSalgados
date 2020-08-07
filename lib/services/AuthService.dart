import 'dart:async';

import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/UserService.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends BlocBase {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Firestore _firebase = Firestore.instance;

  static Future<Stream<UsuarioModel>> streamUsuario() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var ref = Firestore.instance
        .collection('usuarios')
        .document(user.uid)
        .snapshots()
        .asBroadcastStream();

    return ref.map((snap) {
      if (snap.exists) {
        return UsuarioModel.fromJson(snap.data);
      } else {
        return null;
      }
    });
  }

  static Future<UsuarioModel> recuperaDadosUsuario() async {
    FirebaseUser fbUser = await FirebaseAuth.instance.currentUser();
    UsuarioModel user;
    Stream<UsuarioModel> streamUser;
    if (fbUser != null) {
      streamUser = await streamUsuario();
      streamUser = streamUser.take(1);
      await for (UsuarioModel i in streamUser) {
        if (i != null) {
          user = i;
        }
      }
    }
    return user;
  }

  static Future<bool> logar(UsuarioModel user) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
          email: user.email, password: user.senha);

      FirebaseUser firebaseUser = authResult?.user;

      if (firebaseUser != null) {
        await UserService.recuperaDadosUsuarioLogado();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> estaLogado() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseUser firebaseUser = await auth.currentUser();

      if (firebaseUser != null) {
        UserService.recuperaDadosUsuarioLogado();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> deslogar() async {
    await _auth.signOut();
    AppModel.to.bloc<AppBloc>().isLogged = false;
    AppModel.to.bloc<UserBloc>().userAddition.add(UsuarioModel());
    AppModel.to.bloc<CarrinhoBloc>().cartAddition.add(CarrinhoModel());
    return;
  }
}
