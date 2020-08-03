import 'package:applancasalgados/models/Carrinho.dart';
import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/util/Util.dart';

class Pedido {
  Carrinho _carrinho;
  Usuario _usuario;
  bool _atendido = false;
  String _status = "Solicitado";
  String _formaPagamento;
  String _tituloPedido;

  Pedido();

  void fecharPedido(){
    atendido = true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["usuario"] = usuario.toJson();
    data["carrinho"] = carrinho.toJson();
    data["status"] = status;
    data["atendido"] = atendido;
    data["formaPagamento"] = formaPagamento;
    data["tituloPedido"] =
        usuario.nome + " _ " + Util.formatarData(DateTime.now());
    return data;
  }

  Pedido.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    atendido = json["atendido"];
    formaPagamento = json["formaPagamento"];
    tituloPedido = json["tituloPedido"];
    carrinho = Carrinho.fromJson(json["carrinho"]);
    usuario = Usuario.fromJson(json["usuario"]);
  }

  Usuario get usuario => _usuario;
  set usuario(Usuario value) {
    _usuario = value;
  }

  Carrinho get carrinho => _carrinho;
  set carrinho(Carrinho value) {
    _carrinho = value;
  }

  bool get atendido => _atendido;
  set atendido(bool value) {
    _atendido = value;
  }

  String get status => _status;
  set status(String value) {
    _status = value;
  }

  String get formaPagamento => _formaPagamento;
  set formaPagamento(String value) {
    _formaPagamento = value;
  }

  String get tituloPedido => _tituloPedido;

  set tituloPedido(String value) {
    _tituloPedido = value;
  }
}
