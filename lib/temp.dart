import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  // Replace `backup.json` with the path to your backup file.
  final backupFile = File('backup.json');

  try {
    // Read the backup file as a string.
    final backupData = backupFile.readAsStringSync();

    // Decode the JSON data.
    final jsonData = jsonDecode(backupData);

    // Open the SQLite database.
    final db = openDatabase(
      join(await getDatabasesPath(), 'my_database.db'),
      onCreate: (db, version) {
        // Create the tables in the database.
        db.execute(
          'CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, name TEXT)',
        );
        db.execute(
          'CREATE TABLE IF NOT EXISTS posts(id INTEGER PRIMARY KEY, title TEXT, content TEXT, user_id INTEGER, FOREIGN KEY(user_id) REFERENCES users(id))',
        );
        db.execute(
          'CREATE TABLE IF NOT EXISTS comments(id INTEGER PRIMARY KEY, content TEXT, post_id INTEGER, FOREIGN KEY(post_id) REFERENCES posts(id))',
        );
        db.execute(
          'CREATE TABLE IF NOT EXISTS likes(id INTEGER PRIMARY KEY, post_id INTEGER, user_id INTEGER, FOREIGN KEY(post_id) REFERENCES posts(id), FOREIGN KEY(user_id) REFERENCES users(id))',
        );
      },
      version: 1,
    );

    // Restore the data from the JSON object.
    restoreDataFromJson(jsonData, db);

    // Close the database.
    await db.close();
  } catch (e) {
    print('Error restoring data from backup: $e');
  }
}

void restoreDataFromJson(dynamic jsonData, Database db) async {
  final users = jsonData['users'];
  final posts = jsonData['posts'];
  final comments = jsonData['comments'];
  final likes = jsonData['likes'];

  // Insert the users into the users table.
  for (final user in users) {
    await db.insert(
      'users',
      {
        'id': user['id'],
        'name': user['name'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert the posts into the posts table.
  for (final post in posts) {
    await db.insert(
      'posts',
      {
        'id': post['id'],
        'title': post['title'],
        'content': post['content'],
        'user_id': post['user_id'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert the comments into the comments table.
  for (final comment in comments) {
    await db.insert(
      'comments',
      {
        'id': comment['id'],
        'content': comment['content'],
        'post_id': comment['post_id'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert the likes into the likes table.
  for (final like in likes) {
    await db.insert(
      'likes',
      {
        'id': like['id'],
        'post_id': like['post_id'],
        'user_id': like['user_id'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
