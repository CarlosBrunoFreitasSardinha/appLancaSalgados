import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  CarrinhoModel carrinho = CarrinhoModel();
  ProdutoCarrinhoModel produtoCarrinho = ProdutoCarrinhoModel();
  bool isInitial = true;
  String coletionPai, documentPai, subColection, subDocument;


  _initilizer() {
    produtoCarrinho = ProdutoCarrinhoModel.fromJson(widget.produto.toJson());
    coletionPai = "carrinho";
    documentPai = AppModel.to.bloc<UserBloc>().usuario.uidUser != null
        ? AppModel.to.bloc<UserBloc>().usuario.uidUser
        : "";
    subColection = "carrinho";
    subDocument = "ativo";
  }

  _listenerCarrinho() async {
    DocumentSnapshot snapshot = await BdService.recuperarItemsColecaoGenerica(
        coletionPai, documentPai, subColection, subDocument);

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      carrinho = CarrinhoModel.fromJson(dados);
    }
  }

  Future _adicionarAoCarrinho() {
    if (AppModel.to
        .bloc<AppBloc>()
        .isLogged) {
      streamCarrinho.addition.add(produtoCarrinho);
      carrinho.addProdutos(produtoCarrinho);
      isInitial
          ? BdService.criarItemComIdColecaoGenerica(coletionPai, documentPai,
          subColection, subDocument, carrinho.toJson())
          : BdService.alterarItemColecaoGenerica(coletionPai, documentPai,
          subColection, subDocument, carrinho.toJson());

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
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteGenerator.LOGIN),
                    child: Text("Efetuar login")),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    _listenerCarrinho();
    timeDilation = 3;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timeDilation = 1;
  }

  _acrescenta() {
    setState(() {
      produtoCarrinho.quantidade += 1;
      produtoCarrinho.subtotal += produtoCarrinho.preco;
    });
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
                //imagem do produto
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45.withOpacity(0.7),
                        spreadRadius: 40,
                        blurRadius: 100,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 24, bottom: 10),
                    child: Hero(
                      tag: widget.produto.idProduto,
                      child: GestureDetector(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              widget.produto.urlImg,
                              width: 290,
                              height: 290,
                              fit: BoxFit.cover,
                            )),
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),

                //container dados produto
                Container(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding:
                            EdgeInsets.only(
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
                            padding:
                            EdgeInsets.only(left: 16, right: 8),
                            child: Text(widget.produto.descricao,
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.grey)),
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
                                  decoration:
                                  BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                      border: Border.all(
                                          width: 1, color: Colors.grey)
                                  ),
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
                                        color: Colors.green,
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            color: Color(0xff5c3838)),
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Row(
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                    Icons.add_shopping_cart),
                                                color: Colors.white,
                                                onPressed: () {},
                                              ),
                                              Text(
                                                  'Adicionar ${UtilService
                                                      .moeda(
                                                      produtoCarrinho
                                                          .subtotal)}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontSize: 20.0,
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
                    )
                ),
              ],
            )
        ),
      ),
    );
  }
}
