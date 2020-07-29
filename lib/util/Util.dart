

class Util {

  static String moeda(String valor) {

    return "R\$ "+valor.replaceAll(".", ",");
  }
}
