import 'package:flutter/material.dart';

class Carrinho extends StatefulWidget {
  @override
  _CarrinhoState createState() => _CarrinhoState();
}

class _CarrinhoState extends State<Carrinho> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Carrinho",
          style: TextStyle(fontSize: 20, color: Colors.green)),
    );
  }
}


