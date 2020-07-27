import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:applancasalgados/models/Conversa.dart';
import 'package:applancasalgados/models/mensagem.dart';
import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/models/usuarioFireBase.dart';
import 'package:image_picker/image_picker.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  Firestore bd = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollControllerMensagens = ScrollController();
  Usuario destinatario;
  String idReceptor, urlImagemEnviada;
  bool _subindoImagem = false;

  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem() {
    String textMensagem = _controllerMensagem.text;
    if (textMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuarioEmissor = UserFirebase.fireLogged.uidUser;
      mensagem.idUsuarioReceptor = destinatario.uidUser;
      mensagem.mensagem = textMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      mensagem.salvarMensagem();
      //Salvar conversa
      _salvarConversa(mensagem);
      _controllerMensagem.clear();
    }
  }

  Future _enviarImagem() async {
    File imagemSelecionada;
    imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(UserFirebase.fireLogged.uidUser)
        .child(nomeImagem + ".jpg");

    //Upload da imagem
    StorageUploadTask task = arquivo.putFile(imagemSelecionada);

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuarioEmissor = UserFirebase.fireLogged.uidUser;
    mensagem.idUsuarioReceptor = destinatario.uidUser;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    mensagem.salvarMensagem();
  }

  _salvarConversa(Mensagem msg) {
    //Salvar conversa remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = msg.idUsuarioEmissor;
    cRemetente.idDestinatario = destinatario.uidUser;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = destinatario.nome;
    cRemetente.caminhoFoto = destinatario.urlPerfil;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //Salvar conversa destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = msg.idUsuarioReceptor;
    cDestinatario.idDestinatario = UserFirebase.fireLogged.uidUser;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = destinatario.nome;
    cDestinatario.caminhoFoto = destinatario.urlPerfil;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = bd
        .collection("mensagens")
        .document(UserFirebase.fireLogged.uidUser)
        .collection(destinatario.uidUser)
        .orderBy("envio", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollControllerMensagens
            .jumpTo(_scrollControllerMensagens.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    destinatario = widget.contato;
    _adicionarListenerConversas();
  }

  @override
  Widget build(BuildContext context) {
    idReceptor = destinatario.uidUser;

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TextField(
                    controller: _controllerMensagem,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                        hintText: "Digite uma Mensagem...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)),
                        prefixIcon: _subindoImagem
                            ? CircularProgressIndicator()
                            : IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () {
                              _enviarImagem();
                            })),
                  ))),
          Platform.isIOS
              ? CupertinoButton(
            child: Text("Enviar"),
            onPressed: _enviarMensagem(),
          )
              : FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(Icons.send, color: Colors.white),
            mini: true,
            onPressed: () {
              _enviarMensagem();
            },
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(child: Text("Erro ao carregar os dados!"));
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollControllerMensagens,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera mensagem
                      List<DocumentSnapshot> mensagens =
                      querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);
                      if (UserFirebase.fireLogged.uidUser !=
                          item["idEmissor"]) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                BorderRadius.all(Radius.circular(8))),
                            child: item["tipo"] == "texto"
                                ? Text(
                              item["mensagem"],
                              style: TextStyle(fontSize: 18),
                            )
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }

            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: destinatario.urlPerfil != null
                    ? NetworkImage(destinatario.urlPerfil)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(destinatario.nome),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  stream,
                  caixaMensagem,
                ],
              ),
            )),
      ),
    );
  }
}
