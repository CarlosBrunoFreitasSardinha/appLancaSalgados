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
  String _tituloPedido =
      AppModel.to.bloc<UserBloc>().usuario.nome.substring(0, 9) +
          "..._" +
          UtilService.formatarData(DateTime.now());
  String _dataPedido = Timestamp.now().toString();
  String _idCelularSolicitante = "";

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
    json["idCelularSolicitante"] = idCelularSolicitante;

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
    idCelularSolicitante = json["idCelularSolicitante"];
  }

  // ignore: unnecessary_getters_setters
  UsuarioModel get usuario => _usuario;

  // ignore: unnecessary_getters_setters
  set usuario(UsuarioModel value) {
    _usuario = value;
  }

  // ignore: unnecessary_getters_setters
  CarrinhoModel get carrinho => _carrinho;

  // ignore: unnecessary_getters_setters
  set carrinho(CarrinhoModel value) {
    _carrinho = value;
  }

  // ignore: unnecessary_getters_setters
  bool get atendido => _atendido;

  // ignore: unnecessary_getters_setters
  set atendido(bool value) {
    _atendido = value;
  }

  // ignore: unnecessary_getters_setters
  String get status => _status;

  // ignore: unnecessary_getters_setters
  set status(String value) {
    _status = value;
  }

  // ignore: unnecessary_getters_setters
  String get formaPagamento => _formaPagamento;

  // ignore: unnecessary_getters_setters
  set formaPagamento(String value) {
    _formaPagamento = value;
  }

  // ignore: unnecessary_getters_setters
  String get tituloPedido => _tituloPedido;

  // ignore: unnecessary_getters_setters
  set tituloPedido(String value) {
    _tituloPedido = value;
  }

  // ignore: unnecessary_getters_setters
  String get enderecoEntrega => _enderecoEntrega;

  // ignore: unnecessary_getters_setters
  set enderecoEntrega(String value) {
    _enderecoEntrega = value;
  }

  // ignore: unnecessary_getters_setters
  String get dataPedido => _dataPedido;

  // ignore: unnecessary_getters_setters
  set dataPedido(String value) {
    _dataPedido = value;
  }

  // ignore: unnecessary_getters_setters
  double get trocoPara => _trocoPara;

  // ignore: unnecessary_getters_setters
  set trocoPara(double value) {
    _trocoPara = value;
  }

  // ignore: unnecessary_getters_setters
  String get idCelularSolicitante => _idCelularSolicitante;

  // ignore: unnecessary_getters_setters
  set idCelularSolicitante(String value) {
    _idCelularSolicitante = value;
  }

  @override
  String toString() {
    return 'PedidoModel{_carrinho: $_carrinho, _usuario: $_usuario, _atendido: $_atendido, _status: $_status, _formaPagamento: $_formaPagamento, _enderecoEntrega: $_enderecoEntrega, _trocoPara: $_trocoPara, _tituloPedido: $_tituloPedido, _dataPedido: $_dataPedido, _idCelularSolicitante: $_idCelularSolicitante}';
  }
}
