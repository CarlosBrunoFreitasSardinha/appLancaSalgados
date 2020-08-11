import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/CarrinhoModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'appModel.dart';

class PedidoModel {
  CarrinhoModel _carrinho;
  UsuarioModel _usuario;
  bool _atendido = false;
  String _status = "Solicitado";
  String _formaPagamento = "";
  String _enderecoEntrega;
  double _trocoPara = 0;
  String _tituloPedido = AppModel.to.bloc<UserBloc>().usuario.nome +
      " _ " +
      UtilService.formatarData(DateTime.now());
  String _dataPedido = Timestamp.now().toString();

  PedidoModel();

  void fecharPedido(){
    atendido = true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json["usuario"] = usuario.toJson();
    json["carrinho"] = carrinho.toJson();
    json["status"] = status;
    json["atendido"] = atendido;
    json["formaPagamento"] = formaPagamento;
    json["tituloPedido"] = tituloPedido;
    json["enderecoEntrega"] = enderecoEntrega;
    json["dataPedido"] = dataPedido;
    json["trocoPara"] = trocoPara;

    return json;
  }

  PedidoModel.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    atendido = json["atendido"];
    formaPagamento = json["formaPagamento"];
    tituloPedido = json["tituloPedido"];
    carrinho = CarrinhoModel.fromJson(json["carrinho"]);
    usuario = UsuarioModel.fromJson(json["usuario"]);
    enderecoEntrega = json["enderecoEntrega"];
    dataPedido = json["dataPedido"];
    trocoPara = json["trocoPara"];
  }

  UsuarioModel get usuario => _usuario;

  set usuario(UsuarioModel value) {
    _usuario = value;
  }

  CarrinhoModel get carrinho => _carrinho;

  set carrinho(CarrinhoModel value) {
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

  String get enderecoEntrega => _enderecoEntrega;

  set enderecoEntrega(String value) {
    _enderecoEntrega = value;
  }

  String get dataPedido => _dataPedido;

  set dataPedido(String value) {
    _dataPedido = value;
  }

  double get trocoPara => _trocoPara;

  set trocoPara(double value) {
    _trocoPara = value;
  }

  @override
  String toString() {
    return 'PedidoModel{_carrinho: $_carrinho, _usuario: $_usuario, _atendido: $_atendido, _status: $_status, _formaPagamento: $_formaPagamento, _enderecoEntrega: $_enderecoEntrega, _trocoPara: $_trocoPara, _tituloPedido: $_tituloPedido, _dataPedido: $_dataPedido}';
  }
}
