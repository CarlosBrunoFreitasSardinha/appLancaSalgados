import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Destaques extends StatefulWidget {
  @override
  _DestaquesState createState() => _DestaquesState();
}

class _DestaquesState extends State<Destaques>
    with SingleTickerProviderStateMixin {
  final PageController ctrl = PageController(viewportFraction: 0.9);
  final Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  int currentPage = 0;

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
    _listarListenerProdutos();

    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
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
                    List<DocumentSnapshot> produtos =
                        querySnapshot.documents.toList();
                    DocumentSnapshot json = produtos[indice];
                    bool active = indice == currentPage;
                    // Animated Properties
                    final double blur = active ? 30 : 0;
                    final double offset = active ? 20 : 0;
                    final double top = active ? 100 : 200;

                    return AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOutQuint,
                        margin:
                            EdgeInsets.only(top: top, bottom: 50, right: 30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(json['urlImg']),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: blur,
                                  offset: Offset(offset, offset))
                            ]),
                        child: Column(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.center,
                                child: Text(json['titulo'],
                                    style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.white,
                                        backgroundColor: Colors.black38
                                    ))),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(json['preco'],
                                    style: TextStyle(
                                        fontSize: 40,
                                        color: Color(0xffd19c3c),
                                        backgroundColor: Colors.black38
                                    )))
                          ],
                        )
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
                fit: BoxFit.cover)),
        child: stream,
      ),
    );
  }
}
