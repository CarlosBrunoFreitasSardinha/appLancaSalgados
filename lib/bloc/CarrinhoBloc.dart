import 'dart:async';

import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class CarrinhoBloc extends BlocBase {
  static const String TAG = "CarrinhoServiceBloc";

  Carrinho cart = Carrinho();

  /// Sinks
  Sink<ProdutoCarrinho> get addition => itemAdditionController.sink;
  final itemAdditionController = StreamController<ProdutoCarrinho>();

  Sink<ProdutoCarrinho> get substraction => itemSubtractionController.sink;
  final itemSubtractionController = StreamController<ProdutoCarrinho>();

  Sink<Carrinho> get cartAddition => cartAdditionController.sink;
  final cartAdditionController = StreamController<Carrinho>();

  /// Streams
  Stream<Carrinho> get cartStream => _carrinho.stream;
  final _carrinho = BehaviorSubject<Carrinho>();

  CarrinhoBloc() {
    itemAdditionController.stream.listen(adicionarItemCarrinho);
    itemSubtractionController.stream.listen(removerItemCarrinho);
    cartAdditionController.stream.listen(adicionarCarrinho);
  }

  /// Logic for product added to shopping cart.
  void adicionarItemCarrinho(ProdutoCarrinho item) {
    cart.addProdutos(item);
    cart.calcular();
    _carrinho.add(cart);
    return;
  }

  /// Logic for product removed from shopping cart.
  void removerItemCarrinho(ProdutoCarrinho item) {
    cart.remProdutos(item);
    cart.calcular();
    _carrinho.add(cart);
    return;
  }

  /// Logic for product removed from shopping cart.
  void adicionarCarrinho(Carrinho thisCart) {
    cart = thisCart;
    _carrinho.add(cart);
    return;
  }

  /// Clears the shopping cart
  void clearCart() {
    cart.limpar();
  }

  @override
  void dispose() {
    itemAdditionController.close();
    itemSubtractionController.close();
  }
}
