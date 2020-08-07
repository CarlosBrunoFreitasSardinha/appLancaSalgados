import 'dart:async';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/PedidoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemOne.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';

class ViewPedidos extends StatefulWidget {
  @override
  _ViewPedidosState createState() => _ViewPedidosState();
}

class _ViewPedidosState extends State<ViewPedidos>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  final UsuarioLogado = AppModel.to.bloc<UserBloc>();

  String coletionPai = "pedidos",
      documentPai = AppModel.to.bloc<UserBloc>().usuario.uidUser,
      subColection = "pedidos";

  String stts_saiu = "Saiu Para Entrega",
      stts_recebido = "Pedido Recebido",
      stts_EmPreparacao = "Pedido Recebido";

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollControllerMensagens = ScrollController();

  List<String> _itensMenu = [
    "Visualizar Pedido",
    "Pedido Recebido",
    "Saiu para Entrega",
    "Pedido Entregue"
  ];

  Future _alterarDadoPedido(String documentRef, Map<String, dynamic> json) {
    BdService.alterarItemColecaoGenerica(
        coletionPai, documentPai, subColection, documentRef, json);
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
        .where("atendido", isEqualTo: false)
        .orderBy("dataPedido")
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
            List<DocumentSnapshot> produtos = querySnapshot.documents.toList();

            if (snapshot.hasError) {
              return Expanded(child: Text("Erro ao carregar os dados!"));
            }
            else {
              return Expanded(
                child: produtos.length != 0
                    ? ListView.builder(
                    controller: _scrollControllerMensagens,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                          DocumentSnapshot json = produtos[indice];
                          PedidoModel pedido = PedidoModel.fromJson(json.data);
                          String subtitle = "Pagamento via " +
                              pedido.formaPagamento +
                              "\nTotal: " +
                              UtilService.moeda(pedido.carrinho.total);
                          if (pedido.trocoPara != 0) {
                            subtitle += " Troco para " +
                                UtilService.moeda(pedido.trocoPara);
                          }

                          return Padding(
                              padding: EdgeInsets.all(3),
                              child: GestureDetector(
                                  onTap: () {
//                      Navigator.pushNamed( context, RouteGenerator.PRODUTO, arguments: produto);
                                  },
                                  child: CustomListItemOne(
                                    title: pedido.tituloPedido,
                                    subtitle: subtitle,
                                    preco: pedido.status,
                                    color: Colors.white,
                                    radius: 5,
                                    icone: PopupMenuButton<String>(
                                      onSelected: (item) {
                                        switch (item) {
                                          case "Visualizar Pedido":
                                            Navigator.pushNamed(
                                                context, RouteGenerator.PEDIDO,
                                                arguments: pedido);
                                            break;
                                          case "Pedido Recebido":
                                            _alterarDadoPedido(json.documentID,
                                                {"status": stts_recebido});
                                            break;
                                          case "Saiu para Entrega":
                                            _alterarDadoPedido(json.documentID,
                                                {"status": stts_saiu});
                                            break;
                                          case "Pedido Entregue":
                                            _alterarDadoPedido(json.documentID,
                                                {"atendido": true});
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return _itensMenu.map((String item) {
                                          return PopupMenuItem<String>(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  )));
                        })
                    : listaPedidosVazia(),
              );
            }
            break;
        }
      },
    );

    var streamResultanteLogged = StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      // ignore: missing_return
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data
              .isEmailVerified) { // logged in using email and password
            return stream;
          }
        } else { //NotLogged }
          return listaPedidosVazia();
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
            )
        ),
      ),
    );
  }
}
