import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;
import 'package:daily_nasa/imagedetails.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Daily Nasa Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var data;
  String apiKey = "ecbPd1gAXph1ytyKAEUeu7KRB5xGEx5XOkB7Xoi4";
  int count = 50;

  Future getData() async {
    _refreshIndicatorKey.currentState?.show();
    var response = await http.get(
        Uri.encodeFull(
            "https://api.nasa.gov/planetary/apod?api_key=$apiKey&count=$count"),
        headers: {"Accept": "application/json"});
    var items = JSON.decode(response.body);
    this.setState(() {
      data = items;
    });
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  Widget buildCellTile(String image, String title, String date) {
    return new Card(
      elevation: 1.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          new Center(
              child: new Text(
            title,
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            textAlign: TextAlign.center,
          )),
          new Expanded(
            child: new Image.network(
              image,
              height: 65.0,
              width: 65.0,
              fit: BoxFit.fitHeight,
            ),
          ),
          new Container(
            height: 10.0,
          ),
          new Center(
              child: new Text(
            date,
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Daily NASA"),
      ),
      body: new RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: getData,
        child: new GridView.builder(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width <= 500.0
                  ? 2
                  : width <= 800.0 ? 3 : width <= 1100.0 ? 4 : 5),
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              onTap: () {
                globals.firstname = data[index]["title"];
                globals.lastname = data[index]["date"];
                globals.id = data[index]["hdurl"] == null
                    ? data[index]["url"]
                    : data[index]["hdurl"];
                globals.description = data[index]["explanation"];
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new ImageDetailsPage()),
                );
              },
              child: buildCellTile(
                  data[index]["hdurl"] == null
                      ? data[index]["url"]
                      : data[index]["hdurl"],
                  data[index]["title"] == null ? "" : data[index]["title"],
                  data[index]["date"] == null ? "" : data[index]["date"]),
            );
          },
        ),
      ),
    );
  }
}
