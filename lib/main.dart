import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'dart:ffi';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController foodItemController = TextEditingController();

  late Database? database;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'calories_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE meals(id INTEGER PRIMARY KEY, date TEXT, foodItem TEXT, calories INTEGER)',
        );

        // Insert initial data (at least 20 preferred food items and calories pairs)
        await insertInitialData(db);
      },
      version: 1,
    );
  }

  Future<void> insertInitialData(Database db) async {
    // Insert your initial data here, for example:
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Chicken Breast', calories: 200).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Broccoli', calories: 50).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Chicken Burger', calories: 150).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Apple', calories: 80).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Orange', calories: 40).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Veal', calories: 200).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Ground Beef', calories: 150).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Blueberries', calories: 50).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Blackberries', calories: 20).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Burger', calories: 150).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Pork', calories: 150).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Watermelon', calories: 50).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Yogurt', calories: 20).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Turkey', calories: 50).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Banana', calories: 200).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Hotdogs', calories: 50).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Pasta', calories: 200).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Pizza', calories: 50).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Wings', calories: 200).toMap());
    await db.insert('meals', Meal(date: '2023-01-01', foodItem: 'Shawarma', calories: 1500).toMap());
    // ... Add more entries ...
  }

  Future<void> insertMeal(Meal meal) async {
    if (database != null) {
      await database!.insert(
        'meals',
        meal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Meal saved: Date: ${meal.date} | Food Items: ${meal.foodItem} | Calories: ${meal.calories}');
    }
  }

  Future<List<Meal>> getMeals(String date) async {
    if (database != null) {
      final List<Map<String, dynamic>> maps = await database!.query(
        'meals',
        where: 'date = ?',
        whereArgs: [date],
      );

      final meals = List.generate(maps.length, (i) {
        return Meal(
          id: maps[i]['id'],
          date: maps[i]['date'],
          foodItem: maps[i]['foodItem'],
          calories: maps[i]['calories'],
        );
      });

      print('Fetched meals for date $date: $meals');

      return meals;
    } else {
      return [];
    }
  }

  Future<void> deleteMeal(int id, String date) async {
    if (database != null) {
      await database!.delete('meals', where: 'id = ? AND date = ?', whereArgs: [id, date]);
      print('Meal deleted with id: $id and date: $date');
    }
  }

  Future<void> updateMeal(Meal meal, String originalDate) async {
    if (database != null) {
      await database!.update(
        'meals',
        meal.toMap(),
        where: 'id = ? AND date = ?',
        whereArgs: [meal.id, originalDate],
      );
      print('Meal updated: ${meal.id}, ${meal.date}, ${meal.foodItem}, ${meal.calories}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Calories Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(labelText: 'Target Calories per Day'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: foodItemController,
              decoration: InputDecoration(labelText: 'Food Item'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the meal to the database
                final meal = Meal(
                  date: dateController.text,
                  foodItem: foodItemController.text,
                  calories: int.parse(caloriesController.text),
                );
                insertMeal(meal);
              },
              child: Text('Save Meal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Retrieve and display meals for a specific date
                final meals = await getMeals(dateController.text);
                meals.forEach((meal) {
                  print('Date: ${meal.date}, Food Item: ${meal.foodItem}, Calories: ${meal.calories}');
                });
              },
              child: Text('Show Meals'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Delete meals for the selected date
                final meals = await getMeals(dateController.text);
                meals.forEach((meal) async {
                  await deleteMeal(meal.id!, dateController.text);
                });
              },
              child: Text('Delete Meal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update meals for the selected date
                final meals = await getMeals(dateController.text);
                meals.forEach((meal) async {
                  final updatedMeal = Meal(
                    id: meal.id,
                    date: dateController.text,
                    foodItem: 'Updated Food',
                    calories: 300,
                  );
                  await updateMeal(updatedMeal, dateController.text);
                });
              },
              child: Text('Update Meal'),
            ),
          ],
        ),
      ),
    );
  }
}

class Meal {
  final int? id;
  final String date;
  final String foodItem;
  final int calories;

  Meal({this.id, required this.date, required this.foodItem, required this.calories});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'foodItem': foodItem,
      'calories': calories,
    };
  }

  @override
  String toString() {
    return 'Meal{id: $id, date: $date, foodItem: $foodItem, calories: $calories}';
  }
}
