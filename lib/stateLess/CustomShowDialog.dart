import 'package:flutter/material.dart';

alertDialogEndereco(BuildContext context) {
  TextEditingController _controllerEndereco;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Endereço de Cadastrado"),
          content: TextField(
            controller: _controllerEndereco,
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Enviar"))
          ],
        );
      });
}

alertDialogFormaPagamento(BuildContext context) {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedRadio = 0;
        return AlertDialog(
          title: Text("Forma de Pagamento"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(4, (int index) {
                  return RadioListTile(
                    title: Text(index.toString()),
                    value: index,
                    groupValue: selectedRadio,
                    onChanged: (int value) {
                      setState(() => selectedRadio = value);
                    },
                  );
                }),
              );
            },
          ),
        );
      });
}
