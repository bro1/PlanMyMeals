import 'package:flutter/material.dart';

import 'dart:async';

import 'package:path/path.dart';
import 'package:plan_my_meals/day.dart';
import 'package:plan_my_meals/plans.dart';
import 'package:plan_my_meals/recipes.dart';
import 'package:plan_my_meals/wishlist.dart';
import 'package:sqflite/sqflite.dart';

import 'package:intl/intl.dart';

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';



Future<Database>? database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'plan-my-meals1.db'),


    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      db.execute(
        '''
          CREATE TABLE "lnkplandayrecipe" (
	          "planDayID"	INTEGER,
	          "recipeID"	INTEGER,
	          PRIMARY KEY("planDayID","recipeID")
          )
        ''',
      );

      db.execute(
        '''
          CREATE TABLE "plan" (
	          "id"	INTEGER,
	          PRIMARY KEY("id")
          )
        ''',
      );

      db.execute(
        '''
CREATE TABLE "planday" (
	"id"	INTEGER,
	"date"	timestamp,
	"planid"	INTEGER,
	"leftovers"	boolean,
	"takeaway"	boolean,
	PRIMARY KEY("id")
)
        ''',
      );

      db.execute(
        '''
          CREATE TABLE "recipe" (
            "id"	INTEGER,
            "title"	TEXT,
            "description"	TEXT,
            "whereToFind"	TEXT,
            "whereToFindURL"	TEXT,
            "sideDish"	boolean DEFAULT 0,
            "dessert"	boolean DEFAULT 0,
            "restrictions"	TEXT,
            PRIMARY KEY("id" AUTOINCREMENT)
          )
        ''',
      );

      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Čeburėkai', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Pasta and mince', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Kugelis', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Biryani', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Burgers', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Pizza', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Chicken nuggets', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Hot dogs', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Stir fry and noodles ', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Citrus pork', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Chicken wings', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Chicken saag', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Tacos', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Nachos', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Daal', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Corned beef', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Fish and chips', 0, 0)''');
      db.execute(
          '''insert into recipe(title, sidedish, dessert) values ('Čenachai', 0, 0)''');

      db.execute('''INSERT INTO "planday" VALUES (1,'2022-10-24',1)''');
      db.execute('''INSERT INTO "planday" VALUES (2,'2022-10-25',1)''');
      db.execute('''INSERT INTO "planday" VALUES (3,'2022-10-26',1)''');
      db.execute('''INSERT INTO "planday" VALUES (4,'2022-10-27',1)''');
      db.execute('''INSERT INTO "planday" VALUES (5,'2022-10-28',1)''');
      db.execute('''INSERT INTO "planday" VALUES (6,'2022-10-29',1)''');
      db.execute('''INSERT INTO "planday" VALUES (7,'2022-10-30',1)''');

      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (1,1)''');
      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (2,9)''');
      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (3,8)''');
      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (4,11)''');
      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (5,NULL)''');
      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (6,NULL)''');
      db.execute('''INSERT INTO "lnkplandayrecipe" VALUES (7,11)''');
    },

    onUpgrade: (db, oldversion, newversion) {

      if (oldversion == 1) {
        print("upgrading db from $oldversion to $newversion");
        db.execute('''ALTER TABLE planday add leftovers boolean''');
        db.execute('''ALTER TABLE planday add takeaway boolean''');
      }

    },

    version: 2,
  );

  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan My Meals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Plan My Meals'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _recipeTitle = "";
  late Future<List<Map<String, dynamic>>> _plan;


  @override
  void initState() {
    super.initState();
    _plan = _getPlan();
  }

  Future<List<Map<String, dynamic>>> _getPlan() async {
    final db = await database;
    final Future<List<Map<String, dynamic>>> maps = db!.rawQuery("""
select planday.id as plandayid, planday.leftovers, planday.takeaway, date, recipe.id as recipeid, recipe.title 
from planday 
join lnkplandayrecipe l on (planday.id = l.planDayID)
join recipe on (l.recipeid = recipe.id)
where planday.planid = ?
    """, [1]);
    return maps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [

          PopupMenuButton(
            // add icon, by default "3 dot" icon
            // icon: Icon(Icons.book)
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Backup"),
                  ),

                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Restore from backup"),
                  ),

                ];
              },
              onSelected:(value) async {
                if(value == 0){
                  print("Backup");
                  final db = await database;
                  if (db != null) {
                    createBackupFile(db);
                  }
                }else if(value == 1){
                  print("Settings menu is selected.");
                }
              }
          ),

        ],
      ),
      body: Center(
          child: Column(children: [
        FutureBuilder<List<Map<String, dynamic>>>(
            future: _plan,
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
                                    title: Text('📅 ${plan?[index]["date"]}'),
                                    subtitle: getsubtitle(plan?[index]),
                                    onTap: () {

                                      int di = plan![index]["plandayid"];

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Day(dayID: di),
                                        ),
                                      ).then((value) {
                                        setState(() {
                                          _plan = _getPlan();
                                        });
                                      });
                                    },
                                  ),
                                  confirmDismiss:
                                      (DismissDirection direction) async {
                                        replaceDayAndRefresh(plan?[index]["plandayid"], plan?[index]["recipeid"]);
                                        return false;
                                        },
                                  background: Container(color: Colors.green),
                                  // secondaryBackground: Container(color: Colors.red),
                                );


                            })));
              }

              return Text("Nothing yet");
            }),
        Text(
          '$_counter: $_recipeTitle',
          style: Theme.of(context).textTheme.headline4,
        ),
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: generateNewPlan,
        tooltip: 'Refresh plan',
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (value) {
          // Recipes
          if (value == 0)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Plans()),
            );

          // Recipes
          if (value == 2)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Recipes()),
            );

          if (value == 3)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Wishlist()),
            );
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: 'Some day',
          ),
        ],
      ),
    );
  }


  Widget getsubtitle(Map<String, dynamic>? planentry) {
    if (planentry?["leftovers"] == 1) {
      return Text("Leftovers");
    }
    if (planentry?["takeaway"] == 1) {
      return Text("Takeaway");
    }
    return Text(planentry?["title"]);
  }

  void replaceDayAndRefresh(int dayID, int recipeID) async {

    await replaceDayWithRandomRecipe(dayID, recipeID);

    setState(() {
      _plan = _getPlan();
    });
  }

  void generateNewPlan() async {

    final planID = 1;

    final db = await database;

    // Get 7 random recipes
    List<Map<String, Object?>>? res = await  db?.rawQuery('''
    SELECT * from recipe    
    order by random() limit 7
    ''');

    // Clean up
    await db?.execute('''delete from plan where id = ?''', [planID]);

    // Clean up
    await db?.execute('''delete from lnkplandayrecipe where
    planDayID in (select id from planday where planid = ?);''', [planID]);

    await db?.execute('''delete from planday where planid = ?''', [planID]);

    await db?.execute('''insert into plan values(?)''', [planID]);

    int i = 0;

    DateTime d = DateTime.now();
    for (final recipe in res!) {

      i++;
      if (i == 1) {
        d = next(i);
      } else {
        d = d.add(Duration(days: 1));
      }
      final DateFormat formatter = DateFormat('E, dd MMM');
      final String formatted = formatter.format(d);

      print(recipe);
      await db?.execute('''insert into planday (date, planid) values(?, ?)''', [formatted, planID]);
      int id = await lastID(db!);

      await db?.execute('''INSERT into lnkplandayrecipe(planDayID, recipeID) values (?, ?)''', [id, recipe["id"]]);
    }

    setState(() {
      _plan = _getPlan();
    });

  }


}
Future<int> lastID(Database db) async {
  var v = await db.rawQuery("select last_insert_rowid() as last");
  int id = v?[0]["last"] as int;
  return id;
}


