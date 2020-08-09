import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/PedidoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemTwo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewCarrinho extends StatefulWidget {
  @override
  _ViewCarrinhoState createState() => _ViewCarrinhoState();
}

class _ViewCarrinhoState extends State<ViewCarrinho>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  final UsuarioLogado = AppModel.to.bloc<UserBloc>();

  final cartShip = AppModel.to.bloc<CarrinhoBloc>();
  CarrinhoModel carrinho = CarrinhoModel();
  ProdutoCarrinhoModel _ultimaTarefaRemovida = ProdutoCarrinhoModel();
  String coletionPai = "carrinho",
      documentPai = AppModel.to.bloc<UserBloc>().usuario
          .uidUser,
      subDocument = "ativo",
      subColection = "carrinho",
      strPedido = "pedidos";

  List<String> _itensMenu = [
    "Remover",
    "Editar",
  ];

  _escolhaMenuItem(String itemEscolhido) {
    int i = int.parse(itemEscolhido.split("-")[1]);
    String item = itemEscolhido.split("-")[0];
    switch (item) {
      case "Remover":
        _deleteItem(i);
        break;
      case "Editar":
        Navigator.pushNamed(context, RouteGenerator.PRODUTO,
            arguments: carrinho.produtos[i]);
        break;
    }
  }



  _deleteItem(int index) {
    _ultimaTarefaRemovida = carrinho.produtos[index];
    setState(() {
      carrinho.produtos.removeAt(index);
      carrinho.calcular();
    });
    _alterarCarrinho();

    //snackbar
    final snackbar = SnackBar(
      content: Text("Produto Removido"),
      duration: Duration(seconds: 4),
      action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              carrinho.produtos.insert(index, _ultimaTarefaRemovida);
              carrinho.calcular();
            });
            _alterarCarrinho();
          }),
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  Future _alterarCarrinho() =>
      BdService.alterarItemColecaoGenerica(
        coletionPai, documentPai, subColection, subDocument, carrinho.toJson());

  Widget carrinhoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          'Nenhum Produto adicionado ainda:(',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _adicionarPedido() {
    if (AppModel.to.bloc<UserBloc>().isLogged && carrinho.produtos.length != 0) {
      PedidoModel pedido = PedidoModel();
      pedido.usuario = AppModel.to
          .bloc<UserBloc>()
          .usuario;
      pedido.carrinho = carrinho;
      pedido.enderecoEntrega = pedido.usuario.endereco;
      Navigator.pushNamed(context, RouteGenerator.PEDIDO, arguments: pedido);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Para fechar o carrinho é necessário efetuar Login!"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar")),
                FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteGenerator.LOGIN);
                    },
                    child: Text("Efetuar login")),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _alterarCarrinho();
  }

  Widget _criarItemLista(context, index) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: CustomListItemTwo(
        thumbnail: GestureDetector(
          child: Hero(
            tag: carrinho.produtos[index].idProduto,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  carrinho.produtos[index].urlImg,
                  fit: BoxFit.cover,
                )),
          ),
          onTap: () {
            Navigator.pushNamed(context, RouteGenerator.PRODUTO,
                arguments: carrinho.produtos[index]);
          },
        ),
        title: carrinho.produtos[index].titulo,
        subtitle: carrinho.produtos[index].descricao,
        preco: UtilService.moeda(carrinho.produtos[index].preco),
        quantidade: carrinho.produtos[index].quantidade.toString(),
        subTotal: UtilService.moeda(carrinho.produtos[index].subtotal),
        color: Colors.white,
        radius: 5,
        icone: PopupMenuButton<String>(
          onSelected: _escolhaMenuItem,
          itemBuilder: (context) {
            return _itensMenu.map((String item) {
              return PopupMenuItem<String>(
                value: item + '-' + index.toString(),
                child: Text(item),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var resultante = AppModel.to
        .bloc<UserBloc>()
        .isLogged
        ? StreamBuilder(
        stream: cartShip.cartStream,
            builder:
                (BuildContext context, AsyncSnapshot<CarrinhoModel> snapshot) {
              List<Widget> children;
          if (snapshot.hasData) {
            carrinho = snapshot.data;

            children = <Widget>[
              carrinho.produtos.length > 0
                  ? Expanded(
                child: ListView.builder(
                    itemCount: carrinho.produtos.length,
                    itemBuilder: (context, index) {
                      return _criarItemLista(context, index);
                    }),
              )
                  : carrinhoVazio(),
              carrinho.produtos.length > 0
                  ? Container(
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(width: 1, color: Colors.grey),
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                              border: Border.all(
                                  width: 1, color: Colors.grey),
                              color: Color(0xffd19c3c)),
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.restaurant),
                                  color: Colors.white,
                                  onPressed: () {},
                                ),
                                Text('Fechar Carrinho',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 19.0,
                                        color: Colors.white)),
                              ],
                            ),
                          )),
                      onPressed: () {
                        _adicionarPedido();
//                    Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Total: " + UtilService.moeda(carrinho.total),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Center()
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[carrinhoVazio()];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Carrendo os Dados...',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
              )
            ];
          }
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("imagens/background.jpg"),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          );
        })
        : Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("imagens/background.jpg"),
              fit: BoxFit.cover)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[carrinhoVazio()],
        ),
      ),
    );
    return resultante;
  }
}
