import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/FormaPagamentoModel.dart';
import 'package:applancasalgados/models/PedidoModel.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemOne.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewPedido extends StatefulWidget {
  final PedidoModel pedido;

  ViewPedido(this.pedido);

  @override
  _ViewPedidoState createState() => _ViewPedidoState();
}

class _ViewPedidoState extends State<ViewPedido>
    with SingleTickerProviderStateMixin {
  Firestore bd = Firestore.instance;
  String coletionPai, documentPai, subColection, subDocument;
  String strPedido = "pedidos";
  ScrollController _scrollControllerMensagens = ScrollController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  TextEditingController _controllerEndereco = TextEditingController(
      text: AppModel.to.bloc<UserBloc>().usuario.endereco);
  TextEditingController _controllerTroco = TextEditingController();
  String bdCarrinho = "carrinho";
  var selectedItem;
  List<FormaPagamentoModel> options = [];

  _initilizer() {
    coletionPai = "pedidos";
    documentPai = AppModel.to
        .bloc<UserBloc>()
        .usuario
        .uidUser;
    subColection = "pedidos";
    _controllerEndereco.text = widget.pedido.enderecoEntrega;
    selectedItem = widget.pedido.formaPagamento;
  }

  Future _salvarPedido() {
    if (_controllerEndereco.text.isNotEmpty &&
        widget.pedido.formaPagamento.isNotEmpty) {
      widget.pedido.carrinho.fecharPedido();
      widget.pedido.trocoPara =
          _controllerTroco.text == "" ? 0 : double.parse(_controllerTroco.text);

      BdService.criarItemAutoIdColecaoGenerica(
          strPedido, documentPai, strPedido, widget.pedido.toJson());
      widget.pedido.carrinho.limpar();
      BdService.criarItemComIdColecaoGenerica(bdCarrinho, documentPai,
          bdCarrinho, "ativo", widget.pedido.carrinho.toJson());

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 3);
    }
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = bd
        .collection("formaPagamento")
        .orderBy("id", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    var stream = Expanded(
      child: ListView.builder(
          controller: _scrollControllerMensagens,
          itemCount: widget.pedido.carrinho.produtos.length,
          itemBuilder: (context, indice) {
            String valores = UtilService.moeda(
                    widget.pedido.carrinho.produtos[indice].preco) +
                " X " +
                widget.pedido.carrinho.produtos[indice].quantidade.toString() +
                " = " +
                UtilService.moeda(
                    widget.pedido.carrinho.produtos[indice].subtotal);

            return Padding(
                padding: EdgeInsets.all(3),
                child: GestureDetector(
                    onTap: () {
//                      Navigator.pushNamed( context, RouteGenerator.PRODUTO, arguments: produto);
                    },
                    child: CustomListItemOne(
                      title: widget.pedido.carrinho.produtos[indice].titulo,
                      subtitle:
                          widget.pedido.carrinho.produtos[indice].descricao,
                      preco: valores,
                      color: Colors.white,
                      radius: 5,
                    )));
          }),
    );

    var streamCategoria = StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            const Text("Carregando...");
          else {
            List<DropdownMenuItem> currencyItems = [];
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot snap = snapshot.data.documents[i];
              options.add(FormaPagamentoModel.fromJson(snap.data));

              currencyItems.add(
                DropdownMenuItem(
                  child: Text(
                    snap.data["descricao"],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffd19c3c)),
                  ),
                  value: "${snap.data["descricao"]}",
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 4, 8, 4),
                  child: DropdownButton(
                      underline: SizedBox(),
                      items: currencyItems,
                      onChanged: (currencyValue) {
                        setState(() {
                          selectedItem = currencyValue;
                          widget.pedido.formaPagamento =
                              currencyValue.toString();
                        });
                      },
                      value: selectedItem,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Selecione a Forma de Pagamento!",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffd19c3c)),
                        ),
                      )),
                ),
              ),
            );
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.pedido.usuario.urlPerfil != null
                    ? NetworkImage(widget.pedido.usuario.urlPerfil)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(widget.pedido.usuario.nome),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/background.jpg"),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Endereço de Entrega",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: _controllerEndereco,
                  maxLines: 3,
                  maxLength: 60,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12, right: 25),
                          child: Icon(
                            Icons.home,
                          )),
                      hintText: "Endereço de Entrega",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              ),
              streamCategoria,
              selectedItem == "Dinheiro"
                  ? Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: _controllerTroco,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Troco Para: ",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              )
                  : SizedBox(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Produtos",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              stream,
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(width: 1, color: Colors.grey),
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              border: Border.all(width: 1, color: Colors.grey),
                              color: Color(0xffd19c3c)),
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.restaurant),
                                  color: Colors.white,
                                  onPressed: () {},
                                ),
                                Text('Finalizar Pedido',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 19.0,
                                        color: Colors.white)),
                              ],
                            ),
                          )),
                      onPressed: () {
                        _salvarPedido();
//                    Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Total: " + UtilService.moeda(widget.pedido.carrinho
                            .total),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
