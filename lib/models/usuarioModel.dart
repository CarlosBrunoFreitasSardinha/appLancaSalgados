class UsuarioModel {
  String _uidUser;
  String _nome;
  String _email;
  String _senha;
  String _urlPerfil;
  String _foneContato1;
  String _endereco;
  bool _isAdm = false;

  UsuarioModel();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uidUser'] = this.uidUser;
    data['nome'] = this.nome;
    data['email'] = this.email;
    data['foneContato1'] = this.foneContato1;
    data['endereco'] = this.endereco;
    data['urlPerfil'] = this.urlPerfil;
    data['isAdm'] = this.isAdm;

    return data;
  }

  UsuarioModel.fromJson(Map<String, dynamic> json) {
    _uidUser = json['uidUser'] != null ? json['uidUser'] : "";
    _nome = json['nome'] != null ? json['nome'] : "";
    _senha = json['senha'] != null ? json['senha'] : "";
    _email = json['email'] != null ? json['email'] : "";
    _foneContato1 = json['foneContato1'] != null ? json['foneContato1'] : "";
    _endereco = json['endereco'] != null ? json['endereco'] : "";
    _urlPerfil = json['urlPerfil'] != null ? json['urlPerfil'] : "";
    _isAdm = json['isAdm'];
  }

  // ignore: unnecessary_getters_setters
  bool get isAdm => _isAdm;

  // ignore: unnecessary_getters_setters
  set isAdm(bool value) {
    _isAdm = value;
  }

  // ignore: unnecessary_getters_setters
  String get foneContato1 => _foneContato1;

  // ignore: unnecessary_getters_setters
  set foneContato1(String value) {
    _foneContato1 = value;
  }

  // ignore: unnecessary_getters_setters
  String get urlPerfil => _urlPerfil;

  // ignore: unnecessary_getters_setters
  set urlPerfil(String value) {
    _urlPerfil = value;
  }

  // ignore: unnecessary_getters_setters
  String get senha => _senha;

  // ignore: unnecessary_getters_setters
  set senha(String value) {
    _senha = value;
  }

  // ignore: unnecessary_getters_setters
  String get email => _email;

  // ignore: unnecessary_getters_setters
  set email(String value) {
    _email = value;
  }

  // ignore: unnecessary_getters_setters
  String get nome => _nome;

  // ignore: unnecessary_getters_setters
  set nome(String value) {
    _nome = value;
  }

  // ignore: unnecessary_getters_setters
  String get uidUser => _uidUser;

  // ignore: unnecessary_getters_setters
  set uidUser(String value) {
    _uidUser = value;
  }

  // ignore: unnecessary_getters_setters
  String get endereco => _endereco;

  // ignore: unnecessary_getters_setters
  set endereco(String value) {
    _endereco = value;
  }

  @override
  String toString() {
    return 'Usuario{_uidUser: $_uidUser, _nome: $_nome, _email: $_email, _senha: $_senha, _urlPerfil: $_urlPerfil, _foneContato1: $_foneContato1, _endereco: $_endereco, _isAdm: $_isAdm}';
  }
}
