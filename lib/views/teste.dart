import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemTwo.dart';
import 'package:flutter/material.dart';

import '../RouteGenerator.dart';

class pagCarrinhoStream extends StatefulWidget {
  @override
  _pagCarrinhoStreamState createState() => _pagCarrinhoStreamState();
}

class _pagCarrinhoStreamState extends State<pagCarrinhoStream> {
  Carrinho cart;
  final CartShip = AppModel.to.bloc<CarrinhoBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Teste Cart"),
        ),
        body: StreamBuilder(
            stream: CartShip.cartStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text("Shopping cart is empty"));
              } else {
                cart = snapshot.data;
                if (cart.produtos.length == 0) {
                  return Center(child: Text("Shopping cart is empty"));
                }
                return Container(
                    padding: EdgeInsets.all(16),
                    child: Column(children: [
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            Card(
                              child: ListTile(
                                leading: Text("Total - Gross",
                                    style: Theme.of(context).textTheme.subhead),
                                trailing: Text(cart.total.toString() + " €",
                                    style:
                                    Theme.of(context).textTheme.headline),
                              ),
                            ),
                            Card(
                              child: ExpansionTile(
                                  title: Text("Products (" +
                                      cart.produtos.length.toString() +
                                      ")"),
                                  children: getProdutos()),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            child: Text("Order now!"),
                            onPressed: () {
                              CartShip.clearCart();
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text("Order completed!")));
//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) => Example5()),
//                              );
                            },
                          ),
                        ),
                      )
                    ]));
              }
            }));
  }

  List<Widget> getProductTiles() {
    List<Widget> list = [];
    if (cart != null) {
      for (ProdutoCarrinho p in cart.produtos) {
        String name = p.titulo;
        String price = p.preco.toString();
        list.add(ListTile(
          title: Text(name),
          subtitle: Text(price + " €"),
          trailing: FlatButton(
            padding: EdgeInsets.only(left: 0, right: 0),
            child: Icon(Icons.clear, color: Colors.red),
            onPressed: () {
              CartShip.substraction.add(p);
            },
          ),
        ));
      }
    }
    return list;
  }

  List<Widget> getProdutos() {
    List<Widget> list = [];
    if (cart != null) {
      for (ProdutoCarrinho p in cart.produtos) {
        list.add(CustomListItemTwo(
          thumbnail: GestureDetector(
            child: Hero(
              tag: p.idProduto,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    p.urlImg,
                    fit: BoxFit.cover,
                  )),
            ),
            onTap: () {
              Navigator.pushNamed(context, RouteGenerator.PRODUTO,
                  arguments: p);
            },
          ),
          title: p.titulo,
          subtitle: p.descricao,
          preco: UtilService.moeda(p.preco),
          quantidade: p.quantidade.toString(),
          subTotal: UtilService.moeda(p.subtotal),
          color: Colors.white,
          radius: 5,
          icone: Icon(Icons.camera),
        ));
      }
    }
    return list;
  }
}
