import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersService {
  static Future<Stream<List<Usuario>>> streamUsers() async {
    var ref = Firestore.instance.collection('users');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Usuario.fromJson(doc.data)).toList());
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
