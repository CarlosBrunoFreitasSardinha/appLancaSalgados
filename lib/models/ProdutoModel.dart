class ProdutoModel {
  String _idProduto;
  String _titulo;
  String _urlImg;
  double _preco;
  String _descricao;

  String _idCategoria;
  String _tempoPreparo;

  ProdutoModel();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['idProduto'] = this.idProduto;
    data['titulo'] = this.titulo;
    data['urlImg'] = this.urlImg;
    data['preco'] = this.preco;
    data['descricao'] = this.descricao;

    data['idCategoria'] = this.idCategoria;
    data['tempoPreparo'] = this.tempoPreparo;
    return data;
  }


  ProdutoModel.fromJson(Map<String, dynamic> json) {
    idProduto = json['idProduto'];
    titulo = json['titulo'];
    urlImg = json['urlImg'];
    preco = json['preco'] + 0.0;
    descricao = json['descricao'];

    idCategoria = json['idCategoria'];
    tempoPreparo = json['tempoPreparo'];
  }

  // ignore: unnecessary_getters_setters
  String get idProduto => _idProduto;

  // ignore: unnecessary_getters_setters
  set idProduto(String value) {
    _idProduto = value;
  }

  // ignore: unnecessary_getters_setters
  String get titulo => _titulo;

  // ignore: unnecessary_getters_setters
  set titulo(String value) {
    _titulo = value;
  }

  // ignore: unnecessary_getters_setters
  String get urlImg => _urlImg;

  // ignore: unnecessary_getters_setters
  set urlImg(String value) {
    _urlImg = value;
  }

  // ignore: unnecessary_getters_setters
  double get preco => _preco;

  // ignore: unnecessary_getters_setters
  set preco(double value) {
    _preco = value;
  }

  // ignore: unnecessary_getters_setters
  String get descricao => _descricao;

  // ignore: unnecessary_getters_setters
  set descricao(String value) {
    _descricao = value;
  }

  // ignore: unnecessary_getters_setters
  String get tempoPreparo => _tempoPreparo;

  // ignore: unnecessary_getters_setters
  set tempoPreparo(String value) {
    _tempoPreparo = value;
  }

  // ignore: unnecessary_getters_setters
  String get idCategoria => _idCategoria;

  // ignore: unnecessary_getters_setters
  set idCategoria(String value) {
    _idCategoria = value;
  }
}
