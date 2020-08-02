import 'dart:async';
import 'dart:io';

import 'package:applancasalgados/models/CategoriaProduto.dart';
import 'package:applancasalgados/models/Produto.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

import '../RouteGenerator.dart';

class CadastroProdutos extends StatefulWidget {
  @override
  _CadastroProdutosState createState() => _CadastroProdutosState();
}

class _CadastroProdutosState extends State<CadastroProdutos> {
  //Controladores
  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerPreco = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerTempPreparo = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore bd = Firestore.instance;
  String _mensagemErro = "";
  String _categoria, _urlImagemRecuperada;
  var selectedItem;
  File _image;
  final picker = ImagePicker();
  Produto produto = Produto();
  List<CategoriaProduto> options = [];
  int idCategoria;
  bool isCad = true;

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

  Future getImage(bool i) async {
    final pickedFile = await picker.getImage(
        source: i ? ImageSource.camera : ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      if (_image != null) _uploadImagem();
    });
  }

  Future _uploadImagem() {
    FirebaseStorage storage = FirebaseStorage.instance;

    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("produtos")
        .child(Timestamp.now().toString().replaceAll(" ", "") + ".jpg");
    arquivo.putFile(_image);
    StorageUploadTask task = arquivo.putFile(_image);

    task.events.listen((event) {
      if (task.isInProgress) {
        print("progresso");
        setState(() {
        });
      } else if (task.isSuccessful) {
        print("Sucesso");
        setState(() {
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) async {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFirestore(String url) {
    bd.collection("produtos").document(_categoria).updateData({"urlImg": url});
  }

  _obterIndice() async {
    if (true) {
      Map<String, dynamic> id =
          await UtilFirebase.recuperarUmObjeto("indices", "produtos");
      setState(() {
        produto.idProduto = id["id"];
      });
    }
  }

  _salvar() {
    _cadastrarProduto();
    Navigator.pop(context);
  }

  _cadastrarProduto() async {
    int indice = int.parse(produto.idProduto)+1;
    if(isCad){
      UtilFirebase.cadastrarDados("produtos", produto.idProduto, produto.toJson());
      UtilFirebase.alterarDados("indices", "produtos", {"id": indice.toString()});
      isCad = false;
    }
    else {
      UtilFirebase.alterarDados("produtos", produto.idCategoria, produto.toJson());
    }
  }

  validarCampos() {
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
    double preco = double.parse(Util.moeda(double.parse(_controllerPreco.text)));
    String temp = _controllerTempPreparo.text;


    if (titulo.length >= 3) {

      if (_urlImagemRecuperada.isNotEmpty) {

        if (preco >= 0) {

          if (selectedItem != null) {

            produto.titulo = titulo;
            produto.descricao = descricao;
            produto.preco = preco;
            produto.tempoPreparo = temp;
            produto.idCategoria = selectedItem;
            produto.urlImg = _urlImagemRecuperada;

            _salvar();
          } else {
            _mensagemErro = " Já existe uma Categoria com este titulo!";
          }
        } else {
          _mensagemErro = " Uma imagem deve ser selecionada!";
        }
      } else {
        _mensagemErro = " Já existe uma Categoria com este titulo!";
      }
    } else {
      setState(() {
        _mensagemErro = " Preencha o Titulo da Categoria do Produto !";
      });
    }
    _controllerTitulo.clear();
    _controllerDescricao.clear();
    _controllerPreco.clear();
    _controllerTempPreparo.clear();
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = bd
        .collection("categoria")
        .orderBy("idCategoria", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _verificarUsuarioLogado() {
    if (UserFirebase.fireLogged.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _obterIndice();
    super.initState();
    _verificarUsuarioLogado();
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
            const Text("Loading.....");
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
                        style: TextStyle(color: Color(0xffd19c3c)),
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    setState(() {
                      selectedItem = currencyValue;
                    });
                  },
                  value: selectedItem,
                  isExpanded: true,
                  hint: new Text(
                    "Selecione uma Categoria!",
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
        title: Text("Cadastro Produtos"),
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
                  _urlImagemRecuperada != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            _urlImagemRecuperada,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : LinearProgressIndicator(
                                      backgroundColor: Colors.grey,
                                    );
                            },
                            fit: BoxFit.cover,
                          ),
                        )
                      : CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.grey,
                        ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () {
                            _recuperarImagem("camera");
                          },
                          child: Text("Câmera")),
                      FlatButton(
                          onPressed: () {
                            _recuperarImagem("galeria");
                          },
                          child: Text("Galeria")),
                    ],
                  ),

                  //categoria
                  streamCategoria,

                  //titulo produto
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

                  //preco
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerPreco,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Preço",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //Tempo Medio de Preparo
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerTempPreparo,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Tempo Médio de Preparo(min)",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //Descricao
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerDescricao,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Descrição",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //botao
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
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
