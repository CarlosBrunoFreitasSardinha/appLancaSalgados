import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/models/CategoriaProduto.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class CadastroCategoriaProdutos extends StatefulWidget {
  @override
  _CadastroCategoriaProdutosState createState() =>
      _CadastroCategoriaProdutosState();
}

class _CadastroCategoriaProdutosState extends State<CadastroCategoriaProdutos> {
  //Controladores
  TextEditingController _controllerTitulo = TextEditingController();
  Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _mensagemErro = "", colection = "categoria";
  List<CategoriaProduto> options = [];
  int id;
  var selectedItem;


  _obterIndice() async {
    Map<String, dynamic> json =
    await UtilFirebase.recuperarUmObjeto("indices", colection);
    setState(() {
      id = int.parse(json["id"]);
    });
  }

  validarCampos() {
    String titulo = _controllerTitulo.text;
    if (titulo.length >= 3) {
      bool isRepeat = false;
      options.forEach((result) {
        if (result.descricao.contains(titulo)) {
          isRepeat = true;
        }
      });
      if (!isRepeat) {
        _salvar();
      } else {
        _mensagemErro = " Já existe uma Categoria com este titulo!";
      }
    } else {
      setState(() {
        _mensagemErro = " Preencha o Titulo da Categoria do Produto !";
      });
    }
    selectedItem = null;
    _controllerTitulo.clear();
  }

  _salvar() {
    if (selectedItem == null)
      _cadastrarCategoria();
    else {
      options.forEach((element) {
        if (element.descricao == selectedItem) {
          selectedItem = null;
          _alterarCategoria(element.idCategoria.toString());
        }
      });
    }
    setState(() {
      _mensagemErro = "";
    });
  }

  _cadastrarCategoria() async {
    UtilFirebase.cadastrarDados(colection, id.toString(),
        {
          "idCategoria": id.toString(),
          "descricao": _controllerTitulo.text
        });
    UtilFirebase.alterarDados(
        "indices", colection, {"id": (id + 1).toString()});
  }

  _alterarCategoria(String ident) {
    UtilFirebase.alterarDados(
        colection, ident, {"descricao": _controllerTitulo.text});
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = bd
        .collection(colection)
        .orderBy("idCategoria", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _verificarUsuarioLogado() {
    UserFirebase.recuperaDadosUsuario();
    if (!UserFirebase.fireLogged.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
    _obterIndice();
    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {

    var streamCategoria = StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            const Text("Carregando.....");
          else {
            List<DropdownMenuItem> currencyItems = [];
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot snap = snapshot.data.documents[i];
              options.add(CategoriaProduto.fromJson({
                'idCategoria': snap.data["idCategoria"],
                'descricao': snap.data["descricao"]
              }));

              currencyItems.add(
                DropdownMenuItem(
                  child: Text(
                    snap.data["descricao"],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffd19c3c)),
                  ),
                  value: "${snap.data["descricao"]}",
                ),
              );
            }
            return Container(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: DropdownButton(
                  items: currencyItems,
                  onChanged: (currencyValue) {
                    final snackBar = SnackBar(
                      content: Text(
                        'Categoria $currencyValue, foi selecionada!',
                        style:
                        TextStyle(color: Color(0xffd19c3c)),
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    setState(() {
                      selectedItem = currencyValue;
                      _controllerTitulo.text = currencyValue;
                    });
                  },
                  value: selectedItem,
                  isExpanded: true,
                  hint: new Text(
                    "Nova Categoria!",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffd19c3c)),
                  ),
                ),
              ),
            );
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Categoria"),
      ),
      body: Container(
          decoration: BoxDecoration(color: Color(0xff5c3838)),
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

                  streamCategoria,

                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerTitulo,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Titulo",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //botao Cadastrar Atualizar
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                        child: Text(
                          "Cadastrar/Atualizar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          validarCampos();
                        }),
                  ),

                  //msg error
                  Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
