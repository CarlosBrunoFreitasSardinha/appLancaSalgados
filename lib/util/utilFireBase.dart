import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class UtilFirebase {
  static Firestore bd = Firestore.instance;

  static cadastrarDados(String colection, String document, Map<String, dynamic> map) {
    if (document != "") {
      UtilFirebase.bd.collection(colection).document(document).setData(map);
    } else {
      UtilFirebase.bd.collection(colection).add(map);
    }
  }

  static alterarDados(String colection, String document, Map<String, dynamic> map) {
    UtilFirebase.bd.collection(colection).document(document).updateData(map);
  }

  static removerDados(String colection, String document) {
    UtilFirebase.bd.collection(colection).document(document).delete();
  }

  static Future<Map<String, dynamic>> recuperarUmObjeto(String colection, String document) async {
    DocumentSnapshot snapshot =
        await UtilFirebase.bd.collection(colection).document(document).get();
    var dados = snapshot.data;
    return dados;
  }

  static removerItemColecaoGenerica(String colecaoPai, String documentPai,
      String subColection, String subDocument) {
      UtilFirebase.bd
          .collection(colecaoPai)
          .document(documentPai)
          .collection(subColection)
          .document(subDocument)
          .delete();
  }

  static alterarItemColecaoGenerica(String coletionPai, String documentPai,
      String subColection, String subDocument, Map<String, dynamic> json) {
    UtilFirebase.bd
        .collection(coletionPai)
          .document(documentPai)
          .collection(subColection)
          .document(subDocument)
          .updateData(json);
  }

  static Future<void> criarItemComIdColecaoGenerica(String coletionPai, String documentPai,
      String subColection, String subDocument, Map<String, dynamic> json) async {
    await UtilFirebase.bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .document(subDocument)
        .setData(json);
  }

  static criarItemAutoIdColecaoGenerica(String coletionPai, String documentPai,
      String subColection, Map<String, dynamic> json) {
    UtilFirebase.bd
          .collection(coletionPai)
          .document(documentPai)
          .collection(subColection)
          .add(json);
  }

  static Future<DocumentSnapshot> recuperarItemsColecaoGenerica(String coletionPai, String documentPai,
      String subColection, String subDocument) async {
    DocumentSnapshot snapshot =
    await UtilFirebase.bd
          .collection(coletionPai)
          .document(documentPai)
          .collection(subColection)
          .document(subDocument)
          .get();
    return snapshot;
  }

}
