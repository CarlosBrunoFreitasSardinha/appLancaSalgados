import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/ProdutoCarrinho.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListaDeTarefas extends StatefulWidget {
  @override
  _ListaDeTarefasState createState() => _ListaDeTarefasState();
}

class _ListaDeTarefasState extends State<ListaDeTarefas>  with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  Carrinho carrinho = Carrinho();
  ProdutoCarrinho _ultimaTarefaRemovida = ProdutoCarrinho();

  _adicionarListenerProdutos() async{
    Firestore bd = Firestore.instance;
    DocumentSnapshot snapshot = await bd
        .collection("carrinho")
        .document("cJ8II0UZcFSk18kIgRZXzIybXLg2")
        .collection("carrinhoAtivo")
        .document("7MmkdZrp4rhrOGig4VAq").get();

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      this.carrinho = Carrinho.fromJson(dados);
      print("Carrinho"+this.carrinho.toString());
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adicionarListenerProdutos();
  }

  Widget _CriarItemLista(context, index) {

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {

        _ultimaTarefaRemovida = carrinho.produtos[index];
        carrinho.produtos.removeAt(index);

        //snackbar
        final snackbar = SnackBar(
          content: Text("Produto Removida"),
          duration: Duration(seconds: 5),
//          backgroundColor: Colors.green,
          action:
          SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  carrinho.produtos.insert(index, _ultimaTarefaRemovida);
                });
              }
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Color(0xFFe10000),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),

      child: ListTile(
        leading: ClipRRect(
            borderRadius:
            BorderRadius.circular(15),
            child: Image.network(
              carrinho.produtos[index].urlImg,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )),
        title: Text(carrinho.produtos[index].titulo),
        subtitle: Text(carrinho.produtos[index].descricao),
        trailing: Text(carrinho.produtos[index].preco),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: carrinho.produtos.length,
                  itemBuilder: (context, index) {
                    return _CriarItemLista(context, index);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}