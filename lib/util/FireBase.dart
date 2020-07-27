import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:applancasalgados/models/usuario.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UtilFirebase {
  static Firestore bd = Firestore.instance;

  static cadastrarDados(
      String colection, String document, Map<String, dynamic> map) {
    if (document != ""){
      UtilFirebase.bd.collection(colection).document(document).setData(map);
    }
    else{
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
}
