import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<Paar> controller;
  List<Paar> namen = [];

  @override
  void dispose() {
    super.dispose();
    controller?.close();
    controller = null;
  }

  @override
  void initState() {
    super.initState();
    doit();
  }

  void doit() async {
    controller = StreamController.broadcast();

    controller.stream.listen((p) {
      setState(() {
        namen.add(p);
      });
    });

    load();
  }

  void load() async {
    //String url = "https://jsonplaceholder.typicode.com/photos";
    String url = "http://api.icndb.com/jokes/random/";

    var client = http.Client();
    var request = http.Request('get', Uri.parse(url));

    var streamedResponse = await client.send(request);

    streamedResponse.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        //.expand((e) => e)
        .map((map) => Paar.fromJsonMap(map))
        .pipe(controller);
  }

  void _incrementCounter(String text) {
    setState(() {
      //namen.add(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: namen.length,
          itemBuilder: (context, index) {
            //return Text("$index ${namen[index].url}");
            return _makeElement(index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         doit();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _makeElement(index) {
    if (index >= namen.length) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(namen[index].joke),
    );
  }
}

class Paar {
  int id;
  String joke;

  Paar.fromJsonMap(Map map) {
    this.id = map["value"]["id"];
    this.joke = map["value"]["joke"];
  }
}
