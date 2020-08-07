import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:flutter/material.dart';

class CarrinhoAppBarIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final carrinhoService = AppModel.to.bloc<CarrinhoBloc>();
    return StreamBuilder(
      stream: carrinhoService.cartStream,
      initialData: Carrinho(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          if (snapshot.data is Carrinho) {
            count = snapshot.data.produtos.length;
          }
        }

        return Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
