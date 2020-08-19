import 'dart:async';
import 'dart:io';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/models/CategoriaProdutoModel.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
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

  final blocUsuarioLogado = AppModel.to.bloc<UserBloc>();
  final picker = ImagePicker();

  var selectedItem;

  ProdutoModel produto;

  List<DropdownMenuItem> currencyItems = [];
  List<CategoriaProdutoModel> options = [];
  List<bool> imagensUlpoding = [false, false, false];

  String _urlImagemRecuperada = "";

  bool isCad = true;
  bool isImgPrincipal = false;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    File image = File(pickedFile.path);
    if (image != null) {
      setState(() {
        isImgPrincipal = true;
      });
      String url = await ImageService.insertImage(
          File(pickedFile.path),
          "produtos",
          Timestamp.now()
              .toString()
              .replaceAll(" ", "")
              .replaceAll("Timestamp(", "")
              .replaceAll(")", ""));
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
        BdService.updateDocumentInColection("produtos", produto.idProduto,
            {"galeria": UtilService.coverterListStringInMap(produto.galeria)});
    }
  }

  void getFileImageGaleria(int index, File file) async {
    String url = await ImageService.insertImage(File(file.path), "produtos",
        Timestamp.now().toString()
            .replaceAll(" ", "")
            .replaceAll("Timestamp(", "")
            .replaceAll(")", ""));

    setState(() {
      produto.galeria[index] = url;
      imagensUlpoding[index] = false;
    });
    if (!isCad)
      BdService.updateDocumentInColection(
          "produtos", produto.idProduto, {"urlImg": url});
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

  _informacoesDoProduto() async {
    isCad = widget.produtoModel == null;
    print("Is Cad " + isCad.toString());
    if (isCad) {
      produto = ProdutoModel();
      Map<String, dynamic> id =
          await BdService.getDocumentInColection("indices", "produtos");
        produto.idProduto = id["id"];
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
    if (isCad) {
      BdService.insertDocumentInColection(
          "produtos", produto.idProduto, produto.toJson());
      BdService.updateDocumentInColection(
          "indices", "produtos", {"id": indice.toString()});
    } else {
      BdService.updateDocumentInColection(
          "produtos", produto.idProduto, produto.toJson());
    }
  }

  validarCampos() {
    double preco;
    String titulo = _controllerTitulo.text;
    String descricao = _controllerDescricao.text;
    String temp = _controllerTempPreparo.text;

    try {
      preco = double.parse(_controllerPreco.text.replaceAll(",", "."));
    } catch (e) {
      alert("Atenção", "Preço informado inválido!", Colors.red, Colors.black87);
      return;
    }

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
            alert("Atenção",
                "Selecione uma Categoria para o Produto!",
                Colors.red,
                Colors.black87);
          }
        } else {
          alert("Atenção",
              "Preço Inválido!",
              Colors.red,
              Colors.black87);
        }
      } else {
        alert("Atenção",
            "Cadastre a imagem principal do Produto!",
            Colors.red,
            Colors.black87);
      }
    } else {
      alert("Atenção",
          "O Titulo deve conter mais de 3 caracteres!",
          Colors.red,
          Colors.black87);
    }
    limparForm();
  }

  limparForm() {
    selectedItem = null;
    _controllerTitulo.clear();
    _controllerDescricao.clear();
    _controllerPreco.clear();
    _controllerTempPreparo.clear();
    produto = null;
    produto = ProdutoModel();
  }

  apagarImagens() {
    if (isCad) {
      produto.galeria.forEach((element) {
        ImageService.deleteImage(element);
      });
      ImageService.deleteImage(produto.urlImg);
      setState(() {});
    }
  }

  Future<List<CategoriaProdutoModel>> adicionarListenerFormaPagamento() async {
    Firestore bd = Firestore.instance;
    QuerySnapshot querySnapshot = await bd
        .collection("categoria")
        .orderBy("idCategoria", descending: false)
        .getDocuments();

    for (int i = 0; i < querySnapshot.documents.length; i++) {
      DocumentSnapshot snap = querySnapshot.documents[i];
      options.add(CategoriaProdutoModel.fromJson(snap.data));

      currencyItems.add(
        DropdownMenuItem(
          child: Text(
            snap.data["descricao"],
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffd19c3c)),
          ),
          value: "${snap.data["descricao"]}",
        ),
      );
    }
    setState(() {
      currencyItems;
    });
    return options;
  }

  _verificarUsuarioLogado() {
    if (!blocUsuarioLogado.usuario.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }
  }


  Widget galeriaProdutoUploadItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(produto.galeria.length, (index) {
        if (produto.galeria[index].isNotEmpty) {
          return Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        produto.galeria[index],
                        height: MediaQuery
                            .of(context)
                            .size
                            .width * 0.8 / 3,
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Theme
                                  .of(context)
                                  .accentColor,
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
              ));
        } else {
          return Expanded(
              child: Card(
                child: !imagensUlpoding[index]
                    ? SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8 / 3,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _onAddImageGaleriaClick(index),
                  ),
                )
                    : SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8 / 3,
                  child: Center(child: CircularProgressIndicator(),),
                ),
              ));
        }
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _informacoesDoProduto();
    adicionarListenerFormaPagamento();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  //imgPrincipal
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
                                    height:
                                        MediaQuery.of(context).size.width * 0.5,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : Center(
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child:
                                    CircularProgressIndicator(),
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
                                    height: 200,
                                    width: 200,
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
                    child: galeriaProdutoUploadItems(),
                  ),

                  //categoria
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: DropdownButton(
                            underline: SizedBox(),
                            items: currencyItems,
                            onChanged: (currencyValue) {
                              setState(() {
                                selectedItem = currencyValue;
                              });
                            },
                            value: selectedItem,
                            isExpanded: true,
                            hint: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                "Selecione a Categoria!",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffd19c3c)),
                              ),
                            )),
                      ),
                    ),
                  ),

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
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
                              borderRadius: BorderRadius.circular(5.0),
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

                  //botao Cadastrar/Atualizar
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

                  //botao Limpar
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                        child: Text(
                          "Limpar Formulário",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          limparForm();
                        }),
                  ),

                  //botao DeletarImagens
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                        child: Text(
                          "Deletar Imagens",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          apagarImagens();
                        }),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
