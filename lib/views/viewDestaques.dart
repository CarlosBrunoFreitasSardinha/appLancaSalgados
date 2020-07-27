import 'package:flutter/material.dart';

class Destaques extends StatefulWidget {
  @override
  _DestaquesState createState() => _DestaquesState();
}

class _DestaquesState extends State<Destaques> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "this is a Home",
        style: TextStyle(fontSize: 20, color: Colors.red),
      ),
    );
  }
}
