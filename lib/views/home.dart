import 'dart:async';

import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:applancasalgados/views/viewCardapio.dart';
import 'package:applancasalgados/views/viewCarrinho.dart';
import 'package:applancasalgados/views/viewDestaques.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';
import '../util/usuarioFireBase.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool isInitial = true;
  String coletionPai, documentPai, subColection, subDocument;
  Carrinho carrinho = Carrinho();
  List<String> _itensMenu = [
    "Configurações",
    "Perfil",
    "Pag. de Testes",
    "Sair"
  ];

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    }
  }

  _deslogar() async {
    UserFirebase.deslogar();
    Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, RouteGenerator.CONFIG);
        break;
      case "Perfil":
        Navigator.pushNamed(context, RouteGenerator.PERFIL);
        break;
      case "Pag. de Testes":
        Navigator.pushNamed(context, RouteGenerator.TESTE);
        break;
      case "Sair":
        _deslogar();
        break;
    }
  }

  Future<int> _listenerCarrinho() async {
    coletionPai = "carrinho";
    documentPai = "cJ8II0UZcFSk18kIgRZXzIybXLg2";
    subDocument = "ativo";
    subColection = "carrinho";
    DocumentSnapshot snapshot =
    await UtilFirebase.recuperarItemsColecaoGenerica(
        coletionPai, documentPai, subColection, subDocument);

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      return Carrinho.fromJson(dados).produtos.length;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {

    var futureCarrinho = FutureBuilder(
        future: _listenerCarrinho(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {

          List<Widget> children;

          if (snapshot.hasData) {
            children = <Widget>[
                Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 24 ),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      snapshot.data.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
              ];
          }

          else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24 ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    "0",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
            ];
          }

          else {
            children = <Widget>[
              Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24 ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    "0",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
            ];
          }

          return Stack(
            alignment: Alignment.topLeft,
            children: children,
          );
        });

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                expandedHeight: 150.0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: <StretchMode>[
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle,
                  ],
                  centerTitle: false,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'imagens/tentativa.jpg',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.0, 0.5),
                            end: Alignment(0.0, 0.0),
                            colors: <Color>[
                              Color(0x60000000),
                              Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorWeight: 4,
                  tabs: [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.restaurant_menu)),
                    Tab(child: futureCarrinho,),
                  ],
                ),
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: _escolhaMenuItem,
                    itemBuilder: (context) {
                      return _itensMenu.map((String item) {
                        return PopupMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList();
                    },
                  )
                ],
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              Destaques(),
              Cardapio(),
              ViewCarrinho(),
            ],
          ),
        ),
      ),
    );
  }
}
