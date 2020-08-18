import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class BdService {
  static Firestore bd = Firestore.instance;

  static insertDocumentInColection(
      String colection, String document, Map<String, dynamic> map) {
    if (document != "") {
      BdService.bd.collection(colection).document(document).setData(map);
    } else {
      BdService.bd.collection(colection).add(map);
    }
  }

  static Future<void> updateDocumentInColection(
      String colection, String document, Map<String, dynamic> map) async {
    BdService.bd.collection(colection).document(document).updateData(map);
    return;
  }

  static removeDocumentInColection(String colection, String document) {
    BdService.bd.collection(colection).document(document).delete();
  }

  static Future<Map<String, dynamic>> getDocumentInColection(
      String colection, String document) async {
    DocumentSnapshot snapshot =
        await BdService.bd.collection(colection).document(document).get();
    var dados = snapshot.data;
    return dados;
  }

  static removeDocumentInSubColection(String colecaoPai, String documentPai,
      String subColection, String subDocument) {
    BdService.bd
        .collection(colecaoPai)
        .document(documentPai)
        .collection(subColection)
        .document(subDocument)
        .delete();
  }

  static updateDocumentInSubColection(String coletionPai, String documentPai,
      String subColection, String subDocument, Map<String, dynamic> json) {
    BdService.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .document(subDocument)
        .updateData(json);
  }

  static Future<void> insertWithIdDocumentInSubColection(String coletionPai,
      String documentPai, String subColection,
      String subDocument, Map<String, dynamic> json) async {
    await BdService.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .document(subDocument)
        .setData(json);
  }

  static insertAutoIdDocumentInSubColection(String coletionPai,
      String documentPai,
      String subColection, Map<String, dynamic> json) {
    BdService.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .add(json);
  }

  static Future<DocumentSnapshot> getDocumentInSubColection(
      String coletionPai,
      String documentPai,
      String subColection,
      String subDocument) async {
    DocumentSnapshot snapshot = await BdService.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .document(subDocument)
        .get();
    return snapshot;
  }

  static Future<Map<String, dynamic>> getMapDocumentInSubColection(
      String coletionPai,
      String documentPai,
      String subColection,
      String subDocument) async {
    DocumentSnapshot snapshot = await BdService.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .document(subDocument)
        .get();
    var dados = snapshot.data;
    return dados;
  }

  static Future<QuerySnapshot> getSubColection(
      String coletionPai,
      String documentPai,
      String subColection) async {
    QuerySnapshot querySnapshot = await BdService.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .getDocuments();

    return querySnapshot;
  }
}
