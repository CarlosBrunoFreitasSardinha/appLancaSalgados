import 'dart:async';

import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/CarrinhoBloc.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/models/FormaPagamentoModel.dart';
import 'package:applancasalgados/models/PedidoModel.dart';
import 'package:applancasalgados/models/ProdutoCarrinhoModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:applancasalgados/stateLess/CustomListItemOne.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ViewPedido extends StatefulWidget {
  final PedidoModel pedido;

  ViewPedido(this.pedido);

  @override
  _ViewPedidoState createState() => _ViewPedidoState();
}

class _ViewPedidoState extends State<ViewPedido>
    with SingleTickerProviderStateMixin {
  final blocUsuario = AppModel.to.bloc<UserBloc>();
  final blocCarrinho = AppModel.to.bloc<CarrinhoBloc>();

  TextEditingController _controllerEndereco = TextEditingController();
  TextEditingController _controllerTroco = TextEditingController();

  var selectedItem;

  List<FormaPagamentoModel> options = [];
  List<DropdownMenuItem> currencyItems = [];

  _initilizer() {
    _controllerEndereco.text = widget.pedido.enderecoEntrega;
    if (widget.pedido.formaPagamento != "") {
      _controllerTroco.text = widget.pedido.trocoPara.toString();
      selectedItem = widget.pedido.formaPagamento;
    }
  }

  alert(String titulo, String msg, Color colorHead, Color colorBody) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: colorHead),
            ),
            content: Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: colorBody)),
          );
        });
  }

  _obterIndice() async {
    QuerySnapshot json =
        await BdService.getSubColection("indices", "oneSignal", "oneSignal");
    json.documents.forEach((element) {
      enviarNotificacao("Um novo pedido em aberto!", element["aparelho"]);
    });
  }

  enviarNotificacao(String msg, String destinatario) async {
    await OneSignal.shared.postNotification(
      OSCreateNotification(
        playerIds: [destinatario],
        content: msg,
        heading: "Nova mensagem",
      ),
    );
  }

  _salvarPedido() async {
    _obterIndice();
    widget.pedido.carrinho.fecharPedido();
    blocCarrinho.cart.fecharPedido();
    widget.pedido.idCelularSolicitante = blocUsuario.playId;

    widget.pedido.trocoPara = _controllerTroco.text == ""
          ? 0
          : double.parse(_controllerTroco.text.replaceAll(',', '.'));

    BdService.insertDocumentInColection("pedidos", "", widget.pedido.toJson());

    widget.pedido.carrinho.limpar();
      blocCarrinho.cart.limpar();


    BdService.insertWithIdDocumentInSubColection(
          "carrinho", blocUsuario.usuario.uidUser,
          "carrinho", "ativo", widget.pedido.carrinho.toJson());

      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 3);
  }

  verificaPedido() {
    if (UtilService.stringNotIsNull(_controllerEndereco.text)) {
      if (UtilService.stringNotIsNull(widget.pedido.formaPagamento)) {
        _salvarPedido();
      }
      else {
        alert("Atenção",
            "A Forma de Pagamento Não Foi Informada!",
            Colors.red,
            Colors.black87);
      }
    }
    else {
      alert("Atenção",
          "O Endereço Não Foi Informado!",
          Colors.red,
          Colors.black87);
    }
  }

  Future<List<FormaPagamentoModel>> adicionarListenerFormaPagamento() async {
    Firestore bd = Firestore.instance;
    QuerySnapshot querySnapshot = await bd
        .collection("formaPagamento")
        .orderBy("id", descending: false).getDocuments();

    for (int i = 0; i < querySnapshot.documents.length; i++) {
      DocumentSnapshot snap = querySnapshot.documents[i];
      options.add(FormaPagamentoModel.fromJson(snap.data));

      currencyItems.add(
        DropdownMenuItem(
          child: Text(
            snap.data["descricao"],
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffd19c3c)),
          ),
          value: "${snap.data["descricao"]}",
        ),
      );
      setState(() {
        currencyItems;
      });
    }
    return options;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initilizer();
    adicionarListenerFormaPagamento();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/background.jpg"),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),

                    //dados Pessoais do cliente
                    Card(
                      child: ListTile(
                        title: Text(
                          "Cliente: " + widget.pedido.usuario.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xffd19c3c)),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(bottom: 5, left: 24),
                          child: Text(
                            "Telefone: " + widget.pedido.usuario.foneContato1,
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xff006400),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    //Espacamento entre dados cliente e endereco
                    SizedBox(
                      height: 8,
                    ),

                    //textField endereco de entrega
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        enabled: !widget.pedido.carrinho.fechado,
                        controller: _controllerEndereco,
                        maxLines: 3,
                        maxLength: 60,
                        keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                            prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 12, right: 25),
                                child: Icon(
                                  Icons.home,
                                )),
                            hintText: "Endereço de Entrega",
                            counterStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ),

                    //forma de pagamento
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child:
                        !widget.pedido.carrinho.fechado
                            ? Padding(padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
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
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffd19c3c)),
                                ),
                              )),)

                            : Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Text(
                            selectedItem,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme
                                    .of(context)
                                    .accentColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,),),
                      ),
                    ),

                //forma pagamento se dinheiro
                    selectedItem == "Dinheiro"
                        ? Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        enabled: !widget.pedido.carrinho.fechado,
                        controller: _controllerTroco,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.fromLTRB(24, 16, 32, 16),
                            hintText: "Troco Para ",
                            prefix: Text("R\$ "),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    )
                        : SizedBox(),

                    //listagem de produtos
                    Padding(
                      padding: EdgeInsets.only(bottom: 15, top: 5),
                      child: Card(
                        child: ExpansionTile(
                            backgroundColor: Colors.grey[200],
                            title: Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
                              child: Text(
                                "Produtos",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme
                                        .of(context)
                                        .accentColor,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            children: getProdutos()),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          border: Border.all(width: 1, color: Colors.grey[300]),
                          color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          !widget.pedido.carrinho.fechado
                              ? FlatButton(
                            padding: EdgeInsets.all(0),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)),
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                    color: Color(0xffd19c3c)),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16, left: 6),
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.restaurant),
                                        color: Colors.white,
                                        onPressed: () {},
                                      ),
                                        Text('Finalizar',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 19.0,
                                              color: Colors.white)),
                                    ],
                                  ),
                                )),
                            onPressed: () {
                              verificaPedido();
                              //                    Navigator.pop(context);
                            },
                          )
                              : SizedBox(),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Total: " +
                                  UtilService.moeda(
                                      widget.pedido.carrinho.total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
          ),
        )),
      ),
    );
  }

  List<Widget> getProdutos() {
    List<Widget> list = [];

    for (ProdutoCarrinhoModel p in widget.pedido.carrinho.produtos) {
      String valores = UtilService.moeda(p.preco) +
          " X " +
          p.quantidade.toString() +
          " = " +
          UtilService.moeda(p.subtotal);
      list.add(Padding(
          padding: EdgeInsets.all(3),
          child: CustomListItemOne(
            title: p.titulo,
            subtitle: p.descricao,
            preco: valores,
            color: Colors.white,
            radius: 5,
          )));
    }
    return list;
  }
}
