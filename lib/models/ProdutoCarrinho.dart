import 'package:applancasalgados/models/Produto.dart';

class ProdutoCarrinho extends Produto{

  int _quantidade;
  double _subtotal;


  ProdutoCarrinho();


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['idProduto'] = this.idProduto;
    data['titulo'] = this.titulo;
    data['urlImg'] = this.urlImg;
    data['preco'] = this.preco;
    data['descricao'] = this.descricao;
    data['idCategoria'] = this.idCategoria;
    data['tempoPreparo'] = this.tempoPreparo;

    data['quantidade'] = this._quantidade;
    data['subtotal'] = this._subtotal;
    return data;
  }


  ProdutoCarrinho.fromJson(Map<String, dynamic> json) {
    idProduto = json['idProduto'];
    titulo = json['titulo'];
    urlImg = json['urlImg'];
    preco = json['preco']+0.0;
    descricao = json['descricao'];
    idCategoria = json['idCategoria'];
    tempoPreparo = json['tempoPreparo'];

    quantidade = json['quantidade'] != null ? json['quantidade'] : 1;
    subtotal = json['subtotal'] != null ? json['subtotal']+0.0 : preco;
  }

  // ignore: unnecessary_getters_setters
  int get quantidade => _quantidade;

  // ignore: unnecessary_getters_setters
  set quantidade(int value) {
    _quantidade = value;
  }

  // ignore: unnecessary_getters_setters
  double get subtotal => _subtotal;

  // ignore: unnecessary_getters_setters
  set subtotal(double value) {
    _subtotal = value;
  }
}