DateTime next(int day) {
  DateTime d = DateTime.now();

  return d.add(
    Duration(
      days: (day - d.weekday) % DateTime.daysPerWeek,
    ),
  );
}


DateTime dayAfter(DateTime day) {

  return day.add(Duration(days: 1));
}


Future<int> replaceDayWithRandomRecipe(int dayID, int recipeID) async {
  final db = await database;

  // get a random recipe that is
  // not the same as the current recipe
  List<Map<String, Object?>>? res = await  db?.rawQuery('''
    SELECT * from recipe
    where id <> ?
    order by random() limit 1
    ''', [recipeID]);

  var nid = res?[0]["id"];

  await db?.execute('''update lnkplandayrecipe set recipeID = ? where plandayid = ? and recipeID = ?''', [nid, dayID, recipeID]);
  await db?.execute('''update planday set takeaway=null, leftovers=null where id = ?''', [dayID]);

  return 0;

}


Future<int> replaceDayWithSpecificRecipe(int dayID, int recipeID) async {
  final db = await database;

  await db?.execute('''update lnkplandayrecipe set recipeID = ? where plandayid = ?''', [recipeID, dayID]);
  await db?.execute('''update planday set takeaway=null, leftovers=null where id = ?''', [dayID]);

  return recipeID;
}





Future<void> createBackupFile(Database database) async {

  // Fetch the data from the database
  final plans = await database.query('plan');
  final planDays = await database.query('planday');
  final recipes = await database.query('recipe');
  final planDayRecipes = await database.query('lnkplandayrecipe');

  // Convert the data to JSON
  final backupData = {
    'plans': plans,
    'planDays': planDays,
    'recipes': recipes,
    'planDayRecipes': planDayRecipes,
  };
  final backupJson = json.encode(backupData);

  // Save the JSON to a file
  final backupFile = await File('/storage/emulated/0/Download/planmymealsbackup.json').create();
  backupFile.writeAsStringSync(backupJson);
}
