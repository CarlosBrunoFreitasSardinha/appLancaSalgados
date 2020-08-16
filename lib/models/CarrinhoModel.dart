import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';

class CarrinhoModel {
  List<ProdutoCarrinhoModel> produtos = [];
  double total = 0;
  bool _fechado = false;

  CarrinhoModel();

  void addProdutos(ProdutoCarrinhoModel p) {
    int posicao = verificaitem(p);
    if (posicao != -1) {
      produtos[posicao].quantidade = p.quantidade;
      produtos[posicao].subtotal = p.subtotal;
    } else {
      produtos.add(p);
    }
    calcular();
  }

  void remProdutos(ProdutoCarrinhoModel p) {
    produtos.remove(p);
    calcular();
  }

  int verificaitem(ProdutoCarrinhoModel p) {
    for (int i = 0; i < produtos.length; i++) {
      if (produtos[i].idProduto == p.idProduto) {
        return i;
      }
    }
    return -1;
  }

  void calcular() {
    total = 0;
    produtos.forEach((p) {
      total += (p.preco * p.quantidade);
    });
  }

  void limpar() {
    produtos = [];
    total = 0;
    fechado = false;
  }

  void fecharPedido(){
    fechado = true;
  }

  // ignore: unnecessary_getters_setters
  bool get fechado => _fechado;

  // ignore: unnecessary_getters_setters
  set fechado(bool value) {
    _fechado = value;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    int i = 0;
    produtos.forEach((p) {
      data[i.toString()] = p.toJson();
      i++;
    });
    return {
      "total": this.total.toStringAsFixed(2),
      "produtos": data,
      "fechado": fechado
    };
  }

  CarrinhoModel.fromJson(Map<String, dynamic> json) {
    total = double.parse(json["total"]);
    fechado = json["fechado"];

    json["produtos"].forEach((key, value) {
      ProdutoCarrinhoModel item = ProdutoCarrinhoModel.fromJson(value);
      produtos.add(item);
    });
  }

}
