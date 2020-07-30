import 'package:applancasalgados/models/ProdutoCarrinho.dart';

class Carrinho {
  List<ProdutoCarrinho> produtos = [];
  double total = 0;
  bool fechado = false;

  Carrinho();

  void addProdutos(ProdutoCarrinho p) {
    produtos.add(p);
    calcular();
  }
  void remProdutos(ProdutoCarrinho p) {
    produtos.remove(p);
    calcular();
  }


  void calcular() {
    total = 0;
    produtos.forEach((p) {
      total += (double.parse(p.preco) * int.parse(p.quantidade));
    });
  }


 void limpar(){
   produtos = [];
   total = 0;
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
