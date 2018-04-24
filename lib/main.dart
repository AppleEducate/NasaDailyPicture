import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;
import 'package:daily_nasa/imagedetails.dart';
import 'package:daily_nasa/settings.dart';
// import 'package:admob/admob.dart';
import 'package:flutter/services.dart';
// import 'package:local_notifications/local_notifications.dart';
import 'help.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = 'YOUR_DEVICE_ID';
const String iosAdmobAppID = "ca-app-pub-7837488287280985~4079769179";
const String androidAdmobAppID = "ca-app-pub-7837488287280985~7248645342";

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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List data;
  String apiKey = "ecbPd1gAXph1ytyKAEUeu7KRB5xGEx5XOkB7Xoi4";
  int count = 100;
  bool _reverse = false;
  bool isLoaded = false;
  String appIDAds = "";
  bool isDebug = false;

  Future getData() async {
    isLoaded = false;
    String result = "" +
        await globals.Utility.getData('https://api.nasa.gov/planetary/apod?',
            'api_key=$apiKey&count=$count');
    // print('Result: $result');

    try {
      if (result.contains('Error')) {
        // _scaffoldKey.currentState.showSnackBar(new SnackBar(
        //     content: new Text(
        //         'Failed fetching images, please refresh and try again.')));
        globals.Utility.showAlertPopup(context, 'Info',
            'Failed fetching images.\nPlease refresh and try again.');
      } else {
        List decoded = json.decode(result);
        for (var row in decoded) {
          addNewItem(row);
        }
        data = decoded;
      }
    } catch (ex) {
      print(ex);
    }
    showBanner();
    isLoaded = true;
    firstBottom = true;
  }

  void addNewItem(Map row) {
    String content = row["hdurl"] == null
        ? row["url"] == null ? "" : row["url"]
        : row["hdurl"];
    _items.add(
      new InkWell(
        onTap: () {
          showFullAd();
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
                child: content.contains('youtube') || content.contains('vimeo')
                    ? new Center(
                        child: new Icon(
                          Icons.ondemand_video,
                          size: 60.0,
                        ),
                      )
                    : content.toString().isEmpty || content == null
                        ? new Center(
                            child: new Icon(
                              Icons.broken_image,
                              size: 60.0,
                            ),
                          )
                        : new Image.network(
                            content,
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

  List<Widget> _items = new List.generate(0, (index) {
    return new Text("item $index");
  });

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    birthday: new DateTime.now(),
    childDirected: true,
    gender: MobileAdGender.male,
  );

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return new InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    appIDAds = Platform.isIOS ? iosAdmobAppID : androidAdmobAppID;
    FirebaseAdMob.instance
        .initialize(appId: isDebug ? FirebaseAdMob.testAppId : appIDAds);
    _bannerAd = createBannerAd()
      ..load()
      ..show();
    _interstitialAd = createInterstitialAd()..load();

    print('AddID: $appIDAds');
    getData().then((result) {
      setState(() {
        print('Data Loaded');
        // data = newData;
        _bannerAd ??= createBannerAd();
        _bannerAd
          ..load()
          ..show();
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _items.clear();
    getData().then((result) {
      setState(() {
        print('Data Loaded');
        // data = newData;
        // showInterstitialAd();
      });
    });
    completer.complete();

    return completer.future;
  }

  void showBanner() {
    print('New Banner Shown');
    _bannerAd?.dispose();
    _bannerAd = null;

    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show();
  }

  void showFullAd() {
    print('New Full Screen Ad Shown');
    _interstitialAd?.dispose();
    _interstitialAd = createInterstitialAd()
      ..load()
      ..show();
  }

  void goToAbout() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new HelpPage()),
    );
  }

  Future<Null> delay(int milliseconds) {
    return new Future.delayed(new Duration(milliseconds: milliseconds));
  }

  bool firstBottom = true;


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
          : _items.length == 0 && isLoaded
              ? new Center(
                  child: new Text('No Images Found'),
                )
              : new GridView.builder(
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: axisCount),
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _items == null ? 0 : _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    // print('Index: $index => Count: $count');
                    if (index == count - 1 && firstBottom == true) {
                      // _loadMoreItems();
                      firstBottom = false;
                      showFullAd();
                      
                    }
                    return _items[index];
                  },
                  reverse: _reverse,
                ),
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.info),
            onPressed: goToAbout,
          ),
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: () {
              showFullAd();
              _items.clear();
              getData().then((result) {
                setState(() {
                  print('Data Loaded');
                  // data = newData;
                });
              });
            },
          ),
        ],
        title: new Text("Daily NASA"),
      ),
      body: _list,
    );
  }
}
