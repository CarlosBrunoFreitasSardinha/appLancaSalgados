import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/models/FormaPagamentoModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastroFormaPagamento extends StatefulWidget {
  @override
  _CadastroFormaPagamentoState createState() => _CadastroFormaPagamentoState();
}

class _CadastroFormaPagamentoState extends State<CadastroFormaPagamento> {
  //Controladores
  TextEditingController _controllerTitulo = TextEditingController();
  Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String colection = "formaPagamento";
  List<FormaPagamentoModel> options = [];
  int id;
  var selectedItem;

  _obterIndice() async {
    Map<String, dynamic> json =
        await BdService.getDocumentInColection("indices", colection);
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
        alert("Atenção", "Já existe uma Forma de Pagamento com este titulo!",
            Colors.red, Colors.black87);
      }
    } else {
      alert("Atenção",
          "Preencha o Titulo da Forma de Pagamento!",
          Colors.red,
          Colors.black87);
    }
    selectedItem = null;
    _controllerTitulo.clear();
  }

  _salvar() {
    if (selectedItem == null)
      _cadastrarFormaPagamento();
    else {
      options.forEach((element) {
        if (element.descricao == selectedItem) {
          _alterarFormaPagamento(element.id.toString());
        }
      });
      limparFormulario();
    }
    alert("Sucesso",
        "Informações salvas com sucesso!",
        Colors.blueAccent,
        Colors.lightBlue);
  }

  _cadastrarFormaPagamento() async {
    BdService.insertDocumentInColection(colection, id.toString(),
        {"id": id, "descricao": _controllerTitulo.text});
    BdService.updateDocumentInColection(
        "indices", colection, {"id": (id + 1).toString()});
  }

  _alterarFormaPagamento(String ident) {
    BdService.updateDocumentInColection(
        colection, ident, {"descricao": _controllerTitulo.text});
  }

  _excluirFormaPagamento() {
    if (selectedItem != null) {
      options.forEach((element) {
        if (element.descricao == selectedItem) {
          selectedItem = null;
          BdService.removeDocumentInColection(colection, element.id.toString());
        }
      });
    }
    limparFormulario();
  }

  limparFormulario() {
    setState(() {
      selectedItem = null;
    });
    _controllerTitulo.clear();
  }

  _adicionarListenerFormaPagamento() {
    final stream =
        bd.collection(colection).orderBy("id", descending: false).snapshots();

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
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
    _obterIndice();
    _adicionarListenerFormaPagamento();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro de Forma de Pagamento"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          // ignore: missing_return
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              const Text("Carregando...");
            else {
              List<DropdownMenuItem> currencyItems = [];
              for (int i = 0;
              i < snapshot.data.documents.length;
              i++) {
                DocumentSnapshot snap = snapshot.data.documents[i];
                options
                    .add(FormaPagamentoModel.fromJson(snap.data));

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
                            padding: EdgeInsets.only(bottom: 32, top: 10),
                            child: Image.asset(
                              "imagens/logo.png",
                              width: 200,
                              height: 150,
                            ),
                          ),

                          //Stream forma de pagamento
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
                                    "Nova Forma de Pagamento!",
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
                            padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
                            child: TextField(
                              controller: _controllerTitulo,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.title),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      32, 16, 32, 16),
                                  hintText: "Titulo",
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
                                padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                onPressed: () => _excluirFormaPagamento()),
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
