import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UtilService {
  static String moeda(double valor) {
    return "R\$ " + valor.toStringAsFixed(2).replaceAll(".", ",");
  }

  static String formatarData(DateTime date) {
    String menorQueDez(int i) {
      if (i < 10) return '0' + i.toString();
      return i.toString();
    }

    return menorQueDez(date.day) +
        '/' +
        menorQueDez(date.month) +
        '/' +
        date.year.toString() +
        '_' +
        menorQueDez(date.hour) +
        ':' +
        menorQueDez(date.minute);
  }

  static String formatarNumberFone(String n) {
    if (n.length == 11) {
      return "(" +
          n.substring(0, 2) +
          ") " +
          n.substring(2, 7) +
          "-" +
          n.substring(7, 11);
    }
    return n;
  }

  static String formatSimpleNumber(String n) {
    return n
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("-", "")
        .replaceAll(" ", "");
  }

  static bool stringIsNull(String str) {
    if (str == null || str.replaceAll(' ', '') == '') return true;
    return false;
  }

  static bool stringNotIsNull(String str) {
    if (str == null || str.replaceAll(' ', '') == '') return false;
    return true;
  }

  static coverterListStringInMap(List<String> lista) {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    int i = 0;
    lista.forEach((p) {
      map[i.toString()] = p.toString();
      i++;
    });
    return map;
  }

  static coverterMapInListString(Map<String, dynamic> map) {
    final List<String> lista = [];
    map.forEach((key, value) {
      lista.add(value);
    });
    return lista;
  }

  static Widget checkUrl(
      String url, double heigh, double width, BoxFit boxFit) {
    try {
      return Image.network(
        url,
        height: heigh,
        width: width,
        fit: boxFit,
        loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      );
    } catch (e) {
      return Icon(Icons.image);
    }
  }

  static testaUrl(url) async {
    var resp = await new http.Client().get(url);
    return resp.contentLength != 0;
  }
}
