import 'package:flutter/material.dart';
import 'main.dart';

class Day extends StatefulWidget {
  const Day({super.key, required this.dayID});

  final int dayID;

  @override
  State<Day> createState() => _DayState();
}

class _DayState extends State<Day> {
  late Future<Map<String, Object?>> day;
  late String _dayName = "Day screen";
  bool _showSearch = false;

  // List<String> _kOptions = <String>[
  //   'pizza',
  //   'kugelis',
  //   'čeburėkai',
  //   'šalykai',
  //   'pasta',
  //   'dumplings',
  //   'pork belly',
  //   'something else',
  // ];

  List<String> _kOptions = <String>[
    '---',
  ];



  @override
  void initState() {
    day = getDay();
    day.then((value) => {
      setState(() {
        _dayName = value["date"] as String;
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📅 $_dayName"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          FutureBuilder<Map<String, dynamic>>(
              future: day,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       Text("Title: ${snapshot.data?['title']}"),

                      if (snapshot.data?["description"] != null) Text("Description: ${snapshot.data?["description"]}"),
                      Text("Takeaway?: ${snapshot.data?["takeaway"]}"),
                      Text("Leftovers?: ${snapshot.data?["leftovers"]}"),
                      Wrap(spacing: 10,children: [
                        ElevatedButton(
                          child: const Text("I'll have leftovers"),
                          onPressed: () async {
                            var db = await database;
                            db?.execute("update planday set leftovers = true, takeaway = null where id = ?", [widget.dayID]);
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var db = await database;
                            db?.execute("update planday set leftovers = null, takeaway = true where id = ?", [widget.dayID]);
                            Navigator.pop(context);
                          },

                          child: const Text("I'll get takeaway"),
                        ),
                        if (!_showSearch) ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showSearch = true;
                            });
                          },
                          child: const Text("Look up recipe"),
                        ),
                        if (_showSearch) Autocomplete<Recipe>(
                          optionsBuilder: (TextEditingValue textEditingValue) async {
                            if (textEditingValue.text == '') {
                              return const Iterable<Recipe>.empty();
                            }
                            return await _searchRecipes(textEditingValue.text);
                          },
                          displayStringForOption: (Recipe opt) {
                            return opt.title;
                          },
                          onSelected: (Recipe selection) async {
                            debugPrint('You just selected $selection');
                            await replaceDayWithSpecificRecipe(widget.dayID, selection.id);
                            setState(() {
                              day = getDay();
                            });

                          },
                          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                            return TextField(
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.search),),
                                onTap: () {
                                setState(() {
                                  _showSearch = false;
                                });
                                },
                                focusNode: focusNode,
                                autofocus: true,
                                controller: textEditingController,
                            );
                            },

                        ),
                      ],
                      ),
                    ],
                  );

                }

                return Text("Not ready ${widget.dayID}");
              }),
        ]),
      ),
    );
  }

  Future<Map<String, Object?>> getDay() async {
    var db = await database;

    var rm = await db?.rawQuery("""
    SELECT
	planday.id,
	recipe.title,
	recipe.description,
	recipe.whereToFind,
	recipe.whereToFindURL,
	recipe.sideDish,
	recipe.dessert,
	recipe.restrictions,
	planday.date,
	planday.takeaway,
	planday.leftovers
FROM
	lnkplandayrecipe
	left JOIN planday
	 ON lnkplandayrecipe.planDayID = planday.id
	INNER JOIN recipe
	 ON lnkplandayrecipe.recipeID = recipe.id
where planday.id = ?
    """, [widget.dayID]);

    return rm![0];
  }

  Future<List<Recipe>> _searchRecipes(String q) async {

    var a = await getSearch(q);
    List<Recipe> lst = a.map((e) {
      var recipe = Recipe();
      recipe.id =  e["id"] as int;
      recipe.title = e["title"] as String;
      if (e["description"] != null) recipe.description = e["description"] as String;
      return recipe;
    }
    ).toList();
    return lst;
  }


Future<List<Map<String, Object?>>> getSearch(String q) async {
  var db = await database;

  var rm = await db?.rawQuery("""
SELECT
	recipe.id,
	recipe.title,
	recipe.description
FROM
	recipe
WHERE
	upper(recipe.title) LIKE ?  
    """, ["%${q.toUpperCase()}%"]);

  return rm!;
}
}



class Recipe {
  late int id;
  late String title;
  late String description;

  @override
  String toString() {
    return title;
  }
}