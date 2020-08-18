import 'dart:async';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/models/PedidoModel.dart';
import 'package:applancasalgados/models/UsuarioModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemOne.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../RouteGenerator.dart';

class ViewPedidos extends StatefulWidget {
  @override
  _ViewPedidosState createState() => _ViewPedidosState();
}

class _ViewPedidosState extends State<ViewPedidos>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  final blocUser = AppModel.to.bloc<UserBloc>();

  final _controller = StreamController<QuerySnapshot>.broadcast();

  List<String> _itensMenu = [];

  _alterarDadoPedido(String documentRef, Map<String, dynamic> json) async {
    BdService.updateDocumentInSubColection(
        "pedidos", blocUser.usuario.uidUser, "pedidos", documentRef, json);
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

  _adicionarListenerProdutos() {
    final stream = bd
        .collection("pedidos")
        .document(blocUser.usuario.uidUser)
        .collection("pedidos")
        .where("atendido", isEqualTo: false)
        .orderBy("dataPedido", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  enviarNotificacao(String msg, String destinatario) async {
    await OneSignal.shared.postNotification(
      OSCreateNotification(
        playerIds: [destinatario],
        content: msg,
        heading: "Nova mensagem",
      ),
    );
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
            } else {
              return Expanded(
                child: produtos.length != 0
                    ? ListView.builder(
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
                                    Navigator.pushNamed(
                                        context, RouteGenerator.PEDIDO,
                                        arguments: pedido);
                                  },
                                  child: CustomListItemOne(
                                    title: pedido.tituloPedido,
                                    subtitle: subtitle,
                                    preco: pedido.status,
                                    color: Colors.white,
                                    radius: 5,
                                    icone: StreamBuilder<UsuarioModel>(
                                      stream: blocUser.userLogged,
                                      builder:
                                          (BuildContext context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (UtilService.stringNotIsNull(
                                              snapshot.data.uidUser)) {
                                            if (snapshot.data.isAdm) {
                                              _itensMenu = [
                                                "Recebido",
                                                "Saiu para Entrega",
                                                "Entregue"
                                              ];
                                            } else {
                                              _itensMenu = [];
                                            }
                                          } else {
                                            _itensMenu = [];
                                          }
                                        }
                                        return PopupMenuButton<String>(
                                          onSelected: (item) {
                                            switch (item) {
                                              case "Recebido":
                                                _alterarDadoPedido(
                                                    json.documentID,
                                                    {"status": "Recebido"});
                                                enviarNotificacao(
                                                    "Seu Pedido Foi Recebido",
                                                    pedido
                                                        .idCelularSolicitante);
                                                break;
                                          case "Saiu para Entrega":
                                            _alterarDadoPedido(
                                                json.documentID, {
                                                  "status": "Saiu para Entrega"
                                                });
                                            enviarNotificacao(
                                                "Seu Pedido Saiu para Entrega",
                                                pedido
                                                    .idCelularSolicitante);
                                            break;
                                          case "Entregue":
                                            _alterarDadoPedido(
                                                json.documentID, {
                                                  "status": "Entregue",
                                                  "atendido": true
                                                });
                                                break;
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return _itensMenu
                                            .map((String item) {
                                          return PopupMenuItem<String>(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList();
                                      },
                                    );
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
