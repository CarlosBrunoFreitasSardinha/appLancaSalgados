import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/Produto.dart';
import 'package:applancasalgados/models/ProdutoCarrinho.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ViewProduto extends StatefulWidget {
  final Produto produto;

  ViewProduto(this.produto);

  @override
  _ViewProdutoState createState() => _ViewProdutoState();
}

class _ViewProdutoState extends State<ViewProduto> {
  int contagem;
  double resultado;
  double preco;
  Carrinho carrinho = Carrinho();
  ProdutoCarrinho produtoCarrinho = ProdutoCarrinho();
  bool isInitial = true;
  String coletionPai, documentPai, subColection, subDocument;


  _initilizer() {
    contagem = 1;
    preco = widget.produto.preco;
    resultado = preco * contagem;
    coletionPai = "carrinho";
    documentPai = "cJ8II0UZcFSk18kIgRZXzIybXLg2";
    subDocument = "ativo";
    subColection = "carrinho";
  }

  _listenerCarrinho() async {
    DocumentSnapshot snapshot =
        await UtilFirebase.recuperarItemsColecaoGenerica(
            coletionPai, documentPai, subColection, subDocument);

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      carrinho = Carrinho.fromJson(dados);
    }
  }
  verificaItem(){
  produtoCarrinho = ProdutoCarrinho.fromJson(widget.produto.toJson());
  int posicao = -1;
  for(int i=0; i<carrinho.produtos.length;i++){
    if(carrinho.produtos[i].idProduto == produtoCarrinho.idProduto){
      posicao = i;
      break;
    }
  }
  if(posicao != -1){
    carrinho.produtos[posicao].quantidade = carrinho.produtos[posicao].quantidade + contagem;
    carrinho.produtos[posicao].subtotal = carrinho.produtos[posicao].subtotal + resultado;
    carrinho.total = carrinho.total + resultado;
  }
  else{
    produtoCarrinho.quantidade = contagem;
    produtoCarrinho.subtotal = resultado;
    carrinho.addProdutos(produtoCarrinho);
  }
  }
  Future _adicionarAoCarrinho() {

    verificaItem();

    isInitial
      ? UtilFirebase.criarItemComIdColecaoGenerica(coletionPai, documentPai, subColection, subDocument, carrinho.toJson())
      : UtilFirebase.alterarItemColecaoGenerica(coletionPai, documentPai, subColection, subDocument, carrinho.toJson());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    _listenerCarrinho();
    timeDilation = 3;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timeDilation = 1;
  }

  _acrescenta() {
    setState(() {
      contagem += 1;
      resultado += preco;
    });
  }

  _reduzir() {
    if (contagem > 1) {
      setState(() {
        contagem -= 1;
        resultado -= preco;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto.titulo),
      ),
      body: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("imagens/background.jpg"),
                  fit: BoxFit.cover)),
          alignment: Alignment.topCenter,
          child: Hero(
            tag: widget.produto.idProduto,
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45.withOpacity(0.7),
                        spreadRadius: 40,
                        blurRadius: 100,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 32, bottom: 10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          widget.produto.urlImg,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 16, top: 16, right: 16),
                              child: Text(
                                widget.produto.titulo,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30.0,
                                    color: Color(0xfff49c3c)),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 16, top: 16, right: 16),
                              child: Text(widget.produto.descricao,
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.grey)),
                            ),
                            Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  Util.moeda(widget.produto.preco),
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                )),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10.0)),
                                        border: Border.all(
                                            width: 1, color: Colors.grey)),
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.remove_circle),
                                          color: contagem == 1
                                              ? Colors.grey
                                              : Colors.green,
                                          onPressed: () => _reduzir(),
                                        ),
                                        Text(
                                          "$contagem",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add_circle),
                                          color: Colors.green,
                                          onPressed: () => _acrescenta(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                ButtonBar(
                                  children: <Widget>[
                                    FlatButton(
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                              color: Color(0xff5c3838)),
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Row(
                                              children: <Widget>[
                                                IconButton(
                                                  icon:
                                                      Icon(Icons.add_shopping_cart),
                                                  color: Colors.white,
                                                  onPressed: () {},
                                                ),
                                                Text(
                                                    'Adicionar ${Util.moeda(resultado)}',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20.0,
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          )),
                                      onPressed: () {
                                        _adicionarAoCarrinho();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                  ),
                )),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
