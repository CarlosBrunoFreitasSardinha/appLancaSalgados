import 'package:applancasalgados/cadastros/cadCategoria.dart';
import 'package:applancasalgados/cadastros/cadFormaPagamento.dart';
import 'package:applancasalgados/cadastros/cadProdutos.dart';
import 'package:applancasalgados/cadastros/cadUsuario.dart';
import 'package:applancasalgados/login/login.dart';
import 'package:applancasalgados/login/recuperarSenha.dart';
import 'package:applancasalgados/views/teste.dart';
import 'package:applancasalgados/views/viewCardapio.dart';
import 'package:applancasalgados/views/viewCarrinho.dart';
import 'package:applancasalgados/views/viewConfiguracoes.dart';
import 'package:applancasalgados/views/viewDestaques.dart';
import 'package:applancasalgados/views/viewHome.dart';
import 'package:applancasalgados/views/viewPedido.dart';
import 'package:applancasalgados/views/viewPedidos.dart';
import 'package:applancasalgados/views/viewPerfil.dart';
import 'package:applancasalgados/views/viewProduto.dart';
import 'package:applancasalgados/views/viewSplashScreen.dart';
import 'package:flutter/material.dart';


class RouteGenerator{
  static const String BASE = "/";

  static const String HOME = "/home";
  static const String LOGIN = "/login";
  static const String RECP = "/recuperarSenha";

  static const String DESTAQUES = "/viewDestaques";
  static const String CARDAPIO = "/viewCardapio";
  static const String CARRINHO = "/viewCarrinho";
  static const String PERFIL = "/viewPerfil";
  static const String PRODUTO = "/viewProduto";
  static const String PEDIDO = "/viewPedido";
  static const String PEDIDOS = "/viewPedidos";

  static const String CAD_USER = "/cadastro";
  static const String CAD_CATEGORIA = "/cadCategoria";
  static const String CAD_FORMAPAGAMENTO = "/cadFormaPagamento";
  static const String CAD_PRODUTOS = "/cadProdutos";


  static const String CONFIG = "/configuracoes";
//  static const String MSGS = "/mensagens";
  static const String TESTE = "/testes";


  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case BASE: return MaterialPageRoute(builder: (_) => SplashScreen());
      case HOME:
        return MaterialPageRoute(builder: (_) => Home(args));
      case LOGIN: return MaterialPageRoute(builder: (_) => Login());
      case RECP: return MaterialPageRoute(builder: (_) => ResetPasswordView());

      case DESTAQUES: return MaterialPageRoute(builder: (_) => Destaques());
      case CARDAPIO: return MaterialPageRoute(builder: (_) => Cardapio());
      case CARRINHO: return MaterialPageRoute(builder: (_) => ViewCarrinho());
      case PERFIL: return MaterialPageRoute(builder: (_) => ViewPerfil());
      case PRODUTO: return MaterialPageRoute(builder: (_) => ViewProduto(args));
      case PEDIDOS:
        return MaterialPageRoute(builder: (_) => ViewPedidos());
      case PEDIDO:
        return MaterialPageRoute(builder: (_) => ViewPedido(args));

      case CAD_USER: return MaterialPageRoute(builder: (_) => CadastroUsuario());
      case CAD_CATEGORIA: return MaterialPageRoute(builder: (_) => CadastroCategoriaProdutos());
      case CAD_FORMAPAGAMENTO:
        return MaterialPageRoute(builder: (_) => CadastroFormaPagamento());
      case CAD_PRODUTOS: return MaterialPageRoute(builder: (_) => CadastroProdutos());

      case CONFIG: return MaterialPageRoute(builder: (_) => Configuracoes());

      case TESTE:
        return MaterialPageRoute(builder: (_) => pagCarrinhoStream());

      default: _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
     builder: (_){
       return Scaffold(
         appBar: AppBar(title: Text("Tela não Encontrada!"),),
         body: Center(child: Text("Tela não Encontrada!"),),
       );
     }
   );
  }

}