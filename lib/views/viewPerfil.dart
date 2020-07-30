import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class viewPerfil extends StatefulWidget {
  @override
  _viewPerfilState createState() => _viewPerfilState();
}

class _viewPerfilState extends State<viewPerfil> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerNumber = TextEditingController();
  String _idUsuarioLogado, _urlImagemRecuperada;
  String imagem = "";
  bool _upload = false;
  File _image;
  final picker = ImagePicker();

  Future getImage(bool i) async {
    final pickedFile = await picker.getImage(source: i ? ImageSource.camera: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      _upload = true;
      if(_image != null) _uploadImagem();
    });
  }

  Future _uploadImagem(){
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("perfil")
        .child(_idUsuarioLogado+".jpg");
    arquivo.putFile(_image);
    StorageUploadTask task = arquivo.putFile(_image);
    task.events.listen((event) {
      if (task.isInProgress){
        print("progresso");
        setState(() {
          _upload = true;
        });
      }
      else if (task.isSuccessful){
        print("Sucesso");
        setState(() {
          _upload = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) async{
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async{
    String url = await snapshot.ref.getDownloadURL();
    setState(() {
      _urlImagemRecuperada = url;
    });
    _atualizarUrlImagemFirestore(url);
  }

  Future _atualizarUrlImagemFirestore(String url){
    Map<String, dynamic> dadosAtualizar ={
      "urlPerfil": url
    };

    Firestore bd = Firestore.instance;
    bd.collection("usuarios")
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);
  }

  Future _atualizarNomeFirestore(){
    Map<String, dynamic> dadosAtualizar ={
      "nome": _controllerNome.text,
      "foneContato1": _controllerNumber.text
    };

    Firestore bd = Firestore.instance;
    bd.collection("usuarios")
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);
  }

  Future _recuperarImagem(String urlImg) async {
    switch(urlImg){
      case "camera":
        getImage(true);
        break;
      case "galeria":
        getImage(false);
        break;
    }
  }

  _recuperaDadosUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore bd = Firestore.instance;
    DocumentSnapshot snapshot = await bd.collection("usuarios")
        .document(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data;
    setState(() {
      _controllerNome.text = dados["nome"];
      _urlImagemRecuperada = dados["urlPerfil"] != null ? dados["urlPerfil"] : null;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaDadosUsuario();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil"),),

      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _upload
                      ? CircularProgressIndicator()
                      : CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada)
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(onPressed: (){
                        _recuperarImagem("camera");
                      },
                          child: Text("Câmera")),
                      FlatButton(onPressed: (){
                        _recuperarImagem("galeria");
                      },
                          child: Text("Galeria")),
                    ],
                  ),

                  //nome
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerNome,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Nome",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),
                  //Contato
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerNumber,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Telefone(Whatsapp)",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                        child: Text(
                          "Salvar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        onPressed: () {
                          _atualizarNomeFirestore();
                        }),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}
