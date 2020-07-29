import 'dart:async';

import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/CustomListTile.dart';
import 'package:applancasalgados/models/Produto.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class viewCarrinho extends StatefulWidget {
  @override
  _viewCarrinhoState createState() => _viewCarrinhoState();
}

class _viewCarrinhoState extends State<viewCarrinho>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollControllerMensagens = ScrollController();
  Carrinho carrinho = Carrinho();
  Produto _ultimaTarefaRemovida = Produto();

  Future<Carrinho> _ListenerCarrinho() async {
    Firestore bd = Firestore.instance;
    DocumentSnapshot snapshot = await bd
        .collection("carrinho")
        .document("cJ8II0UZcFSk18kIgRZXzIybXLg2")
        .collection("carrinhoAtivo")
        .document("7MmkdZrp4rhrOGig4VAq")
        .get();
    print("Estou aqui !");
    if (snapshot.data != null) {
      print("Cheguei aqui tbm!");
      Map<String, dynamic> dados = snapshot.data;
      return Carrinho.fromJson(dados);
    }
  }
  _deleteItem(int index){
    _ultimaTarefaRemovida = carrinho.produtos[index];
    carrinho.produtos.removeAt(index);

    //snackbar
    final snackbar = SnackBar(
      content: Text("Produto Removida"),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              carrinho.produtos.insert(index, _ultimaTarefaRemovida);
            });
          }),
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _CriarItemLista(context, index) {
    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _deleteItem(index);
        },
        background: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("Remover", style: TextStyle(color: Colors.white, fontSize: 20),),
              Icon( Icons.delete, color: Colors.white,)
            ],
          ),
        ),
        child: CustomListItemTwo(
          thumbnail: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                carrinho.produtos[index].urlImg,
                fit: BoxFit.cover,
              )),
          title: carrinho.produtos[index].titulo,
          subtitle: carrinho.produtos[index].descricao,
          author: Util.moeda(carrinho.produtos[index].preco),
          color: Colors.white,
          radius: 5,
          icone: IconButton(icon: Icon(Icons.delete_sweep),
              onPressed: (){
            _deleteItem(index);
          }),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _ListenerCarrinho(),
        builder: (BuildContext context, AsyncSnapshot<Carrinho> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            carrinho = snapshot.data;
            children = <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: carrinho.produtos.length,
                    itemBuilder: (context, index) {
                      return _CriarItemLista(context, index);
                    }),
              ),
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Nenhum Produto adicionado :('),
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
                child: Text('Carrendo os Dados...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xffd19c3c)),),
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
