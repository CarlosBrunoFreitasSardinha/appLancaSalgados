class UtilService {
  static String moeda(double valor) {

    return "R\$ "+valor.toStringAsFixed(2).replaceAll(".", ",");
  }

  static String formatarData(DateTime date) {
    String menorQueDez(int i) {
      if (i < 10) return '0' + i.toString();
      return i.toString();
    }

    return menorQueDez(date.day) +
        ' - ' + menorQueDez(date.month) +
        ' - ' + menorQueDez(date.year) +
        ' ' + menorQueDez(date.hour) +
        ':' + menorQueDez(date.minute);
  }

  static bool stringIsNull(String str) {
    if (str == null || str.replaceAll(' ', '') == '') return true;
    return false;
  }

  static bool stringNotIsNull(String str) {
    if (str == null || str.replaceAll(' ', '') == '') return false;
    return true;
  }
}