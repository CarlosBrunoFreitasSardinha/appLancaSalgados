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
}
