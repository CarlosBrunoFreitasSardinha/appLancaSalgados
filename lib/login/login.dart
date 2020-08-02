import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:applancasalgados/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail =
      TextEditingController(text: "teste@teste.com");
  TextEditingController _controllerSenha =
      TextEditingController(text: "1234567");
  String _mensagemErro = "";
  Usuario usuario = Usuario();

  validarCampos(_controllerEmail, _controllerSenha) {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.length > 3) {
        usuario.senha = senha;
        usuario.email = email;
        _logarUsuario(usuario);
      } else {
        setState(() {
          _mensagemErro = " Senha deve ser conter mais de 3 caracteres ";
        });
      }
    } else {
      setState(() {
        _mensagemErro = " Preencha o Email Utilizando @ ";
      });
    }
  }

  _logarUsuario(Usuario user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(email: user.email, password: user.senha)
        .then((firebaseUser) async {
      var usuario = await UserFirebase.recuperaDadosUsuario();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Home()),
        ModalRoute.withName('/'),
      );
    }).catchError((onError) {
      print("Erro: " + onError.toString());
      setState(() {
        _mensagemErro =
            "Erro ao efetuar Login, verifique as informações e tente Novamente";
      });
    });
  }

  Future _verificarUsuarioLogado() async {
    print("tela login = " + UserFirebase.logado.toString());
    print("Usuario fire login = " + UserFirebase.fireLogged.toString());
    if (UserFirebase.logado) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _verificarUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  //email
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //senha
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: TextField(
                      controller: _controllerSenha,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Senha",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //botao
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: RaisedButton(
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xffd19c3c),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          validarCampos(
                            _controllerEmail,
                            _controllerSenha,
                          );
                        }),
                  ),
                  Center(
                    child: GestureDetector(
                      child: Text(
                        "Não tem conta, Cadastre-se!",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: (){


                        Navigator.pushNamed(context, RouteGenerator.CAD_USER);
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _mensagemErro,
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
