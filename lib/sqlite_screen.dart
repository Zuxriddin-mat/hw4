import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  List<Map<String, dynamic>> usersFromDatabase = [];

  @override
  void initState() {
    super.initState();
    // Fetch user data from the SQLite database
    _fetchUsersFromDatabase();
  }

  // Function to fetch user data from the SQLite database
  Future<void> _fetchUsersFromDatabase() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using a hardcoded path is not recommended for production.
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database
        return db.execute(
          'CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, name TEXT, email TEXT)',
        );
      },
      version: 1,
    );

    // Query the database for all users
    final List<Map<String, dynamic>> users = await database.then((db) {
      return db.query('users');
    });

    setState(() {
      usersFromDatabase = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Screen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display user information from the SQLite database
          Expanded(
            child: ListView.builder(
              itemCount: usersFromDatabase.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(usersFromDatabase[index]['name']),
                  subtitle: Text(usersFromDatabase[index]['email']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
