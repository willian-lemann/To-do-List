import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var novaTask = TextEditingController();

  _HomePageState() {
    load();
  }

  void add() {
    if (novaTask.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: novaTask.text, done: false));
      novaTask.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((item) => Item.fromJson(item)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: TextFormField(
          controller: novaTask,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: 'Nova Tarefa',
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];

          return Dismissible(
            key: Key(item.title),
            background: Container(
              child: Center(
                child: Text('Deletar'),
              ),
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) {
              remove(index);
              save();
            },
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                });
              },
              checkColor: Colors.white,
              activeColor: Colors.purple,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
