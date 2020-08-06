import 'dart:io';

import 'package:applancasalgados/bloc/UserFireBaseBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../RouteGenerator.dart';

class ViewPerfil extends StatefulWidget {
  @override
  _ViewPerfilState createState() => _ViewPerfilState();
}

class _ViewPerfilState extends State<ViewPerfil> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerNumber = TextEditingController();
  TextEditingController _controllerEndereco = TextEditingController();
  String imagem = "";
  String colection = "usuario";
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
        .child(AppModel.to.bloc<UserFirebase>().usuario.uidUser + ".jpg");
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
      AppModel.to
          .bloc<UserFirebase>()
          .usuario
          .urlPerfil = url;
    });
    _atualizarUrlImagemFirestore(url);
  }

  Future _atualizarUrlImagemFirestore(String url){
    Map<String, dynamic> json;
    json["urlPerfil"] = url;
    BdService.alterarDados(
        colection, AppModel.to.bloc<UserFirebase>()
        .usuario
        .uidUser, json);
  }

  Future _atualizarDadosFirestore() {
    Map<String, dynamic> json;
    json["nome"] = _controllerNome.text;
    json["foneContato1"] = _controllerNumber.text;
    json["endereco"] = _controllerEndereco.text;
    BdService.alterarDados(
        colection, AppModel.to.bloc<UserFirebase>().usuario.uidUser, json);
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
    _verificarUsuarioLogado();

    setState(() {
      _controllerNome.text = AppModel.to
          .bloc<UserFirebase>()
          .usuario
          .nome;
      _controllerNumber.text = AppModel.to
          .bloc<UserFirebase>()
          .usuario
          .foneContato1;
      _controllerEndereco.text = AppModel.to
          .bloc<UserFirebase>()
          .usuario
          .endereco;
    });
  }

  _verificarUsuarioLogado() {
    if (!AppModel.to
        .bloc<AppBloc>()
        .isLogged) {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    }
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
                    backgroundImage: AppModel.to
                        .bloc<UserFirebase>()
                        .usuario
                        .urlPerfil != null
                        ? NetworkImage(AppModel.to
                        .bloc<UserFirebase>()
                        .usuario
                        .urlPerfil)
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.camera_alt),
                      FlatButton(onPressed: (){
                        _recuperarImagem("camera");
                      },
                          child: Text("Câmera")),

                      Icon(Icons.photo_library),
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
                              borderRadius: BorderRadius.circular(10))),
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
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //endereco
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerEndereco,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Endereço Ex(Bairro tal, Rua tal, Número tal)",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //botao salvar
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
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          _atualizarDadosFirestore();
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
