import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Recipe extends StatefulWidget {
  Recipe({ super.key });

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green);
  }
}