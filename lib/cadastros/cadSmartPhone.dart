import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class CadastroOneSignalSmartPhone extends StatefulWidget {
  @override
  _CadastroOneSignalSmartPhoneState createState() =>
      _CadastroOneSignalSmartPhoneState();
}

class _CadastroOneSignalSmartPhoneState
    extends State<CadastroOneSignalSmartPhone> {
  final blocUser = AppModel.to.bloc<UserBloc>();
  String colection = "oneSignal";
  String id;
  String termo = "Habilitar";

  _obterIndice() async {
    Map<String, dynamic> json = await BdService.getMapDocumentInSubColection(
        "indices", colection, colection, blocUser.usuario.uidUser);
    setState(() {
      id = json["aparelho"];
      termo = UtilService.stringIsNull(id) ? "habilitar" : "desabilitar";
    });
  }

  _cadastrarCategoria() async {
    BdService.insertWithIdDocumentInSubColection(
        "indices",
        colection,
        colection,
        blocUser.usuario.uidUser,
        {"nome": blocUser.usuario.nome, "aparelho": blocUser.playId});
    Navigator.pop(context);
  }

  _excluirCategoria() {
    BdService.removeDocumentInSubColection(
        "indices", colection, colection, blocUser.usuario.uidUser);
    Navigator.pop(context);
  }

  _verificarUsuarioLogado() {
    if (!blocUser.usuario.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }
  }

  alert(String titulo, String msg, Color colorHead, Color colorBody) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: colorHead),
            ),
            content: Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: colorBody)),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _obterIndice();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Categoria"),
      ),
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('imagens/background.jpg'),
                  fit: BoxFit.cover)),
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //logo
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "imagens/logo.png",
                      width: 200,
                      height: 150,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Para $termo a receber notificações dos pedidos confirme a baixo!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 25,
                  ),

                  //botao Excluir
                  UtilService.stringNotIsNull(id)
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: 4, bottom: 10, left: 8, right: 8),
                          child: RaisedButton(
                              child: Text(
                                "Excluir",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              color: Color(0xffd19c3c),
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () => _excluirCategoria()),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              top: 16, bottom: 10, left: 8, right: 8),
                          child: RaisedButton(
                              elevation: 8,
                              child: Text(
                                "Cadastrar/Atualizar",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              color: Color(0xffd19c3c),
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {
                                _cadastrarCategoria();
                              }),
                        ),
                ],
              ),
            ),
          )),
    );
  }
}
