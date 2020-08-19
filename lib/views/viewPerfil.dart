import 'dart:io';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
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
  final List<String> formatosAceitos = ["jpg", "jpeg", "Jpeg", "png", "gif"];

  String document = AppModel.to.bloc<UserBloc>().usuario.uidUser;
  bool _upload = false;
  String _imgPerfil = AppModel.to.bloc<UserBloc>().usuario.urlPerfil;

  Future getImage(bool i) async {
    final pickedFile = await picker.getImage(
        source: i ? ImageSource.camera : ImageSource.gallery);

    File _image = File(pickedFile.path);
    String rs = _image.path.substring(
        (_image.path.length - 3), _image.path.length);

    if (!formatosAceitos.contains(rs)) {
      _image = null;
      alert("Atenção",
          "Formato da imagem não aceito, tente formatos como: .jpg, .jpeg, .png ou .gif!",
          Colors.red, Colors.lightBlue);
    }

    if (_image != null) {
      setState(() {
        _upload = true;
      });
      _imgPerfil = await ImageService.insertImage(
          File(pickedFile.path), "perfil", blocUsuarioLogado.usuario.uidUser);
    }

    setState(() {
      _upload = false;
      _imgPerfil;
    });
//    alert("Atenção", "Selecione outra imagem e tente novamente!", Colors.red,Colors.lightBlue);
  }

  Future<void> _atualizarDadosFirestore() async {
    Map<String, dynamic> json = Map<String, dynamic>();

    json["nome"] = _controllerNome.text;
    json["foneContato1"] =
        UtilService.formatSimpleNumber(_controllerNumber.text);
    json["endereco"] = _controllerEndereco.text;
    json["urlPerfil"] = _imgPerfil;

    ImageService.deleteImage(blocUsuarioLogado.usuario.urlPerfil);
    BdService.updateDocumentInColection("usuarios", document, json);
    UserService.recuperaDadosUsuarioLogado();

    alert("Lança Salgados", "Suas informações foram salvas com Sucesso!",
        Theme.of(context)
        .accentColor, Theme
        .of(context)
        .primaryColor);
    return;
  }

  _recuperaDadosUsuario() async {
    if (!blocUsuarioLogado.isLogged) {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    }

    setState(() {
      _controllerNome.text = blocUsuarioLogado.usuario.nome;
      _controllerNumber.text = UtilService.formatarNumberFone(
          blocUsuarioLogado.usuario.foneContato1);
      _controllerEndereco.text = blocUsuarioLogado.usuario.endereco;
    });
  }

  alert(String titulo, String msg, Color colorHead, Color colorBody) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorHead
              ),),
            content: Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: colorBody
                )),
          );
        });
  }

  verificaUrl(String url) {
    try {
      NetworkImage(url);
    }
    catch (e) {
      print("Um Erro aqui " + e.toString());
      return null;
    }
    return NetworkImage(url);
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
                    backgroundImage: verificaUrl(_imgPerfil),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.camera_alt),
                      FlatButton(
                          onPressed: () => getImage(true),
                          child: Text("Câmera")),
                      Icon(Icons.photo_library),
                      FlatButton(
                          onPressed: () => getImage(false),
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
                      keyboardType: TextInputType.number,
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
