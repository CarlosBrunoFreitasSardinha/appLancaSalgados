import 'dart:io';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/ImageService.dart';
import 'package:applancasalgados/services/NumberFormatService.dart';
import 'package:applancasalgados/services/UserService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final picker = ImagePicker();
  final blocUsuarioLogado = AppModel.to.bloc<UserBloc>();
  final _mobileFormatter = NumberTextInputFormatterService();

  String document = AppModel.to.bloc<UserBloc>().usuario.uidUser;
  bool _upload = false;

  Future getImage(bool i) async {
    final pickedFile = await picker.getImage(
        source: i ? ImageSource.camera : ImageSource.gallery);

    File _image;
    _image = File(pickedFile.path);

    setState(() {
      _upload = true;
    });

    if (_image != null) {
      String urlImagemRecuperada;
      urlImagemRecuperada = await ImageService.insertImage(
          File(pickedFile.path), "perfil", blocUsuarioLogado.usuario.uidUser);
      _atualizarUrlImagemFirestore(urlImagemRecuperada);
    }
  }

  Future _atualizarUrlImagemFirestore(String url) async {
    Map<String, dynamic> json = Map<String, dynamic>();

    json["urlPerfil"] = url != null ? url : "";

    ImageService.deleteImage(blocUsuarioLogado.usuario.urlPerfil);
    BdService.alterarDados("usuarios", document, json);

    setState(() {
      blocUsuarioLogado.usuario.urlPerfil = url;
      _upload = false;
    });
  }

  Future<void> _atualizarDadosFirestore() async {
    Map<String, dynamic> json = Map<String, dynamic>();

    json["nome"] = _controllerNome.text;
    json["foneContato1"] =
        UtilService.formatSimpleNumber(_controllerNumber.text);
    json["endereco"] = _controllerEndereco.text;
    json["urlPerfil"] = blocUsuarioLogado.usuario.urlPerfil;

    BdService.alterarDados("usuarios", document, json);
    UserService.recuperaDadosUsuarioLogado();

    return;
  }

  Future _recuperarImagem(String urlImg) async {
    switch (urlImg) {
      case "camera":
        getImage(true);
        break;
      case "galeria":
        getImage(false);
        break;
    }
  }

  _recuperaDadosUsuario() async {
    _verificarUsuarioLogado();

    setState(() {
      _controllerNome.text = blocUsuarioLogado.usuario.nome;
      _controllerNumber.text = UtilService.formatarNumberFone(
          blocUsuarioLogado.usuario.foneContato1);
      _controllerEndereco.text = blocUsuarioLogado.usuario.endereco;
    });
  }

  _verificarUsuarioLogado() {
    if (!blocUsuarioLogado.isLogged) {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
      ),
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
                    backgroundImage: blocUsuarioLogado.usuario.urlPerfil !=
                        null
                        ? NetworkImage(blocUsuarioLogado.usuario.urlPerfil)
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.camera_alt),
                      FlatButton(
                          onPressed: () {
                        _recuperarImagem("camera");
                      },
                          child: Text("Câmera")),
                      Icon(Icons.photo_library),
                      FlatButton(
                          onPressed: () {
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
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.person_outline,
                              )),
                          hintText: "Nome",
                          labelText: "Nome",
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
                      maxLength: 15,
                      style: TextStyle(fontSize: 20),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        _mobileFormatter,
                      ],
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.phone,
                              )),
                          hintText: "Telefone(Whatsapp)",
                          labelText: "Telefone(Whatsapp)",
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
                      maxLines: 3,
                      maxLength: 60,
                      keyboardType: TextInputType.multiline,
                      controller: _controllerEndereco,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.home,
                              )),
                          hintText: "Endereço Ex(Bairro tal, Rua tal, Número tal)",
                          labelText: "Endereço",
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
              )),
        ),
      ),
    );
  }
}
