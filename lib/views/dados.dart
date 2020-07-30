import 'package:flutter/material.dart';

class AnimatedIconExample extends StatefulWidget {
  @override
  _AnimatedIconExampleState createState() => _AnimatedIconExampleState();
}

class _AnimatedIconExampleState extends State<AnimatedIconExample>
    with SingleTickerProviderStateMixin {
  PageController pageController = PageController();
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            child: Center(
              child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close, progress: controller),
            ),
            onTap: () {
              controller.reverse();
              pageController.animateToPage(0,
                  duration: Duration(seconds: 1), curve: Curves.linear);
            },
          ),
          title: Text("Animated PageView Controller")),
      body: PageView(
        controller: pageController,
        scrollDirection: Axis.vertical,
        children: <Widget>[
          buildPage0(),
          Container(color: Colors.green),
          Container(color: Colors.blue),
          Container(color: Colors.yellow),
          Container(color: Colors.pink),
        ],
      ),
    );
  }

  show(int page) {
    controller.forward();
    pageController.animateToPage(page, duration: Duration(seconds: 1), curve: Curves.linear);
  }

  temporario(){
    int i =1;
    while(true){
      show(i);
      Duration(seconds: 2);
      i!=4 ? i++ : i = 1;
    }
  }
  Container buildPage0() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ListTile(onTap: () => show(1), title: Center(child: Text("Green"))),
          ListTile(onTap: () => show(2), title: Center(child: Text("Blue"))),
          ListTile(onTap: () => show(3), title: Center(child: Text("Yellow"))),
          ListTile(onTap: () => show(4), title: Center(child: Text("Pink"))),
        ],
      ),
    );
  }
}