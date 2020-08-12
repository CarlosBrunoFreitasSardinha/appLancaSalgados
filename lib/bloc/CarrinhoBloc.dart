import 'dart:async';

import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class CarrinhoBloc extends BlocBase {
  static const String TAG = "CarrinhoServiceBloc";

  CarrinhoModel cart = CarrinhoModel();

  /// Sinks
  Sink<ProdutoCarrinhoModel> get addition => itemAdditionController.sink;
  final itemAdditionController = StreamController<ProdutoCarrinhoModel>();

  Sink<ProdutoCarrinhoModel> get substraction => itemSubtractionController.sink;
  final itemSubtractionController = StreamController<ProdutoCarrinhoModel>();

  Sink<CarrinhoModel> get cartAddition => cartAdditionController.sink;
  final cartAdditionController = StreamController<CarrinhoModel>();

  /// Streams
  Stream<CarrinhoModel> get cartStream => _carrinho.stream;
  final _carrinho = BehaviorSubject<CarrinhoModel>();

  CarrinhoBloc() {
    itemAdditionController.stream.listen(adicionarItemCarrinho);
    itemSubtractionController.stream.listen(removerItemCarrinho);
    cartAdditionController.stream.listen(adicionarCarrinho);
  }

  /// Logic for product added to shopping cart.
  void adicionarItemCarrinho(ProdutoCarrinhoModel item) {
    cart.addProdutos(item);
    cart.calcular();
    _carrinho.add(cart);
    alterarCarrinho();
    return;
  }

  /// Logic for product removed from shopping cart.
  void removerItemCarrinho(ProdutoCarrinhoModel item) {
    cart.remProdutos(item);
    cart.calcular();
    _carrinho.add(cart);
    alterarCarrinho();
    return;
  }

  /// Logic for product removed from shopping cart.
  void adicionarCarrinho(CarrinhoModel thisCart) {
    cart = thisCart;
    _carrinho.add(cart);
    return;
  }

  /// Clears the shopping cart
  void clearCart() {
    cart.limpar();
  }

  alterarCarrinho() => BdService.criarItemComIdColecaoGenerica(
      "carrinho",
      AppModel.to.bloc<UserBloc>().usuario.uidUser,
      "carrinho",
      "ativo",
      cart.toJson());

  @override
  void dispose() {
    itemAdditionController.close();
    itemSubtractionController.close();
    cartAdditionController.close();
  }
}
