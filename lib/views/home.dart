import 'dart:async';

import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/views/viewCardapio.dart';
import 'package:applancasalgados/views/viewCarrinho.dart';
import 'package:applancasalgados/views/viewDestaques.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';
import '../models/usuarioFireBase.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Carrinho> _listaConversas = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
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

  Stream<QuerySnapshot> _adicionarListenerCarrinho() {
    Firestore bd = Firestore.instance;
    final stream = bd
        .collection("carrinho")
        .document("cJ8II0UZcFSk18kIgRZXzIybXLg2")
        .collection("carrinhoAtivo")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _verificarUsuarioLogado();
    _adicionarListenerCarrinho();
  }

  @override
  Widget build(BuildContext context) {
    var streamCarrinho = StreamBuilder(
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
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  )
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Erro ao carregar os dados!");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;

              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                );
              }

              String count = "0";
              List<DocumentSnapshot> conversas = querySnapshot.documents.toList();
              DocumentSnapshot item = conversas[0];
              carrinho = Carrinho.fromJson(item.data);
              count = carrinho.produtos.length.toString();

              return Stack(
                alignment: Alignment.topLeft,
                children: <Widget>[
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
                        count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            break;
        }
      },
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
                  indicatorWeight: 4,
                  tabs: [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.restaurant_menu)),
                    Tab(child: streamCarrinho,),
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
            children: [
              Destaques(),
              Cardapio(),
              viewCarrinho(),
            ],
          ),
        ),
      ),

      /* CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            onStretchTrigger: () {
              // Function callback for stretch
              return;
            },
            bottom: TabBar(
                indicatorWeight: 7,
                labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
                controller: _tabController,
                indicatorColor: Platform.isIOS ? Colors.grey[400] : Colors.white,
                tabs: <Widget>[
                  Tab(text: "Destaques",),
                  Tab(text: "Cardapio",),
                  Tab(text: "Carrinho",),
                ]
            ),
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              centerTitle: false,
//              title: const Text('Lança Salgados'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
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
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                leading: Icon(Icons.wb_sunny),
                title: Text('Sunday'),
                subtitle: Text('sunny, h: 80, l: 65'),
              ),
              ListTile(
                leading: Icon(Icons.wb_sunny),
                title: Text('Monday'),
                subtitle: Text('sunny, h: 80, l: 65'),
              ),
              // ListTiles++
            ]),
          ),
        ],
      ),*/
    );
  }
}
