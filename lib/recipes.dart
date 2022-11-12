import 'package:flutter/material.dart';
import 'package:plan_my_meals/recipe.dart';

import 'main.dart';

class Recipes extends StatefulWidget {
  Recipes({ super.key });

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {

  late Future<List<Map<String, dynamic>>> _recipes;


  @override
  void initState() {
    super.initState();
    _recipes = _getRecipes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Recipes"),
        ),
        body: Center(
            child: Column(children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                  future: _recipes,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {

                      final plan = snapshot.data;

                      return Flexible(
                          child: Scrollbar(
                              child: ListView.builder(
                                  itemCount: plan?.length,
                                  itemBuilder: (context, index) {

                                    return Dismissible(
                                      key: ObjectKey(plan?[index]),
                                      child: ListTile(
                                        title: Text('${plan?[index]["title"]}'),
                                        // subtitle: if ${plan?[index]["description"] != null Text('${plan?[index]["description"]}'),
                                        subtitle: null,
                                        onTap: () {

                                        },
                                      ),
                                      confirmDismiss:
                                          (DismissDirection direction) async {
                                        //replaceDay(plan?[index]["plandayid"], plan?[index]["recipeid"]);
                                        return false;
                                      },
                                      background: Container(color: Colors.green),
                                      // secondaryBackground: Container(color: Colors.red),
                                    );


                                  })));
                    }

                    return Text("Nothing yet");
                  }),
            ])),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Recipe()
                )
          ).then((value) {


            if (value != 0) {
              // TODO: refresh and select the newly added one


            }

          });
        },
      tooltip: 'New recipe',
      child: const Icon(Icons.add),
    ),
    );

  }
}


Future<List<Map<String, dynamic>>> _getRecipes() async {
  final db = await database;
  final Future<List<Map<String, dynamic>>> maps = db!.rawQuery("""
SELECT
	recipe.id,
	recipe.title,
	recipe.description,
	recipe.whereToFind,
	recipe.whereToFindURL,
	recipe.sideDish,
	recipe.dessert,
	recipe.restrictions
FROM
	recipe
    """);
  return maps;
}
