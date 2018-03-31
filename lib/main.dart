import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;
import 'package:daily_nasa/imagedetails.dart';
import 'package:daily_nasa/settings.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Daily Nasa',
      theme: new ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.redAccent,
        primaryColorBrightness: Brightness.dark,
      ),
      home: new MyHomePage(),
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

  List data;
  String apiKey = "ecbPd1gAXph1ytyKAEUeu7KRB5xGEx5XOkB7Xoi4";
  int count = 100;
  bool _reverse = false;

  Future getData() async {
    // _reverse = true;
    // _refreshIndicatorKey.currentState?.show();
    String result = "" +
        await globals.Utility.getData('https://api.nasa.gov/planetary/apod?',
            'api_key=$apiKey&count=$count');
    // String response = "" + await http.get(
    //     Uri.encodeFull(
    //         "https://api.nasa.gov/planetary/apod?api_key=$apiKey&count=$count"),
    //     headers: {"Accept": "application/json"});
    // List items = JSON.decode(response.body);
    this.setState(() {
      // data = items;
      List decoded = JSON.decode(result);
      // oldData = decoded['objects'];
      data = decoded;
    });
  }

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Widget buildCellTile(int index, List data) {
    String title = data[index]["title"];
    String image = data[index]["url"];
    String hdimage = data[index]["hdurl"];
    String date = data[index]["date"];
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
            child: image.contains('youtube')
                ? new Text(hdimage)
                : new Image.network(
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

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    getData();
    completer.complete();

    return completer.future;
  }

  Widget getTiles(List items) {
    // print('Getting $tab Videos');
    double width = MediaQuery.of(context).size.width;
    int axisCount =
        width <= 500.0 ? 2 : width <= 800.0 ? 3 : width <= 1100.0 ? 4 : 5;
    return new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: new GridView.builder(
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: axisCount),
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items == null ? 0 : items.length,
        itemBuilder: (BuildContext context, int index) {
          print('Index: $index / Length: ' +
              data.length.toString() +
              ' / Count: $count');
          if (index + 1 == data.length && index + 1 == count) {
            // count = count + 100;
            // getData();
          }
          return data[index]["url"].toString().contains('youtube')
              ? new Text('')
              : new InkWell(
                  onTap: () {
                    globals.title = data[index]["title"];
                    globals.datecreated = data[index]["date"];
                    globals.imageurl = data[index]["url"];
                    globals.hdimageurl = data[index]["hdurl"];
                    globals.description = data[index]["explanation"];
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ImageDetailsPage()),
                    );
                  },
                  child: buildCellTile(index, data),
                );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Daily NASA"),
        actions: <Widget>[
          new IconButton(
            // action button
            icon: new Icon(Icons.settings, size: 30.0, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: data == null
          ? new Center(
              child: new Text('No Pictures'),
            )
          : getTiles(data),
    );
  }
}
