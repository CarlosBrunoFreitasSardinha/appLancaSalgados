import 'package:applancasalgados/models/Produto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class viewProduto extends StatefulWidget {
  Produto produto;

  viewProduto(this.produto);

  @override
  _viewProdutoState createState() => _viewProdutoState();
}

class _viewProdutoState extends State<viewProduto> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeDilation = 4;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timeDilation = 1;
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.restaurant),
                              title: Text(widget.produto.titulo,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xfff49c3c))),
                              subtitle: Text(widget.produto.descricao,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              trailing: Text(widget.produto.preco,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ),
                            ButtonBar(
                              children: <Widget>[
                                FlatButton(
                                  child: const Text('Adicionar ao Carrinho'),
                                  onPressed: () {
                                    /* ... */
                                  },
                                ),
                                FlatButton(
                                  child: const Text('LISTEN'),
                                  onPressed: () {
                                    /* ... */
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
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
