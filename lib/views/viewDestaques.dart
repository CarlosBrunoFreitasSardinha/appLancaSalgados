import 'dart:async';

import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Destaques extends StatefulWidget {
  @override
  _DestaquesState createState() => _DestaquesState();
}

class _DestaquesState extends State<Destaques>
    with SingleTickerProviderStateMixin {
  final Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  List<Widget> imageSliders;
  List<String> fullGaleria = [];
  int _current = 0;

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
              fullGaleria.clear();
              List<DocumentSnapshot> produtos =
                  querySnapshot.documents.toList();
              for (DocumentSnapshot documentSnapshot in produtos) {
                ProdutoModel produto =
                    ProdutoModel.fromJson(documentSnapshot.data);
                fullGaleria.add(produto.urlImg);
              }

              imageSliders = fullGaleria
                  .map((item) => Container(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                item,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : Center(
                                          child: LinearProgressIndicator(),
                                        );
                                },
                              )),
                        ),
                      ))
                  .toList();
              return Column(
                children: <Widget>[
                  //imagem do produto
                  Expanded(
                      child: CarouselSlider(
                    items: imageSliders,
                    options: CarouselOptions(
                        autoPlay: true,
                        height: MediaQuery.of(context).size.height * 0.9,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        }),
                  )),
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
                ],
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
                fit: BoxFit.cover)
        ),
        child: SafeArea(child: stream),
      ),
    );
  }
}
