class Usuario {
  String _uidUser;
  String _nome;
  String _email;
  String _senha;
  String _urlPerfil;
  String _foneContato1;
  bool _isAdm = false;

  Usuario();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uidUser'] = this.uidUser;
    data['nome'] = this.nome;
    data['email'] = this.email;
    data['foneContato1'] = this.foneContato1;
    data['urlPerfil'] = this.urlPerfil;
    data['isAdm'] = this.isAdm;

    return data;
  }

  Usuario.fromJson(Map<String, dynamic> json) {
    _uidUser = json['uidUser'] != null ? json['uidUser'] : "";
    _nome = json['nome'] != null ? json['nome'] : "";
    _senha = json['senha'] != null ? json['senha'] : "";
    _foneContato1 = json['foneContato1'] != null ? json['foneContato1'] : "";
    _urlPerfil = json['urlPerfil'] != null ? json['urlPerfil'] : "";
    _isAdm = json['isAdm'];
  }

  String get urlPerfil => _urlPerfil;

  set urlPerfil(String value) {
    _urlPerfil = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get uidUser => _uidUser;

  set uidUser(String value) {
    _uidUser = value;
  }

  String get foneContato1 => _foneContato1;

  set foneContato1(String value) {
    _foneContato1 = value;
  }

  bool get isAdm => _isAdm;

  set isAdm(bool value) {
    _isAdm = value;
  }
}
