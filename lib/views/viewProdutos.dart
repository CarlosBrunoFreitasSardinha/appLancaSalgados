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
  int contagem = 0;

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

  _acrescenta() {
    setState(() {
      contagem += 1;
    });
  }

  _reduzir() {
    if (contagem > 0){
      setState(() {
        contagem -= 1;
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
                            padding:
                                EdgeInsets.all( 16),
                            child: Text(
                              widget.produto.preco,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            )),
                        Row(
                          children: <Widget>[
                            FlatButton(
                              child: Icon(Icons.remove),
                              color: Colors.white,
                              splashColor: Colors.black12,
                              onPressed: () =>_reduzir(),
                            ),
                            Text(
                              "$contagem",
                              style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            FlatButton(
                              child: Icon(Icons.add),
                              color: Colors.white,
                              splashColor: Colors.black12,
                              onPressed: () =>_acrescenta(),
                            ),
                            ButtonBar(
                              children: <Widget>[
                                FlatButton(
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.shopping_cart),
                                        color: Color(0xfff49c3c),
                                        onPressed: () {},
                                      ),
                                      Text('Adicionar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20.0,
                                              color: Color(0xfff49c3c)))
                                    ],
                                  ),
                                  onPressed: () {
                                    /* ... */
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
