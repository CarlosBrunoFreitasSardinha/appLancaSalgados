import 'dart:async';

import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class CarrinhoService extends BlocBase {
  static const String TAG = "CarrinhoServiceBloc";

  Carrinho cart = Carrinho();

  /// Sinks
  Sink<ProdutoCarrinho> get addition => itemAdditionController.sink;
  final itemAdditionController = StreamController<ProdutoCarrinho>();

  Sink<ProdutoCarrinho> get substraction => itemSubtractionController.sink;
  final itemSubtractionController = StreamController<ProdutoCarrinho>();

  /// Streams
  Stream<Carrinho> get cartStream => _cart.stream;

  final _cart = BehaviorSubject<Carrinho>();

  CarrinhoService() {
    itemAdditionController.stream.listen(handleItemAdd);
    itemSubtractionController.stream.listen(handleItemRem);
  }

  ///
  /// Logic for product added to shopping cart.
  ///
  void handleItemAdd(ProdutoCarrinho item) {
//    Logger(TAG).info("Add product to the shopping cart");
    cart.addProdutos(item);
    cart.calcular();
    _cart.add(cart);
    return;
  }

  ///
  /// Logic for product removed from shopping cart.
  ///
  void handleItemRem(ProdutoCarrinho item) {
//    Logger(TAG).info("Remove product from the shopping cart");
    cart.remProdutos(item);
    cart.calcular();
    _cart.add(cart);
    return;
  }

  ///
  /// Clears the shopping cart
  ///
  void clearCart() {
    cart.limpar();
  }

  @override
  void dispose() {
    itemAdditionController.close();
    itemSubtractionController.close();
  }
}
