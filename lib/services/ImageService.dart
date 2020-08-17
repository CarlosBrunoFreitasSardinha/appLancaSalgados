import 'dart:io';

import 'package:applancasalgados/models/UsuarioModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  static FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://lancasalgados.appspot.com');

  _() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'LancaSalgados',
      options: FirebaseOptions(
        googleAppID: (Platform.isIOS || Platform.isMacOS)
            ? '1:917627258974:ios:e616af50eaa478127dcccf'
            : '1:917627258974:android:b978d8ce4a24ae457dcccf',
        gcmSenderID: '917627258974',
        apiKey: 'AIzaSyB84I5fB4DKfk8mALml6UMtxld80CrSbi4',
        projectID: 'lancasalgados',
      ),
    );
    storage = FirebaseStorage(
        app: app, storageBucket: 'gs://lancasalgados.appspot.com');
  }

  static Future<String> getImage(String path) async {
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child(path);
    String url = arquivo.getDownloadURL() as String;
    print("URL gerada " + url);
    return url;
  }

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
        .child(
        nomeArquivo
            .replaceAll(" ", "")
            .replaceAll("Timestamp(", "")
            .replaceAll(")", "") + ".jpg"
    );

    arquivo.putFile(img);
    StorageUploadTask task = arquivo.putFile(img);

    await task.onComplete;
    print("Envio Completo");
    String url = await arquivo.getDownloadURL();

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
