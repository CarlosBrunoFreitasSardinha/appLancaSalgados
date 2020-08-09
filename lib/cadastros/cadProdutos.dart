import 'dart:async';
import 'dart:io';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CategoriaProdutoModel.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

import '../RouteGenerator.dart';

class CadastroProdutos extends StatefulWidget {
  final ProdutoModel produtoModel;

  CadastroProdutos(this.produtoModel);

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
  String _mensagemErro = "";
  String _categoria, _urlImagemRecuperada;
  var selectedItem;
  File _image;
  final picker = ImagePicker();
  ProdutoModel produto;
  List<CategoriaProdutoModel> options = [];
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

  Future _uploadImagem() async {
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
        setState(() {});
      } else if (task.isSuccessful) {
        print("Sucesso");
        setState(() {});
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
    BdService.alterarDados("produtos", _categoria, {"urlImg": url});
  }

  _obterIndice() async {
    if (widget.produtoModel == null) {
      produto = ProdutoModel();
      Map<String, dynamic> id =
          await BdService.recuperarUmObjeto("indices", "produtos");
      setState(() {
        produto.idProduto = id["id"];
      });
    } else {
      produto = widget.produtoModel;
      _controllerTitulo.text = produto.titulo;
      _controllerPreco.text = produto.preco.toString();
      _controllerDescricao.text = produto.descricao;
      _controllerTempPreparo.text = produto.tempoPreparo;
      selectedItem = produto.idCategoria;
      _urlImagemRecuperada = produto.urlImg;
    }
  }

  _salvar() {
    _cadastrarProduto();
    Navigator.pop(context);
  }

  _cadastrarProduto() async {
    int indice = int.parse(produto.idProduto) + 1;
    if (widget.produtoModel == null) {
      BdService.cadastrarDados("produtos", produto.idProduto, produto.toJson());
      BdService.alterarDados("indices", "produtos", {"id": indice.toString()});
      isCad = false;
    } else {
      BdService.alterarDados("produtos", produto.idProduto, produto.toJson());
    }
  }

  validarCampos() {
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
    double preco = double.parse(_controllerPreco.text);
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
    Firestore bd = Firestore.instance;
    final stream = bd
        .collection("categoria")
        .orderBy("idCategoria", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _verificarUsuarioLogado() {
    if (!AppModel.to
        .bloc<UserBloc>()
        .usuario
        .isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
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
            Text("Carregando...");
          else {
            List<DropdownMenuItem> currencyItems = [];
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot snap = snapshot.data.documents[i];
              options.add(CategoriaProdutoModel.fromJson({
                'idCategoria': snap.data["idCategoria"],
                'descricao': snap.data["descricao"]
              })
              );

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
            return Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 4, 8, 4),
                  child: DropdownButton(
                    underline: SizedBox(),
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
            );
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Produtos"),
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
                  _urlImagemRecuperada != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      _urlImagemRecuperada,
                            height: 300,
                            width: 300,
                            loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                        );
                      },
                      fit: BoxFit.contain,
                    ),
                  )
                      : CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Theme
                                  .of(context)
                                  .accentColor)),
                          color: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () {
                            _recuperarImagem("camera");
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.camera_alt, color: Colors.white),
                              Text("Câmera",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20))
                            ],
                          )),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Theme
                                  .of(context)
                                  .accentColor)),
                          color: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () {
                            _recuperarImagem("galeria");
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                              Text("Galeria",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20))
                            ],
                          )),
                    ],
                  ),

                  //categoria
                  streamCategoria,

                  //titulo produto
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: TextField(
                      controller: _controllerTitulo,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.title,
                              )),
                          hintText: "Titulo do Produto",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //preco
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: TextField(
                      controller: _controllerPreco,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.attach_money,
                              )),
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
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: TextField(
                      controller: _controllerTempPreparo,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.timer,
                              )),
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Tempo Preparo (min)",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //Descricao
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: TextField(
                      controller: _controllerDescricao,
                      maxLines: 3,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.description,
                              )),
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Descrição",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Theme
                                  .of(context)
                                  .accentColor)),
                          color: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () {
                            setState(() {
                              produto.isOcult = !produto.isOcult;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Text("Visibilidade: ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              produto.isOcult ? Icon(Icons.visibility_off,
                                  color: Colors.white) : Icon(Icons.visibility,
                                  color: Colors.white),
                            ],
                          )),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Theme
                                  .of(context)
                                  .accentColor)),
                          color: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () {
                            setState(() {
                              produto.isPromo = !produto.isPromo;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Text("Destaque: ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              produto.isPromo ? Icon(Icons.star, color: Colors
                                  .white) : Icon(Icons.star_border,
                                  color: Colors.white),
                            ],
                          )),
                    ],
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
