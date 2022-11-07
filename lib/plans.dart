import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Plans extends StatefulWidget {
  const Plans({ super.key });

  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        title: Text("My Plans"),
    ));

  }
}