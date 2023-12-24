import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hw4/sqlite_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Import the ThirdScreen

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    // Fetch initial user data
    _fetchUsers();
  }

  // Function to fetch user data from the API
  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Function to fetch more users from the API
  Future<void> _fetchMoreUsers() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      setState(() {
        users.addAll(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to fetch more users');
    }
  }

  // Function to store user data in SQLite database
  Future<void> _storeDataInDatabase() async {
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

    // Insert user data into the database
    await database.then((db) async {
      for (var user in users) {
        await db.insert(
          'users',
          {
            'name': user['name'],
            'email': user['email'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display user information
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index]['name']),
                  subtitle: Text(users[index]['email']),
                  onTap: () {
                    // Handle the selection of a user
                    _storeDataInDatabase();
                  },
                );
              },
            ),
          ),
          // Buttons for fetching more users and storing data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _fetchMoreUsers();
                },
                child: Text('Fetch More'),
              ),
              ElevatedButton(
                onPressed: () {
                  _storeDataInDatabase();
                },
                child: Text('Store in SQLite'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Third Screen with fade transition
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => ThirdScreen(),
                      transitionsBuilder: (context, animation1, animation2, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation1.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                      transitionDuration: Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Text('Third Screen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
