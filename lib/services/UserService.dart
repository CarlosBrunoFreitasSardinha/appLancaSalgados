import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'BdService.dart';

class UserService {
  static Future<Stream<List<Usuario>>> streamUsers() async {
    var ref = Firestore.instance.collection('users');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Usuario.fromJson(doc.data)).toList());
  }

  static Future recuperaDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null) {
      Map<String, dynamic> json =
          await BdService.recuperarUmObjeto("usuarios", usuarioLogado.uid);
      AppModel.to.bloc<UserBloc>().userAddition.add(Usuario.fromJson(json));
      AppModel.to.bloc<AppBloc>().isLogged = true;
    }
  }

  static Future updateUser({
    Usuario user,
    bool isRegistering,
  }) async {
    if (isRegistering) {
      await Firestore.instance.collection('users_registrations').add(
        {
          'email': user.email,
          'isAdmin': false,
          'name': user.nome,
          'password': user.senha,
        },
      );
    } else {
      await Firestore.instance
          .collection('users')
          .document(user.uidUser)
          .setData({
        'email': user.email,
        'isAdmin': user.isAdm,
        'name': user.nome,
      }, merge: true);
    }
  }

  static Future updateUserPassword({
    Usuario user,
  }) async {
    await Firestore.instance.collection('users_update_password').add(
      {
        'password': user.senha,
        'userUid': user.uidUser,
      },
    );
  }
}
