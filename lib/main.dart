import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;
import 'package:daily_nasa/imagedetails.dart';
import 'package:daily_nasa/settings.dart';
import 'package:local_notifications/local_notifications.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';import 'package:firebase_messaging/firebase_messaging.dart';

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
        primaryColorBrightness: Brightness.light,
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
  ScrollController _myScrollController = new ScrollController();

  List data;
  String apiKey = "ecbPd1gAXph1ytyKAEUeu7KRB5xGEx5XOkB7Xoi4";
  int count = 100;
  bool _reverse = false;
  bool isLoaded = false;

  Future getData() async {
    isLoaded = false;
    //  _refreshIndicatorKey.currentState?.show();
    // _reverse = true;
    String result = "" +
        await globals.Utility.getData('https://api.nasa.gov/planetary/apod?',
            'api_key=$apiKey&count=$count');
    // String response = "" + await http.get(
    //     Uri.encodeFull(
    //         "https://api.nasa.gov/planetary/apod?api_key=$apiKey&count=$count"),
    //     headers: {"Accept": "application/json"});
    // List items = JSON.decode(response.body);
    try {
      List decoded = JSON.decode(result);
      for (var row in decoded) {
        // mData.add(row);
        // mData.add(row);
        // for (var item in row) {
        //   // print("ROW => $item");
        //   mData.add(item);
        // }
        addNewItem(row);
      }
      data = decoded;
    } catch (ex) {
      print(ex);
    }

    // await LocalNotifications.createNotification(
    //     title: "My First Notification", content: "SomeContent", id: 0);
    isLoaded = true;
  }

  void addNewItem(Map row) {
    _items.add(
      new InkWell(
        onTap: () {
          globals.title = row["title"];
          globals.datecreated = row["date"];
          globals.imageurl = row["url"];
          globals.hdimageurl = row["hdurl"];
          globals.description = row["explanation"];
          Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new ImageDetailsPage(),
                maintainState: true),
          );
        },
        child: new Card(
          elevation: 1.0,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              new Center(
                  child: new Text(
                row["title"],
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                textAlign: TextAlign.center,
              )),
              new Expanded(
                child: row["url"].contains('youtube')
                    ? new Text(row["hdurl"])
                    : new Image.network(
                        row["url"],
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
                row["date"],
                textAlign: TextAlign.center,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void addAllItems(List newList, int oldLength, bool isSearching) {
    if (isSearching) {
      _items.clear();
    }
    int index = 0;
    for (var row in newList) {
      if (index > oldLength - 1) {
        addNewItem(row);
      }

      index++;
    }
  }

  List<Widget> _items = new List.generate(0, (index) {
    return new Text("item $index");
  });

  @override
  void initState() {
    super.initState();
    getData().then((result) {
      setState(() {
        print('Data Loaded');
        // data = newData;
      });
    });
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    getData().then((result) {
      setState(() {
        print('Data Loaded');
        // data = newData;
      });
    });
    completer.complete();

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int axisCount =
        width <= 500.0 ? 2 : width <= 800.0 ? 3 : width <= 1100.0 ? 4 : 5;
    Widget _list = new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: _items.length == 0 && !isLoaded
          ? new Align(
              child: new CircularProgressIndicator(),
              alignment: FractionalOffset.center,
            )
          : new GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: axisCount),
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _items == null ? 0 : _items.length,
              itemBuilder: (BuildContext context, int index) {
                // print('Index: $index => Count: $count');
                if (index == count - 1) {
                  // _loadMoreItems();
                }
                return _items.length == 0
                    ? new Center(
                        child: new Text('No Images Found'),
                      )
                    : _items[index];
              },
              reverse: _reverse,
            ),
    );
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: () {
              getData().then((result) {
                setState(() {
                  print('Data Loaded');
                  // data = newData;
                });
              });
            },
          )
        ],
        title: new Text("Daily NASA"),
        // actions: <Widget>[
        //   new IconButton(
        //     // action button
        //     icon: new Icon(Icons.settings, size: 30.0, color: Colors.white),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         new MaterialPageRoute(
        //             builder: (context) => new SettingsPage(),
        //             maintainState: true),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: _list,
    );
  }
}
