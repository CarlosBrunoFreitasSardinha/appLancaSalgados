import 'dart:io';

import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<Stream<List<UsuarioModel>>> getImages() async {
    var ref = Firestore.instance.collection('users');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => UsuarioModel.fromJson(doc.data)).toList());
  }

  static Future<String> insertImage(
      File img, String subPasta, String nomeArquivo) async {
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child(subPasta)
        .child(nomeArquivo.replaceAll(" ", "") + ".jpg");
    arquivo.putFile(img);
    StorageUploadTask task = arquivo.putFile(img);
    String url = "";

    await task.onComplete;
    print("Envio Completo");
    url = await arquivo.getDownloadURL();
    print("Url registrada: $url");

    return url;
  }

  static Future<String> updateImage(
      String url, File img, String subPasta, String nomeArquivo) async {
    ImageService.deleteImage(url);
    return await ImageService.insertImage(img, subPasta, nomeArquivo);
  }

  static Future<void> deleteImage(String url) async {
    StorageReference pastaRaiz = await storage.getReferenceFromUrl(url);
    pastaRaiz.delete();
    return;
  }
}
