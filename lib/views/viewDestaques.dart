import 'dart:async';

import 'package:applancasalgados/models/Produto.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';

class Destaques extends StatefulWidget {
  @override
  _DestaquesState createState() => _DestaquesState();
}

class _DestaquesState extends State<Destaques>
    with SingleTickerProviderStateMixin {
  final PageController ctrl = PageController(viewportFraction: 0.9, initialPage: 0);
  final Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  int currentPage = 0;
  int totalPage = 0;

  Stream<QuerySnapshot> _listarListenerProdutos({String tag = 'promo'}) {
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

    _listarListenerProdutos();

    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });

//    Timer.periodic(Duration(seconds: 4), (Timer timer) {
//      if (currentPage < totalPage) {
//        currentPage++;
//      } else {
//        currentPage = 0;
//      }
//
//      ctrl.animateToPage(
//        currentPage,
//        duration: Duration(seconds: 1),
//        curve: Curves.easeIn,
//      );
//    });
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
              return PageView.builder(
                  controller: ctrl,
                  itemCount: querySnapshot.documents.length,
                  // ignore: missing_return
                  itemBuilder: (context, indice) {
                  totalPage = querySnapshot.documents.length;

                    List<DocumentSnapshot> produtos = querySnapshot.documents.toList();
                    bool active = indice == currentPage;

                    Produto produto = Produto.fromJson(produtos[indice].data);

                    final double blur = active ? 30 : 0;
                    final double offset = active ? 20 : 0;
                    final double top = active ? 50 : 150;

                    return
                    GestureDetector(
                      child: Hero(
                        tag: produto.idProduto,
                        child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeOutQuint,
                            margin:
                            EdgeInsets.only(top: top, bottom: 25, right: 30),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(produto.urlImg),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black87,
                                      blurRadius: blur,
                                      offset: Offset(offset, offset)
                                  )
                                ]),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Flexible(child:
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child:
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(produto.titulo,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 38,
                                                color: Colors.white,
                                                backgroundColor: Colors.black38)),
                                      )
                                  )
                                  ),

                                  Flexible(child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(Util.moeda(produto.preco),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 40,
                                              color: Color(0xffd19c3c),
                                              backgroundColor: Colors.black54))))
                                ],
                              ),
                            )),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteGenerator.PRODUTO,
                            arguments: produto);
                      },
                    );
                  });
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
                fit: BoxFit.cover)
        ),
        child: stream,
      ),
    );
  }
}
