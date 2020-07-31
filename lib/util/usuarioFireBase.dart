import 'dart:async';
import 'dart:io';

import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserFirebase {
  static Usuario fireLogged = Usuario();
  static FirebaseAuth auth = FirebaseAuth.instance;
  static bool logado = false;
  static String colection = "usuarios";

  static recuperaDadosUsuario() async {
    FirebaseUser usuarioLogado = await auth.currentUser();

    Firestore bd = Firestore.instance;
    DocumentSnapshot snapshot =
        await bd.collection(colection).document(usuarioLogado.uid).get();
    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      UserFirebase.fireLogged = Usuario.fromJson(dados);
      UserFirebase.logado = true;

        print("Dados Usuario initial: " + UserFirebase.fireLogged.toString());
    }
  }

  static deslogar() async {
    await auth.signOut();
    UserFirebase.logado = false;
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