class ProdutoCarrinho {
  String _idProduto;
  String _titulo;
  String _urlImg;
  double _preco;
  String _descricao;
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
    quantidade = json['quantidade'] != null ? json['quantidade'] : 1;
    subtotal = json['subtotal'] != null ? json['subtotal']+0.0 : preco;
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
