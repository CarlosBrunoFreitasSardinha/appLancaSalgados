import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ViewProduto extends StatefulWidget {
  final ProdutoModel produto;

  ViewProduto(this.produto);

  @override
  _ViewProdutoState createState() => _ViewProdutoState();
}

class _ViewProdutoState extends State<ViewProduto> {
  final streamCarrinho = AppModel.to.bloc<CarrinhoBloc>();
  final streamUsuario = AppModel.to.bloc<UserBloc>();

  ProdutoCarrinhoModel produtoCarrinho = ProdutoCarrinhoModel();

  List<Widget> imageSliders;
  List<String> fullGaleria = [];

  String coletionPai, documentPai, subColection, subDocument;
  int _current = 0;

  _initilizer() {
    produtoCarrinho = ProdutoCarrinhoModel.fromJson(widget.produto.toJson());
    coletionPai = "carrinho";
    documentPai = streamUsuario.usuario.uidUser != null
        ? streamUsuario.usuario.uidUser
        : "";
    subColection = "carrinho";
    subDocument = "ativo";

    streamCarrinho.cart.produtos.forEach((element) {
      if (element.idProduto == produtoCarrinho.idProduto) {
        produtoCarrinho.quantidade = element.quantidade;
      }
    });

    if (UtilService.stringNotIsNull(widget.produto.urlImg)) {
      fullGaleria.add(widget.produto?.urlImg);
    }
    widget.produto.galeria.forEach((element) {
      if (UtilService.stringNotIsNull(element.toString())) {
        fullGaleria.add(element.toString());
      }
    });

    imageSliders = fullGaleria
        .map((item) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      item,
                      width: 350,
                      height: 300,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(),
                              );
                      },
                    )),
              ),
            ))
        .toList();
  }

  _adicionarAoCarrinho() async {
    if (AppModel.to.bloc<UserBloc>().isLogged) {
      streamCarrinho.addition.add(produtoCarrinho);
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  Text("Para adicionar ao Carrinho é necessário efetuar Login"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar")),
                FlatButton(
                    onPressed: () {
                      timeDilation = 1;
                      Navigator.pushNamed(context, RouteGenerator.LOGIN);
                      timeDilation = 2;
                    },
                    child: Text("Efetuar Login")),
              ],
            );
          });
    }
  }

  _acrescenta() {
    if (produtoCarrinho.quantidade < 200) {
      setState(() {
        produtoCarrinho.quantidade += 1;
        produtoCarrinho.subtotal += produtoCarrinho.preco;
      });
    }
  }

  _reduzir() {
    if (produtoCarrinho.quantidade > 1) {
      setState(() {
        produtoCarrinho.quantidade -= 1;
        produtoCarrinho.subtotal -= produtoCarrinho.preco;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    timeDilation = 2;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timeDilation = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto.titulo),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/background.jpg"),
                fit: BoxFit.cover)),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //imagens do produto
                CarouselSlider(
                  items: imageSliders,
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: fullGaleria.map((url) {
                    int index = fullGaleria.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                    );
                  }).toList(),
                ),

                //container dados produto
                Container(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, top: 16, bottom: 16, right: 8),
                            child: Text(
                              widget.produto.titulo,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 26.0,
                                  color: Color(0xfff49c3c)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Text(widget.produto.descricao,
                                style: TextStyle(fontSize: 20.0,
                                    color: Colors.grey)),
                          ),
                          Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                UtilService.moeda(widget.produto.preco),
                                style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              )),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                      border: Border.all(
                                          width: 1, color: Colors.grey)),
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.remove_circle),
                                        color: produtoCarrinho.quantidade == 1
                                            ? Colors.grey
                                            : Colors.green,
                                        onPressed: () => _reduzir(),
                                      ),
                                      Text(
                                        "${produtoCarrinho.quantidade
                                            .toString()}",
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle),
                                color: produtoCarrinho.quantidade > 199
                                    ? Colors.grey
                                    : Colors.green,
                                onPressed: () => _acrescenta(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              ButtonBar(
                                buttonPadding: EdgeInsets.all(0),
                                children: <Widget>[
                                  FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(10.0)),
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            color: Color(0xff5c3838)),
                                        child: Padding(
                                  padding: EdgeInsets.only(left: 12, right: 25),
                                  child: Row(
                                            children: <Widget>[
                                              IconButton(
                                                padding: EdgeInsets.all(0),
                                                icon: Icon(
                                                    Icons.add_shopping_cart),
                                                color: Colors.white,
                                                onPressed: () {},
                                              ),
                                              Text(
                                                  '${UtilService
                                                      .moeda(produtoCarrinho
                                                      .subtotal)}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontSize: 18.0,
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        )),
                                    onPressed: () {
                                      _adicionarAoCarrinho();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
              ],
            )),
      ),
    );
  }
}
