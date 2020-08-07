import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarrinhoService {
  static Future<void> futureCarrinho() async {
    final streamCarrinho = AppModel.to.bloc<CarrinhoBloc>();

    print("VALORRRR  " + AppModel.to.bloc<UserBloc>().usuario.uidUser);
    DocumentSnapshot snapshot = await BdService.recuperarItemsColecaoGenerica(
        "carrinho",
        AppModel.to.bloc<UserBloc>().usuario.uidUser,
        "carrinho",
        "ativo");

    if (snapshot.data != null) {
      Map<String, dynamic> dados = snapshot.data;
      CarrinhoModel cart = CarrinhoModel.fromJson(dados);
      streamCarrinho.cartAddition.add(cart);
    }

    return;
  }

  static Future updateCart({CarrinhoModel cart}) async {
    if (cart?.fechado) {
      await Firestore.instance
          .collection('carrinho')
          .document(AppModel.to
          .bloc<UserBloc>()
          .usuario
          .uidUser)
          .collection('carrinho')
          .document('ativo')
          .setData(cart.toJson());
    } else {
      await Firestore.instance
          .collection('carrinho')
          .document(AppModel.to
          .bloc<UserBloc>()
          .usuario
          .uidUser)
          .collection('carrinho')
          .document('ativo')
          .setData({});
    }
  }
}
