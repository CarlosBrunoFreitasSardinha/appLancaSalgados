class CategoriaProduto {
  String _idCategoria;
  String _descricao;

  CategoriaProduto();


  String get idCategoria => _idCategoria;

  set idCategoria(String value) {
    _idCategoria = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['idCategoria'] = this.idCategoria;
    data['descricao'] = this.descricao;
    return data;
  }

  CategoriaProduto.fromJson(Map<String, dynamic> json) {
    idCategoria = json['idCategoria'];
    descricao = json['descricao'];
  }

}
