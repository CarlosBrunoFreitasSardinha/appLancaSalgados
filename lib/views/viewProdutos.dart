import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/Produto.dart';
import 'package:applancasalgados/models/ProdutoCarrinho.dart';
import 'package:applancasalgados/util/Util.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class viewProduto extends StatefulWidget {
  Produto produto;

  viewProduto(this.produto);

  @override
  _viewProdutoState createState() => _viewProdutoState();
}

class _viewProdutoState extends State<viewProduto> {
  int contagem;
  double resultado;
  double preco;
  String coletionPai, documentPai, subColection, subDocument;
  Carrinho carrinho = Carrinho();


  _initilizer() {
    contagem = 1;
    preco = double.parse(widget.produto.preco);
    resultado = preco * contagem;
    coletionPai = "carrinho";
    documentPai = "cJ8II0UZcFSk18kIgRZXzIybXLg2";
    subDocument = "carrinhoAtivo";
    subColection = "7MmkdZrp4rhrOGig4VAq";
  }

  _ListenerCarrinho() async {
    DocumentSnapshot snapshot =
        await UtilFirebase.recuperarItemsColecaoGenerica(
            coletionPai, documentPai, subColection, subDocument);

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      carrinho = Carrinho.fromJson(dados);
    }
  }
  _adicionarAoCarrinho() {

    ProdutoCarrinho produtoCarrinho = ProdutoCarrinho.fromJson(widget.produto.toJson());
    produtoCarrinho.quantidade = contagem.toString();
    produtoCarrinho.subtotal = resultado.toStringAsFixed(2);

    carrinho.addProdutos(produtoCarrinho);

//    UtilFirebase.criarItemComIdColecaoGenerica(coletionPai, documentPai, subColection, subDocument, carrinho.toJson());
    print("carinho in produts"+carrinho.toJson().toString());
    UtilFirebase.alterarItemColecaoGenerica(coletionPai, documentPai, subColection, subDocument, carrinho.toJson());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    _ListenerCarrinho();
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
                                                    'Adicionar ${Util.moeda(resultado.toStringAsFixed(2))}',
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
