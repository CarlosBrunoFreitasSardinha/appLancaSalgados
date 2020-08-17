import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/appModel.dart';
import 'package:applancasalgados/models/usuarioModel.dart';
import 'package:applancasalgados/services/AuthService.dart';
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
  UsuarioModel usuario = UsuarioModel();
  bool visualizarSenha = true;

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

  Future<void> _logarUsuario(UsuarioModel user) async {
    if (await AuthService.logar(user)) {
      Navigator.pop(context);
    } else {
        setState(() {
          _mensagemErro =
              "Erro ao efetuar Login, verifique as informações e tente Novamente";
        });
      }
    return;
  }

  _verificarUsuarioLogado() {
    if (AppModel.to.bloc<UserBloc>().isLogged) {
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
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('imagens/background.jpg'),
                  fit: BoxFit.cover)),
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
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
                    child: RaisedButton(
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Theme
                            .of(context)
                            .accentColor,
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
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: GestureDetector(
                      child: Text(
                        "Esqueceu sua senha?",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.RESET);
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
