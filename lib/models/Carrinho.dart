import 'package:applancasalgados/models/ProdutoCarrinho.dart';

class Carrinho {
  List<ProdutoCarrinho> produtos = [];
  double total = 0;
  bool _fechado = false;

  Carrinho();

  void addProdutos(ProdutoCarrinho p) {
    int posicao = verificaitem(p);
    if (posicao != -1) {
      produtos[posicao].quantidade = produtos[posicao].quantidade +p.quantidade;
      produtos[posicao].subtotal = produtos[posicao].subtotal + p.subtotal;
    } else {
      produtos.add(p);
    }
    calcular();
  }

  void remProdutos(ProdutoCarrinho p) {

    if (p.quantidade <= 0) {
      produtos.remove(p);
    }
    else{
      int i = verificaitem(p);
      produtos[i].quantidade = p.quantidade;
      produtos[i].subtotal = p.subtotal;
    }
    calcular();
  }

  int verificaitem(ProdutoCarrinho p){
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
  }
  void fecharPedido(){
    fechado = true;
  }


  bool get fechado => _fechado;

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
    return {"total": this.total.toStringAsFixed(2), "produtos": data};
  }

  Carrinho.fromJson(Map<String, dynamic> json) {
    total = double.parse(json["total"]);

    json["produtos"].forEach((key, value) {
      ProdutoCarrinho item = ProdutoCarrinho.fromJson(value);
      produtos.add(item);
    });
  }

}
