import 'dart:async';

import 'package:applancasalgados/models/Pedido.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewPedidos extends StatefulWidget {
  @override
  _ViewPedidosState createState() => _ViewPedidosState();
}

class _ViewPedidosState extends State<ViewPedidos>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  Pedido pedido = Pedido();
  String coletionPai, documentPai, subColection, subDocument;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollControllerMensagens = ScrollController();

  _initilizer() {
    UserFirebase.recuperaDadosUsuario();
    coletionPai = "pedidos";
    documentPai = UserFirebase.fireLogged.uidUser;
    subColection = "pedidos";
  }

  Widget listaPedidosVazia() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          'Nenhum Pedido Em Aberto :)',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _adicionarListenerProdutos() {
    final stream = bd
        .collection(coletionPai)
        .document(documentPai)
        .collection(subColection)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    _adicionarListenerProdutos();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    var stream = StreamBuilder(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;
            List<DocumentSnapshot> produtos = querySnapshot.documents.toList();

            if (snapshot.hasError) {
              return Expanded(child: Text("Erro ao carregar os dados!"));
            } else {
              return Expanded(
                child: produtos.length != 0
                    ? ListView.builder(
                    controller: _scrollControllerMensagens,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      DocumentSnapshot json = produtos[indice];

                      Pedido produto = Pedido.fromJson(json.data);

                      return Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.format_list_numbered),
                              title: Text(produto.usuario.nome),
                              subtitle: Text(produto.formaPagamento),
                              trailing: Text(
                                  Util.moeda(produto.carrinho.total)),
                            ),
                            Row(
                              children: <Widget>[
                                ButtonBar(
                                  children: <Widget>[
                                    FlatButton(
                                      child: const Text('Visualizar'),
                                      onPressed: () {
                                        /* ... */
                                      },
                                    ),
                                    FlatButton(
                                      child: const Text('Pedido Recebido'),
                                      onPressed: () {
                                        /* ... */
                                      },
                                    ),
                                    FlatButton(
                                      child: const Text('Saiu Para Entrega'),
                                      onPressed: () {
                                        /* ... */
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    })

                    : listaPedidosVazia(),
              );
            }
            break;
        }
      },
    );

    return Scaffold(
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/background.jpg"),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  stream,
                ],
              ),
            )),
      ),
    );
  }
}