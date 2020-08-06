import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserFireBaseBloc.dart';
import 'package:applancasalgados/bloc/appBloc.dart';
import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/Autenticacao.dart';
import 'package:applancasalgados/services/BdFireBase.dart';
import 'package:applancasalgados/views/viewCardapio.dart';
import 'package:applancasalgados/views/viewCarrinho.dart';
import 'package:applancasalgados/views/viewDestaques.dart';
import 'package:applancasalgados/views/viewPedidos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  final int opcao;

  Home(this.opcao);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> _itensMenu = ["Login"];
  final UsuarioLogado = AppModel.to.bloc<UserFirebase>();

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
      case "Login":
        if (!AppModel.to
            .bloc<AppBloc>()
            .isLogged)
          Navigator.pushNamed(context, RouteGenerator.LOGIN);
        break;
      case "Sair":
        if (AppModel.to
            .bloc<AppBloc>()
            .isLogged) {
          Autenticacao.deslogar();
          print(AppModel.to
              .bloc<UserFirebase>()
              .usuario
              .toString());
          print(AppModel.to.bloc<AppBloc>().toString());
        }
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
    String coletionPai, documentPai, subColection, subDocument;
    coletionPai = "carrinho";
    documentPai = AppModel.to
        .bloc<UserFirebase>()
        .usuario
        .uidUser;
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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.index = widget.opcao != null ? widget.opcao : 0;
  }

  @override
  Widget build(BuildContext context) {
    var futureCarrinho = AppModel.to
        .bloc<AppBloc>()
        .isLogged
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
        : Stack(
            alignment: Alignment.topLeft,
            children: carrinhoZerado(),
          );

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
                  StreamBuilder<Object>(
                    stream: FirebaseAuth.instance.onAuthStateChanged,
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        if (UsuarioLogado.usuario
                            .isAdm) { // logged in using email and password
                          _itensMenu =
                          ["Configurações", "Perfil", "Pag. de Testes", "Sair"];
                        } else { // logged in using other providers
                          _itensMenu = ["Perfil", "Sair"];
                        }
                      } else {
                        _itensMenu = ["Login"];
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
