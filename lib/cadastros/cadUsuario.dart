import 'package:applancasalgados/RouteGenerator.dart';
import 'package:applancasalgados/models/usuario.dart';
import 'package:applancasalgados/util/usuarioFireBase.dart';
import 'package:applancasalgados/util/utilFireBase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  String _mensagemErro = "";
  Usuario usuario = Usuario();

  validarCampos(_controllerNome, _controllerEmail, _controllerSenha) {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    String fone = _controllerFone.text;
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
            }
            else {
              setState(() {
                _mensagemErro =
                " Endereço deve ser conter pelo menos 6 caracteres ";
              });
            }
          }
          else {
            setState(() {
              _mensagemErro = " Um Numero telefonico deve ser informado ";
            });
          }

        } else {
          setState(() {
            _mensagemErro = " Senha deve ser conter pelo menos 6 caracteres ";
          });
        }
      } else {
        setState(() {
          _mensagemErro = " Preencha o Email Utilizando @ ";
        });
      }
    } else {
      setState(() {
        _mensagemErro = " Preencha o Nome ";
      });
    }
  }

  _cadastrarUsuario(Usuario user) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(email: user.email, password: user.senha)
        .then((firebaseUser) async {
          usuario.uidUser = firebaseUser.user.uid;
          UtilFirebase.cadastrarDados(
              "usuarios", usuario.uidUser, usuario.toJson());
          UserFirebase.fireLogged = usuario;
          Navigator.pushNamedAndRemoveUntil(
              context, RouteGenerator.HOME, (_) => false);

    }).catchError((onError) {
      print("Erro: " + onError.toString());

      setState(() {
        _mensagemErro =
            "Erro ao cadastrar, verifique as informações e tente Novamente.";
      });

    });
  }

  Future _verificarUsuarioLogado() async {
    if (UserFirebase.logado) {
      Navigator.pushReplacementNamed(context, RouteGenerator.HOME);
    }
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
                    padding: EdgeInsets.only(left: 8, right: 8),
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

                  //Fone
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controllerFone,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Telefone(whatsapp)",
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
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Endereço",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),

                  //senha
                  Padding(
                    padding: EdgeInsets.all(8),
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

                  //msg error
                  Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
