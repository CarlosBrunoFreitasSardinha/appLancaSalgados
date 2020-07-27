class Produto {
  String _idProduto;
  String _titulo;
  String _urlImg;
  String _preco;
  String _descricao;

  String _idCategoria;
  String _tempoPreparo;


  Produto();



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


  Produto.fromJson(Map<String, dynamic> json) {
    idProduto = json['idProduto'];
    titulo = json['titulo'];
    urlImg = json['urlImg'];
    preco = json['preco'];
    descricao = json['descricao'];

    idCategoria = json['idCategoria'];
    tempoPreparo = json['tempoPreparo'];
  }

  String get idProduto => _idProduto;
  set idProduto(String value) {
    _idProduto = value;
  }

  String get titulo => _titulo;
  set titulo(String value) {
    _titulo = value;
  }

  String get urlImg => _urlImg;
  set urlImg(String value) {
    _urlImg = value;
  }

  String get preco => _preco;
  set preco(String value) {
    _preco = value;
  }

  String get descricao => _descricao;
  set descricao(String value) {
    _descricao = value;
  }

  String get tempoPreparo => _tempoPreparo;
  set tempoPreparo(String value) {
    _tempoPreparo = value;
  }

  String get idCategoria => _idCategoria;
  set idCategoria(String value) {
    _idCategoria = value;
  }
}
