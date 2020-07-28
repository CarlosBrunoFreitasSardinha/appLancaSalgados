import 'dart:async';

import 'package:applancasalgados/models/Produto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';

class Cardapio extends StatefulWidget {
  @override
  _CardapioState createState() => _CardapioState();
}

class _CardapioState extends State<Cardapio>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollControllerMensagens = ScrollController();
  String idReceptor, urlImagemEnviada;

  Stream<QuerySnapshot> _adicionarListenerProdutos() {
    final stream = bd
        .collection("produtos")
        .orderBy("idCategoria", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adicionarListenerProdutos();
    print("Comecando!!!");
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

            if (snapshot.hasError) {
              return Expanded(child: Text("Erro ao carregar os dados!"));
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollControllerMensagens,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera mensagem
                      List<DocumentSnapshot> produtos =
                          querySnapshot.documents.toList();
                      DocumentSnapshot json = produtos[indice];

                      Produto produto = Produto.fromJson(json.data);

                      double larguraContainer =
                          MediaQuery.of(context).size.width;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerLeft;
                      Color cor = Colors.grey[100]; //Color(0xfffff9f4)
                      if (indice % 2 == 0) {
                        cor = Colors.brown[50];
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, RouteGenerator.PRODUTO,
                                    arguments: produto);
                              },
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                      flex: 1,
                                      child: GestureDetector(
                                        child: Hero(
                                          tag: produto.idProduto,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                produto.urlImg,
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, RouteGenerator.PRODUTO,
                                              arguments: produto);
                                        },
                                      )),
                                  Flexible(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(10, 2, 8, 2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text(produto.titulo,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xffd19c3c)))),
                                          Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  8, 2, 4, 4),
                                              child: Text(produto.descricao,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey))),
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text(produto.preco,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87))),
                                          //Color(0xff5c3838)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
      },
    );

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
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
