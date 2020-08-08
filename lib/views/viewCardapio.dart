import 'dart:async';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemOne.dart';
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
  final UsuarioLogado = AppModel.to.bloc<UserBloc>();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollControllerMensagens = ScrollController();
  String idReceptor, urlImagemEnviada;
  List<String> _itensMenu = [];

  _escolhaMenuItem(String itemEscolhido) {
    String i = itemEscolhido.split("-")[1];
    String item = itemEscolhido.split("-")[0];

    switch (item) {
      case "Editar":
        break;
      case "Deletar":
        break;
    }
  }

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

            if (snapshot.hasError) {
              return Expanded(child: Text("Erro ao carregar os dados!"));
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollControllerMensagens,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      List<DocumentSnapshot> produtos =
                          querySnapshot.documents.toList();
                      DocumentSnapshot json = produtos[indice];

                      ProdutoModel produto = ProdutoModel.fromJson(json.data);

                      double larguraContainer =
                          MediaQuery.of(context).size.width;

                      return Padding(
                        padding: EdgeInsets.all(3),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RouteGenerator.PRODUTO,
                                  arguments: produto);
                            },
                            child: CustomListItemOne(
                              thumbnail: GestureDetector(
                                child: Hero(
                                  tag: produto.idProduto,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
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
                              ),
                              title: produto.titulo,
                              subtitle: produto.descricao,
                              preco: UtilService.moeda(produto.preco),
                              color: Colors.white,
                              radius: 5,
                                icone: StreamBuilder<UsuarioModel>(
                                  stream: UsuarioLogado.userLogged,
                                  builder: (BuildContext context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (UtilService.stringNotIsNull(
                                          snapshot.data.uidUser)) {
                                        if (snapshot.data.isAdm) {
                                          _itensMenu = [
                                            "Editar",
                                            "Deletar",
                                          ];
                                        } else {
                                          return SizedBox();
                                        }
                                      } else {
                                        return SizedBox();
                                      }
                                    }
                                    return PopupMenuButton<String>(
                                      onSelected: _escolhaMenuItem,
                                      itemBuilder: (context) {
                                        return _itensMenu.map((String item) {
                                          return PopupMenuItem<String>(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList();
                                      },
                                    );
                                  },
                                ))),
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
