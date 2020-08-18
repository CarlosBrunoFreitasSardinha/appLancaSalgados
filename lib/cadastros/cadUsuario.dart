import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/models/UsuarioModel.dart';
import 'package:applancasalgados/services/BdService.dart';
import 'package:applancasalgados/services/NumberFormatService.dart';
import 'package:applancasalgados/services/UtilService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroUsuario extends StatefulWidget {
  @override
  _CadastroUsuarioState createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  //Controladores
  TextEditingController _controllerNome = TextEditingController(text: "Tester");
  TextEditingController _controllerEmail =
      TextEditingController(text: "teste@teste.com");
  TextEditingController _controllerEndereco =
      TextEditingController(text: "Rua Teste, N 1, Centro, Fatima-to");
  TextEditingController _controllerFone =
      TextEditingController(text: "63 9 9262 0510");
  TextEditingController _controllerSenha =
      TextEditingController(text: "1234567");
  UsuarioModel usuario = UsuarioModel();
  bool visualizarSenha = true;
  final _mobileFormatter = NumberTextInputFormatterService();

  validarCampos(_controllerNome, _controllerEmail, _controllerSenha) {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    String fone = UtilService.formatSimpleNumber(_controllerFone.text);
    String endereco = _controllerEndereco.text;

    if (nome.length >= 3) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.length > 5) {
          if (fone.isNotEmpty) {
            if (endereco.length > 6) {
              usuario.senha = senha;
              usuario.nome = nome;
              usuario.email = email;
              usuario.foneContato1 = fone;
              usuario.endereco = endereco;

              _cadastrarUsuario(usuario);
            } else {
              alert(
                  "Atenção",
                  "Endereço deve ser conter pelo menos 6 caracteres!",
                  Colors.red,
                  Colors.black87);
            }
          } else {
            alert("Atenção",
                "Um Número telefônico deve ser informado!",
                Colors.red,
                Colors.black87);
          }
        } else {
          alert("Atenção",
              "Senha deve ser conter pelo menos 6 caracteres!",
              Colors.red,
              Colors.black87);
        }
      } else {
        alert("Atenção",
            "Um email válido deve conter @",
            Colors.red,
            Colors.black87);
      }
    } else {
      alert("Atenção",
          "O Nome deve ser Informado!",
          Colors.red,
          Colors.black87);
    }
  }

  _cadastrarUsuario(UsuarioModel user) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(email: user.email, password: user.senha)
        .then((firebaseUser) async {
          usuario.uidUser = firebaseUser.user.uid;
      BdService.insertDocumentInColection(
          "usuarios", usuario.uidUser, usuario.toJson());
      AppModel.to.bloc<UserBloc>().usuario = usuario;
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }).catchError((onError) {
      print("Erro: " + onError.toString());
      alert("Atenção",
          "Erro ao cadastrar, verifique as informações e tente Novamente.!",
          Colors.red,
          Colors.black87);

    });
  }

  Future _verificarUsuarioLogado() async {
    if (AppModel.to.bloc<UserBloc>().isLogged) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME,
          arguments: 0);
    }
  }

  alert(String titulo, String msg, Color colorHead, Color colorBody) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorHead
              ),),
            content: Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: colorBody
                )),
          );
        });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Usuário"),
      ),
      body: Container(
          decoration: BoxDecoration(color: Color(0xff5c3838)),
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //logo
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "imagens/logo.png",
                      width: 200,
                      height: 150,
                    ),
                  ),

                  //nome
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerNome,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Nome",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),


                  //email
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Material(
                      elevation: 7,
                      borderRadius: BorderRadius.circular(10),
                      child: TextFormField(
                        controller: _controllerEmail,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Enter Email",
                            contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                            hintStyle: TextStyle(color: Colors.grey[400],
                                fontSize: 20),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 12, right: 25),
                                child: Icon(Icons.person_outline,)
                            )),
                      ),
                    ),
                  ),


                  //Contato
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerFone,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                      style: TextStyle(fontSize: 20),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        _mobileFormatter,
                      ],
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 12, right: 25),
                              child: Icon(
                                Icons.phone,
                              )),
                          hintText: "Telefone(Whatsapp)",
                          counterStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //Endereco
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerEndereco,
                      autofocus: true,
                      maxLines: 3,
                      maxLength: 60,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.home),
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Endereço",
                          filled: true,
                          fillColor: Colors.white,
                          counterStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //senha
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Material(
                      elevation: 7,
                      borderRadius: BorderRadius.circular(10),
                      child: TextFormField(
                        controller: _controllerSenha,
                        style: TextStyle(fontSize: 20),
                        obscureText: visualizarSenha,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Enter Senha",
                            contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                            hintStyle: TextStyle(color: Colors.grey[400],
                                fontSize: 20),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 12, right: 12),
                                child: IconButton(icon: Icon(
                                  Icons.help_outline,
                                  color: Colors.grey[400],
                                ),
                                    onPressed: () {
                                      setState(() {
                                        visualizarSenha = !visualizarSenha;
                                      });
                                    })),
                            prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 12, right: 25),
                                child: Icon(
                                  Icons.lock_outline,
                                ))),
                      ),
                    ),
                  ),

                  //botao
                  Padding(
                    padding: EdgeInsets.only(top: 32, bottom: 10),
                    child: RaisedButton(
                        child: Text(
                          "Cadastrar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          validarCampos(
                            _controllerNome,
                            _controllerEmail,
                            _controllerSenha,
                          );
                        }),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
