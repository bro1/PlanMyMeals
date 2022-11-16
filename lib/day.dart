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

  static const List<String> _kOptions = <String>[
    'pizza',
    'kugelis',
    'čeburėkai',
    'šalykai',
    'pasta',
    'dumplings',
    'pork belly',
    'something else',
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
                        if (_showSearch) Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _kOptions.where((String option) {
                              return option.contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            debugPrint('You just selected $selection');
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
                            }
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
}
