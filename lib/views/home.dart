import 'dart:async';

import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:applancasalgados/views/viewCardapio.dart';
import 'package:applancasalgados/views/viewCarrinho.dart';
import 'package:applancasalgados/views/viewDestaques.dart';
import 'package:applancasalgados/views/viewPedidos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';
import '../util/usuarioFireBase.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String coletionPai, documentPai, subColection, subDocument;
  Carrinho carrinho = Carrinho();
  List<String> _itensMenu = ["Fazer login", "sair login"];

  inicializacao() {
    if (UserFirebase.logado) {
      if (UserFirebase.fireLogged.isAdm == true) {
        setState(() {
          _itensMenu = ["Configurações", "Perfil", "Pag. de Testes", "Sair"];
        });
      } else {
        setState(() {
          _itensMenu = ["Perfil", "Sair"];
        });
      }
    }
  }

  _deslogar() {
    if (UserFirebase.logado) UserFirebase.deslogar();
    Navigator.popAndPushNamed(context, RouteGenerator.HOME);
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
      case "Fazer login":
        Navigator.pushNamed(context, RouteGenerator.LOGIN);
        break;
      case "Sair":
        _deslogar();
        break;
      case "sair login":
        _deslogar();
        break;
    }
  }

  List<Widget> carrinhoZerado() {
    return [
      Icon(
        Icons.shopping_cart,
        color: Colors.white,
      ),
      Padding(
        padding: EdgeInsets.only(left: 24),
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
    inicializacao();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var futureCarrinho = UserFirebase.logado
        ? FutureBuilder(
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
            children = carrinhoZerado();
          }

          else {
            children = carrinhoZerado();
          }

          return Stack(
            alignment: Alignment.topLeft,
            children: children,
          );
        })
        : Stack(alignment: Alignment.topLeft,
      children: carrinhoZerado(),)
    ;

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
                    Tab(icon: Icon(Icons.storage)),
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
              ViewPedidos(),
            ],
          ),
        ),
      ),
    );
  }
}
