import 'package:applancasalgados/models/ProdutoModel.dart';
import 'package:applancasalgados/services/UtilService.dart';

class ProdutoCarrinhoModel extends ProdutoModel {
  int _quantidade;
  double _subtotal;


  ProdutoCarrinhoModel();


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['idProduto'] = this.idProduto;
    data['titulo'] = this.titulo;
    data['urlImg'] = this.urlImg;
    data['preco'] = this.preco;
    data['descricao'] = this.descricao;
    data['idCategoria'] = this.idCategoria;
    data['tempoPreparo'] = this.tempoPreparo;
    data['galeria'] = UtilService.coverterListStringInMap(this.galeria);

    data['quantidade'] = this._quantidade;
    data['subtotal'] = this._subtotal;
    return data;
  }


  ProdutoCarrinhoModel.fromJson(Map<String, dynamic> json) {
    idProduto = json['idProduto'];
    titulo = json['titulo'];
    urlImg = json['urlImg'];
    preco = json['preco']+0.0;
    descricao = json['descricao'];
    idCategoria = json['idCategoria'];
    tempoPreparo = json['tempoPreparo'];
    galeria = json['galeria'] != null
        ? UtilService.coverterMapInListString(json['galeria'])
        : [];

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
