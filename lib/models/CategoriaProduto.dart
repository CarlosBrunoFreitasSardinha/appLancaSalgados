class CategoriaProduto {
  String _idCategoria;
  String _descricao;

  CategoriaProduto();


  // ignore: unnecessary_getters_setters
  String get idCategoria => _idCategoria;

  // ignore: unnecessary_getters_setters
  set idCategoria(String value) {
    _idCategoria = value;
  }

  // ignore: unnecessary_getters_setters
  String get descricao => _descricao;

  // ignore: unnecessary_getters_setters
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
