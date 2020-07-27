import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:applancasalgados/models/usuario.dart';
import '';

  String validarCampos(_controllerNome, _controllerEmail, _controllerSenha){
  String nome = _controllerNome.text;
  String email = _controllerEmail.text;
  String senha = _controllerSenha.text;

  if(nome.length >=3){
    if(email.isNotEmpty && email.contains("@")){
      if(senha.length >3){
      }
      else{
          return " Senha deve ser conter mais de 3 caracteres ";
      }
    }
    else{
        return " Preencha o Email Utilizando @ ";
    }
  }
  else{
    return" Preencha o Nome ";
  }
 return "";
}

  cadastrarUsuario(usuarioCadastrado){
    Usuario usuario = Usuario();
    FirebaseAuth auth = FirebaseAuth.instance;
  }