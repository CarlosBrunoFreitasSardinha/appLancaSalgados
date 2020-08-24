import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/bloc/UserBloc.dart';
import 'package:applancasalgados/models/AppModel.dart';
import 'package:applancasalgados/models/UsuarioModel.dart';
import 'package:applancasalgados/services/AuthService.dart';
import 'package:flutter/material.dart';

class ViewLogin extends StatefulWidget {
  @override
  _ViewLoginState createState() => _ViewLoginState();
}

class _ViewLoginState extends State<ViewLogin> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  UsuarioModel usuario = UsuarioModel();
  bool visualizarSenha = true;

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

  validarCampos(_controllerEmail, _controllerSenha) {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.length > 5) {
        usuario.senha = senha;
        usuario.email = email.trim();
        _logarUsuario(usuario);
      } else {
        alert("Atenção", "A senha deve ser conter pelo menos 6 caracteres!",
            Colors.red, Colors.black87);
      }
    } else {
      alert("Atenção",
          "Preencha o campo Email com um endereço válido !",
          Colors.red,
          Colors.black87);
    }
  }

  Future<void> _logarUsuario(UsuarioModel user) async {
    if (await AuthService.logar(user)) {
      Navigator.pop(context);
    } else {
      alert("Atenção",
          "Erro ao efetuar Login, verifique as informações e tente novamente!",
          Colors.red,
          Colors.black87);
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
                ],
              ),
            ),
          )),
    );
  }
}
