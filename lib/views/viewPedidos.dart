import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/Pedido.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';

class ViewPedidos extends StatefulWidget {
  @override
  _ViewPedidosState createState() => _ViewPedidosState();
}

class _ViewPedidosState extends State<ViewPedidos>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  Carrinho carrinho = Carrinho();
  Pedido pedido = Pedido();
  String coletionPai, documentPai, subColection, subDocument;

  _initilizer() {
    coletionPai = "carrinho";
    documentPai = "cJ8II0UZcFSk18kIgRZXzIybXLg2";
    subColection = "pedido";
    subDocument = "ativo";
  }

  _verificarUsuarioLogado() {
    if (UserFirebase.logado) {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    }
  }

  Future<Pedido> _listenerCarrinho() async {
    DocumentSnapshot snapshot =
        await UtilFirebase.recuperarItemsColecaoGenerica(
            coletionPai, documentPai, subColection, subDocument);

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      return Pedido.fromJson(dados);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
    _initilizer();
  }

  Widget _criarItemLista(context, index) {
    return ListTile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _listenerCarrinho(),
        builder: (BuildContext context, AsyncSnapshot<Pedido> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            pedido = snapshot.data;

            children = <Widget>[
              carrinho.produtos.length > 0
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: carrinho.produtos.length,
                          itemBuilder: (context, index) {
                            return _criarItemLista(context, index);
                          }),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Nenhum Pedido Em Aberto :)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                    ),
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Nenhum Pedido Encontrado :(',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
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
        });
  }
}
