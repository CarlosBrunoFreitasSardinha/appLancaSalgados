class ProdutoCarrinho {
  String _idProduto;
  String _titulo;
  String _urlImg;
  String _preco;
  String _descricao;
  String _quantidade;
  String _subtotal;


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
    preco = json['preco'];
    descricao = json['descricao'];
    quantidade = json['quantidade'] != null ? json['quantidade'] : "1";
    subtotal = json['subtotal'] != null ? json['subtotal'] : json['preco'];
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

  String get quantidade => _quantidade;
  set quantidade(String value) {
    _quantidade = value;
  }

  String get subtotal => _subtotal;
  set subtotal(String value) {
    _subtotal = value;
  }
}
