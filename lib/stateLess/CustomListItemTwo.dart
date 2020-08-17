import 'package:flutter/material.dart';

class _ArticleDescription extends StatelessWidget {
  _ArticleDescription(
      {Key key,
      this.title,
      this.subtitle,
      this.preco,
      this.quantidade,
      this.subTotal})
      : super(key: key);

  final String title;
  final String subtitle;
  final String preco;
  final String quantidade;
  final String subTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xffd19c3c)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 3.0, left: 4),
                child: Text(
                  '$subtitle',
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '$preco',
                style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xff006400),
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'x $quantidade',
                style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xff006400),
                    fontWeight: FontWeight.bold),
              ),
              Text(
                ' = $subTotal',
                style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xff006400),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomListItemTwo extends StatelessWidget {
  CustomListItemTwo(
      {Key key,
      this.thumbnail,
      this.title,
      this.subtitle,
      this.preco,
      this.quantidade,
      this.icone,
      this.radius,
      this.color,
      this.subTotal})
      : super(key: key);

  final Widget thumbnail;
  final Widget icone;
  final String title;
  final String subtitle;
  final String preco;
  final double radius;
  final Color color;
  final String quantidade;
  final String subTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          border: Border.all(width: 1, color: Colors.grey),
          color: color),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.0,
                child: thumbnail,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: _ArticleDescription(
                    title: title,
                    subtitle: subtitle,
                    preco: preco,
                    quantidade: quantidade,
                    subTotal: subTotal,
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 0.45,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: icone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
