import 'dart:async';

import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/CustomListTile.dart';
import 'package:applancasalgados/models/ProdutoCarrinho.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewCarrinho extends StatefulWidget {
  @override
  _ViewCarrinhoState createState() => _ViewCarrinhoState();
}

class _ViewCarrinhoState extends State<ViewCarrinho>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  Carrinho carrinho = Carrinho();
  ProdutoCarrinho _ultimaTarefaRemovida = ProdutoCarrinho();

  Future<Carrinho> _listenerCarrinho() async {
    Firestore bd = Firestore.instance;
    DocumentSnapshot snapshot = await bd
        .collection("carrinho")
        .document("cJ8II0UZcFSk18kIgRZXzIybXLg2")
        .collection("carrinhoAtivo")
        .document("7MmkdZrp4rhrOGig4VAq")
        .get();

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      return Carrinho.fromJson(dados);
    }
  }

  _deleteItem(int index) {
    _ultimaTarefaRemovida = carrinho.produtos[index];
    setState(() {
      carrinho.produtos.removeAt(index);
    });

    //snackbar
    final snackbar = SnackBar(
      content: Text("Produto Removida"),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              carrinho.produtos.insert(index, _ultimaTarefaRemovida);
            });
          }),
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      quantidade: carrinho.produtos[index].quantidade,
      subTotal: Util.moeda(carrinho.produtos[index].subtotal),
      color: Colors.white,
      radius: 5,
      icone: IconButton(
          icon: Icon(Icons.delete_sweep),
          onPressed: () {
            _deleteItem(index);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _listenerCarrinho(),
        builder: (BuildContext context, AsyncSnapshot<Carrinho> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            carrinho = snapshot.data;
            children = <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: carrinho.produtos.length,
                    itemBuilder: (context, index) {
                      return _criarItemLista(context, index);
                    }),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(width: 1, color: Colors.grey),
                    color: Color(0xff5c3838)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              border: Border.all(width: 1, color: Colors.grey),
                              color: Color(0xff006400)),
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.restaurant),
                                  color: Colors.white,
                                  onPressed: () {},
                                ),
                                Text('Finalizar Compra',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 19.0,
                                        color: Colors.white)),
                              ],
                            ),
                          )),
                      onPressed: () {
//                    Navigator.pop(context);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            border: Border.all(width: 1, color: Colors.grey),
                            color: Colors.blueAccent),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text("Total: "+
                              Util.moeda(carrinho.total.toStringAsFixed(2)),
                              style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 19.0,
                              color: Colors.white)
                          ),
                        ))
                  ],
                ),
              )
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Nenhum Produto adicionado :('),
              )
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
                      color: Color(0xffd19c3c)),
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
        });
  }
}
