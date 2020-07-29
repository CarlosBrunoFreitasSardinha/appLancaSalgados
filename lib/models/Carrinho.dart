import 'package:applancasalgados/models/Produto.dart';

class Carrinho {
  List<Produto> produtos = [];
  double total = 0;

  Carrinho();

  void addProdutos(Produto p) {
    produtos.add(p);
    calcular();
  }
  void remProdutos(Produto p) {
    produtos.remove(p);
    calcular();
  }


  void calcular() {
    total = 0;
    produtos.forEach((p) {
      total += double.parse(p.preco);
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
      Produto item = Produto.fromJson(value);
      produtos.add(item);
    });
  }

}
