import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  _verificarUsuarioLogado() async {
    if (!AppModel.to.bloc<UserBloc>().usuario.isAdm) {
      Navigator.pushReplacementNamed(context, RouteGenerator.LOGIN);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações"),),

      body: Container(
        decoration: BoxDecoration(color: Color(0xff5c3838)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "imagens/logo.png",
                      width: 200,
                      height: 150,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: RaisedButton(
                        child: Text(
                          "Categoria",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.pushNamed(context, RouteGenerator.CAD_CATEGORIA);
                        }),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: RaisedButton(
                        child: Text(
                          "Produtos",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.pushNamed(context, RouteGenerator.CAD_PRODUTOS);
                        }),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: RaisedButton(
                        child: Text(
                          "Forma de Pagamento",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, RouteGenerator.CAD_FORMAPAGAMENTO);
                        }),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}
