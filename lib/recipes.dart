import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Recipes extends StatefulWidget {
  Recipes({ super.key });

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Recipes"),
        ));

  }
}