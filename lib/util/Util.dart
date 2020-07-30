

class Util {

  static String moeda(double valor) {

    return "R\$ "+valor.toStringAsFixed(2).replaceAll(".", ",");
  }
}
