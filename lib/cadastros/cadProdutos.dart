import 'dart:async';
import 'dart:io';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CategoriaProdutoModel.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/ImageService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final blocUsuarioLogado = AppModel.to.bloc<UserBloc>();
  final picker = ImagePicker();

  var selectedItem;

  ProdutoModel produto;

  List<CategoriaProdutoModel> options = [];
  List<bool> imagensUlpoding = [false, false, false];

  String _mensagemErro = "";
  String _urlImagemRecuperada = "";

  bool isCad;
  bool isImgPrincipal = false;
  bool salvado = false;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        isImgPrincipal = true;
      });
      String url = await ImageService.insertImage(File(pickedFile.path),
          "produtos", Timestamp.now().toString().replaceAll(" ", ""));
      setState(() {
        _urlImagemRecuperada = url;
        isImgPrincipal = false;
      });
    }
  }

  Future _onAddImageGaleriaClick(int index) async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    File imageFile = File(pickedFile.path);
    if (pickedFile != null) {
      setState(() {
        imagensUlpoding[index] = true;
      });
      getFileImageGaleria(index, imageFile);
      if (!isCad)
        BdService.alterarDados("produtos", produto.idProduto,
            {"galeria": UtilService.coverterListStringInMap(produto.galeria)});
    }
  }

  void getFileImageGaleria(int index, File file) async {
    String url = await ImageService.insertImage(File(file.path), "produtos",
        Timestamp.now().toString().replaceAll(" ", ""));
    setState(() {
      produto.galeria[index] = url;
      imagensUlpoding[index] = false;
    });
    if (!isCad)
      BdService.alterarDados("produtos", produto.idProduto, {"urlImg": url});
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: List.generate(produto.galeria.length, (index) {
        if (produto.galeria[index].isNotEmpty) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    produto.galeria[index],
                    height: 250,
                    width: 250,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context).accentColor,
                              ),
                            );
                    },
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        ImageService.deleteImage(produto.galeria[index]);
                        produto.galeria[index] = "";
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: !imagensUlpoding[index]
                ? IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _onAddImageGaleriaClick(index),
                  )
                : Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    ),
                  ),
          );
        }
      }),
    );
  }

  _informacoesDoProduto() async {
    isCad = widget.produtoModel == null;
    if (isCad) {
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
    salvado = true;
    Navigator.pop(context);
  }

  _cadastrarProduto() async {
    int indice = int.parse(produto.idProduto) + 1;
    if (isCad) {
      BdService.cadastrarDados("produtos", produto.idProduto, produto.toJson());
      BdService.alterarDados("indices", "produtos", {"id": indice.toString()});
    } else {
      BdService.alterarDados("produtos", produto.idProduto, produto.toJson());
    }
  }

  validarCampos() {
    double preco = double.parse(_controllerPreco.text);
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
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

  Stream<QuerySnapshot> _adicionarListenerCategoria() {
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
    if (!blocUsuarioLogado.usuario.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _informacoesDoProduto();
    _verificarUsuarioLogado();
    _adicionarListenerCategoria();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
    if (!salvado) {
      produto.galeria.forEach((element) {
        ImageService.deleteImage(element);
      });
      ImageService.deleteImage(produto.urlImg);
    }
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
                      });
                    },
                    value: selectedItem,
                    isExpanded: true,
                    hint: Text(
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: _urlImagemRecuperada != ""
                        ? Card(
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              _urlImagemRecuperada,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : Center(
                                  child: LinearProgressIndicator(),
                                );
                              },
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: InkWell(
                              child: Icon(
                                Icons.remove_circle,
                                size: 20,
                                color: Colors.red,
                              ),
                              onTap: () {
                                ImageService.deleteImage(produto.urlImg);
                                setState(() {
                                  produto.urlImg = "";
                                  _urlImagemRecuperada = "";
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                        : Card(
                      child: !isImgPrincipal
                          ? SizedBox(
                        height: 250,
                        width: 250,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => getImage(),
                        ),
                      )
                          : SizedBox(
                        height: 250,
                        width: 250,
                        child: Center(
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //Galeria de Imagens
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: buildGridView(),
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
                              side: BorderSide(
                                  color: Theme
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
                              produto.isOcult
                                  ? Icon(Icons.visibility_off,
                                  color: Colors.white)
                                  : Icon(Icons.visibility, color: Colors.white),
                            ],
                          )),
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: Theme
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
                              produto.isPromo
                                  ? Icon(Icons.star, color: Colors.white)
                                  : Icon(Icons.star_border,
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
