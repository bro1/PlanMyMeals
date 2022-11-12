import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';

class Recipe extends StatefulWidget {
  Recipe({super.key});

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {

  bool _dessert = false;
  bool _side = false;

  final myController = TextEditingController();
  final descController = TextEditingController();
  final whereController = TextEditingController();
  final whereURLController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add new recipe"),
        ),
        body: Center(

            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Text("Title", textAlign: TextAlign.left),
          TextField(controller: myController),
          Text("Description"),
          TextField(controller: descController),
          Text("Where to find?"),
          TextField(controller: whereController),
          Text("Where to findURL?"),
          TextField(controller: whereURLController),
          ToggleButtons(

              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.blue[700],
              selectedColor: Colors.white,
              fillColor: Colors.blue[200],
              color: Colors.blue[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
            children: <Widget>[
              Text("Dessert"),
              Text("Side Dish"),

            ],
            onPressed: (int index) {
              setState(() {
                switch(index) {
                  case 0: _dessert = !_dessert; break;
                  case 1: _side = !_side;
                }
              });
            },
            isSelected: <bool>[_dessert, _side]
          ),
              const SizedBox(height: 50),
          ElevatedButton(child: Text("Save"),onPressed: save,)
        ])));
  }

  void save() async {
    var db = await database;
    int i = 0;
    if (db != null) {
      db.execute("""
      INSERT INTO recipe (title, description, whereToFind, whereToFindURL, sideDish, dessert, restrictions) 
      VALUES (?, ?, ?, ?, ?, ?, ?)
      """, [myController.text, descController.text, whereController.text, whereURLController.text, _side, _dessert]);

      i = await lastID(db);
    }

    Navigator.pop(context, i);
  }

}
