import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CategoriaProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
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
  String colection = "categoria";
  List<CategoriaProdutoModel> options = [];
  int id;
  var selectedItem;


  _obterIndice() async {
    Map<String, dynamic> json =
        await BdService.recuperarUmObjeto("indices", colection);
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
        alert("Atenção", "Já existe uma Categoria com este titulo!", Colors.red,
            Colors.black87);
      }
    } else {
      alert("Atenção",
          "Preencha o Titulo da Categoria do Produto!",
          Colors.red,
          Colors.black87);
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
          _alterarCategoria(element.idCategoria.toString());
        }
      });
      limparFormulario();
    }
    alert("Sucesso",
        "Informações salvas com sucesso!",
        Colors.blueAccent,
        Colors.lightBlue);
  }

  _cadastrarCategoria() async {
    BdService.cadastrarDados(colection, id.toString(),
        {
          "idCategoria": id.toString(),
          "descricao": _controllerTitulo.text
        });
    BdService.alterarDados(
        "indices", colection, {"id": (id + 1).toString()});
  }

  _alterarCategoria(String ident) {
    BdService.alterarDados(
        colection, ident, {"descricao": _controllerTitulo.text});
  }

  limparFormulario() {
    setState(() {
      selectedItem = null;
    });
    _controllerTitulo.clear();
  }

  _excluirCategoria() {
    if (selectedItem != null) {
      options.forEach((element) {
        if (element.descricao == selectedItem) {
          selectedItem = null;
          BdService.removerDados(colection, element.idCategoria.toString());
        }
      });
      limparFormulario();
    }
  }

  _adicionarListenerConversas() {
    final stream = bd
        .collection(colection)
        .orderBy("idCategoria", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _verificarUsuarioLogado() {
    if (!AppModel.to.bloc<UserBloc>().usuario.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }
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

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _obterIndice();
    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Categoria"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          // ignore: missing_return
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              const Text("Carregando.....");
            else {
              List<DropdownMenuItem> currencyItems = [];
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                DocumentSnapshot snap = snapshot.data.documents[i];
                options.add(CategoriaProdutoModel.fromJson({
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

                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(24, 4, 8, 4),
                                child: DropdownButton(
                                  underline: SizedBox(),
                                  items: currencyItems,
                                  onChanged: (currencyValue) {
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
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: TextField(
                              controller: _controllerTitulo,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  hintText: "Titulo",
                                  prefixIcon: Icon(Icons.title),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),

                          //botao Cadastrar Atualizar
                          Padding(
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
                                  validarCampos();
                                }),
                          ),

                          //botao Excluir
                          selectedItem != null
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
                                      padding:
                                          EdgeInsets.fromLTRB(32, 16, 32, 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () => _excluirCategoria()),
                                )
                              : SizedBox(),

                          //botao LimparForm
                          Padding(
                            padding: EdgeInsets.only(
                                top: 4, bottom: 10, left: 8, right: 8),
                            child: RaisedButton(
                                child: Text(
                                  "Limpar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                color: Color(0xffd19c3c),
                                padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                onPressed: () => limparFormulario()),
                          )
                        ],
                      ),
                    ),
                  ));
            }
          }),
    );
  }
}
