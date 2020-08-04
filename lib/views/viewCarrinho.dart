import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/Pedido.dart';
import 'package:applancasalgados/models/ProdutoCarrinho.dart';
import 'package:applancasalgados/stateLess/CustomListItemTwo.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewCarrinho extends StatefulWidget {
  @override
  _ViewCarrinhoState createState() => _ViewCarrinhoState();
}

class _ViewCarrinhoState extends State<ViewCarrinho>
    with SingleTickerProviderStateMixin {
  TextEditingController _controllerEndereco = TextEditingController();
  Firestore bd = Firestore.instance;
  Carrinho carrinho = Carrinho();
  ProdutoCarrinho _ultimaTarefaRemovida = ProdutoCarrinho();
  String coletionPai,
      documentPai,
      subColection,
      subDocument,
      strPedido = "pedidos";
  String _escolhaUsuario = "";

  List<String> _itensMenu = [
    "Remover",
    "Editar",
  ];

  _initilizer() {
    var obj = UserFirebase.recuperaDadosUsuario();
    coletionPai = "carrinho";
    documentPai = UserFirebase.fireLogged.uidUser;
    subDocument = "ativo";
    subColection = "carrinho";
    setState(() {
      _controllerEndereco.text = UserFirebase.fireLogged.endereco;
    });
  }

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

  Future<Carrinho> _listenerCarrinho() async {
    DocumentSnapshot snapshot =
    await UtilFirebase.recuperarItemsColecaoGenerica(
        coletionPai, documentPai, subColection, subDocument);

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      return Carrinho.fromJson(dados);
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

  Future _alterarCarrinho() {
    UtilFirebase.alterarItemColecaoGenerica(
        coletionPai, documentPai, subColection, subDocument, carrinho.toJson());
  }

  Widget carrinhoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          'Nenhum Produto adicionado ainda:(',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white),
        ),
      ),
    );
  }

  Future _salvarPedido() {
    Pedido pedido = Pedido();
    pedido.usuario = UserFirebase.fireLogged;
    pedido.carrinho = carrinho;
    pedido.formaPagamento = "Cartão de Crédito";
    carrinho.fecharPedido();

    UtilFirebase.criarItemAutoIdColecaoGenerica(
        strPedido, documentPai, strPedido, pedido.toJson());
    carrinho.limpar();
    UtilFirebase.criarItemComIdColecaoGenerica(
        coletionPai, documentPai, subColection, subDocument, carrinho.toJson());

    Navigator.pushReplacementNamed(context, RouteGenerator.HOME, arguments: 3);
  }

  Future _adicionarPedido() {
    if (UserFirebase.logado && carrinho.produtos.length != 0) {
//      AlertDialogEndereco(context);
      AlertDialogFormaPagamento(context);
    }
    else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Para Finalizar o Pedido é necessário efetuar Login"),
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

  AlertDialogEndereco(BuildContext context) {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
            title: Text("Endereço de Cadastrado"),
            content: TextField(
          controller: _controllerEndereco,
        ),
        actions: <Widget>[
          FlatButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text("Enviar"))
        ],
      );
    });
  }

  AlertDialogFormaPagamento(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: Text("Forma de Pagamento"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(4, (int index) {
                    return RadioListTile(
                      title: Text(index.toString()),
                      value: index,
                      groupValue: selectedRadio,
                      onChanged: (int value) {
                        setState(() => selectedRadio = value);
                      },
                    );
                  }),
                );
              },
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
  }

  Widget _criarItemLista(context, index) {
    return CustomListItemTwo(
      thumbnail: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            carrinho.produtos[index].urlImg,
            fit: BoxFit.cover,
          )),
      title: carrinho.produtos[index].titulo,
      subtitle: carrinho.produtos[index].descricao,
      preco: Util.moeda(carrinho.produtos[index].preco),
      quantidade: carrinho.produtos[index].quantidade.toString(),
      subTotal: Util.moeda(carrinho.produtos[index].subtotal),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    var resultante = UserFirebase.logado
        ? FutureBuilder(
        future: _listenerCarrinho(),
        builder: (BuildContext context, AsyncSnapshot<Carrinho> snapshot) {
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
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(width: 1, color: Colors.grey),
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)),
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
                                Text('Finalizar Pedido',
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
                        "Total: " + Util.moeda(carrinho.total),
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
            children = <Widget>[
              carrinhoVazio()
            ];
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
