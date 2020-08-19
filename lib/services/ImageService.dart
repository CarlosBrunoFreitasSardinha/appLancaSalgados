import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<String> insertImage(
      File img, String subPasta, String nomeArquivo) async {
    String url;

    try {
      nomeArquivo = nomeArquivo;

      StorageReference arquivo =
      storage.ref().child(subPasta).child(nomeArquivo + ".jpg");

      arquivo.putFile(img);
      StorageUploadTask task = arquivo.putFile(img);

      await task.onComplete;
      print("Envio Completo");
      url = await arquivo.getDownloadURL() as String;
    } catch (e) {
      print("Error => " + e.toString());
      return "";
    }

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
