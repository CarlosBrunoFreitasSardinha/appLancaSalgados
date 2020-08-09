import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/AuthService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CarrinhoAppBarIcon.dart';
import 'package:applancasalgados/views/viewCardapio.dart';
import 'package:applancasalgados/views/viewCarrinho.dart';
import 'package:applancasalgados/views/viewDestaques.dart';
import 'package:applancasalgados/views/viewPedidos.dart';
import 'package:flutter/material.dart';

class ViewHome extends StatefulWidget {
  final int opcao;

  ViewHome(this.opcao);

  @override
  _ViewHomeState createState() => _ViewHomeState();
}

class _ViewHomeState extends State<ViewHome>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> _itensMenu = ["Login"];
  final UsuarioLogado = AppModel.to.bloc<UserBloc>();

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
        if (!AppModel.to.bloc<UserBloc>().isLogged)
          Navigator.pushNamed(context, RouteGenerator.LOGIN);
        _tabController.index = 0;
        break;
      case "Sair":
        if (AppModel.to.bloc<UserBloc>().isLogged) {
          AuthService.deslogar();
          _tabController.index = 0;
        }
        break;
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
    var futureCarrinho = CarrinhoAppBarIcon();

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
                    Tab(
                      child: futureCarrinho,
                    ),
                    Tab(icon: Icon(Icons.storage)),
                  ],
                ),
                actions: <Widget>[
                  StreamBuilder<UsuarioModel>(
                    stream: UsuarioLogado.userLogged,
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        if (UtilService.stringNotIsNull(
                            snapshot.data.uidUser)) {
                          if (snapshot.data.isAdm) {
                            _itensMenu = [
                              "Configurações",
                              "Perfil",
                              "Pag. de Testes",
                              "Sair"
                            ];
                          } else {
                            _itensMenu = ["Perfil", "Sair"];
                          }
                        } else {
                          _itensMenu = ["Login"];
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
