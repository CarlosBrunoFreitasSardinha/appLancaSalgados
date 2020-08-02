import 'dart:async';
import 'dart:io';

import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserFirebase {
  static Usuario fireLogged = Usuario();
  static FirebaseAuth auth = FirebaseAuth.instance;
  static bool logado = false;
  static String colection = "usuarios";

  static Future<Usuario> recuperaDadosUsuario() async {
    FirebaseUser usuarioLogado = await auth.currentUser();
    Map<String, dynamic> json =
        await UtilFirebase.recuperarUmObjeto(colection, usuarioLogado.uid);
    UserFirebase.fireLogged = Usuario.fromJson(json);
    UserFirebase.logado = true;
    print("Dados Usuario initial: " + UserFirebase.fireLogged.toString());
    return UserFirebase.fireLogged;
  }

  static deslogar() async {
    await auth.signOut();
    UserFirebase.logado = false;
    UserFirebase.fireLogged = Usuario();
  }

  Future getImage(bool i) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: i ? ImageSource.camera : ImageSource.gallery);
    File _image = File(pickedFile.path);
    if (_image != null) _uploadImagem(_image);
  }

  Future _uploadImagem(File _image) {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("perfil")
        .child(UserFirebase.fireLogged.uidUser + ".jpg");
    arquivo.putFile(_image);
    StorageUploadTask task = arquivo.putFile(_image);
    task.events.listen((event) {
      if (task.isInProgress) {
        print("progresso");
      } else if (task.isSuccessful) {
        print("Sucesso");
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) async {
      UserFirebase.fireLogged.urlPerfil = await snapshot.ref.getDownloadURL();
      _atualizarUsuarioFirebase();
    });
  }

  static _atualizarUsuarioFirebase() {
    UtilFirebase.alterarDados(colection, UserFirebase.fireLogged.uidUser, UserFirebase.fireLogged.toJson());
  }
}
