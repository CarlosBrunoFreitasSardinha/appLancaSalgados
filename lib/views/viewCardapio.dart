import 'dart:async';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CategoriaProdutoModel.dart';
import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/BdService.dart';
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
  List<String> _itensMenu = [];
  List<ProdutoModel> listaDeProdutos = [];

  Future<List<ProdutoModel>> _adicionarListenerProdutos() async {
    QuerySnapshot querySnapshot = UsuarioLogado.usuario.isAdm
        ? await bd
            .collection("produtos")
            .orderBy("idCategoria", descending: false)
            .getDocuments()
        : await bd
            .collection("produtos")
            .where("isOcult", isEqualTo: false)
        .getDocuments();

    for (DocumentSnapshot json in querySnapshot.documents) {
      listaDeProdutos.add(ProdutoModel.fromJson(json.data));
    }

    return listaDeProdutos;
  }

  Future<List<CategoriaProdutoModel>> futureListCategoria() async {
    Firestore bd = Firestore.instance;
    QuerySnapshot querySnapshot = await bd
        .collection("categoria")
        .orderBy("idCategoria", descending: false)
        .getDocuments();
    List<CategoriaProdutoModel> options = [];
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      DocumentSnapshot snap = querySnapshot.documents[i];
      options.add(CategoriaProdutoModel.fromJson(snap.data));
    }
    return options;
  }

  Future<QuerySnapshot> futureProdutos(String categoria) async {
    QuerySnapshot querySnapshot = await bd
        .collection("produtos")
        .where("idCategoria", isEqualTo: categoria)
        .getDocuments();
    return querySnapshot;
  }

  List<Widget> listaItens(String categoria) {
    List<Widget> lista = [];
    for (ProdutoModel produtoModel in listaDeProdutos) {
      if (produtoModel.idCategoria == categoria) {
        lista.add(Container(
          color: Colors.black45.withOpacity(0.7),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8, top: 8, left: 3, right: 3),
            child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RouteGenerator.PRODUTO,
                      arguments: produtoModel);
                },
                child: CustomListItemOne(
                    thumbnail: GestureDetector(
                      child: Hero(
                        tag: produtoModel.idProduto,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              produtoModel.urlImg,
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            )),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.PRODUTO,
                            arguments: produtoModel);
                      },
                    ),
                    title: produtoModel.titulo,
                    subtitle: produtoModel.descricao,
                    preco: UtilService.moeda(produtoModel.preco),
                    color: produtoModel.isOcult ? Colors.black26 : Colors.white,
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
                          onSelected: (itemEscolhido) {
                            switch (itemEscolhido) {
                              case "Editar":
                                Navigator.pushNamed(
                                    context, RouteGenerator.CAD_PRODUTOS,
                                    arguments: produtoModel);
                                break;
                              case "Deletar":
                                BdService.removerDados(
                                    "produtos", produtoModel.idProduto);
                                listaDeProdutos.remove(produtoModel);
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
                        );
                      },
                    ))),
          ),
        ));
      }
    }
    return lista;
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerProdutos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var future = FutureBuilder(
        future: futureListCategoria(),
        initialData: CategoriaProdutoModel(),
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
              if (snapshot.hasError) {
                return Expanded(child: Text("Erro ao carregar os dados!"));
              } else {
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, indice) {
                        List<Widget> subLista = listaItens(
                            snapshot.data[indice].descricao);
                        return subLista.length == 0
                            ? SizedBox()
                            : Padding(
                          padding: EdgeInsets.only(bottom: 5, top: 5),
                          child: Card(
                            child: ExpansionTile(
                              backgroundColor: Colors.grey[100],
                              title: Padding(
                                padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
                                child: Text(
                                  snapshot.data[indice].descricao,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme
                                          .of(context)
                                          .accentColor,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              children: listaItens(
                                  snapshot.data[indice].descricao),),
                          ),
                        );
                      }),
                );
              }
              break;
          }
        });


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
              future,
            ],
          ),
        )),
      ),
    );
  }
}
