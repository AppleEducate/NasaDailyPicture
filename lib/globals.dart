library globals;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

//Variables
bool isLoggedIn = false;
String token = "";
String domain = "";
String apiURL = "https://reqres.in/api/users/2";
String error = "";

String title = '';
String description = "";
String imageurl = '';
String hdimageurl = '';
String datecreated = '';

String id = "0";
String firstname = "Test";
String lastname = "Test";
String avatar =
    "https://s3.amazonaws.com/uifaces/faces/twitter/josephstein/128.jpg";

class Utility {
  static Future<Null> showAlertPopup(
      BuildContext context, String title, String detail) async {
    void showDemoDialog<T>({BuildContext context, Widget child}) {
      showDialog<T>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => child,
      ).then<void>((T value) {
        // The value passed to Navigator.pop() or null.
        if (value != null) {
          // _scaffoldKey.currentState.showSnackBar(new SnackBar(
          //   content: new Text('You selected: $value')
          // ));
        }
      });
    }

    return showDemoDialog<Null>(
        context: context,
        child: Platform.isIOS
            ? new CupertinoAlertDialog(
                title: new Text(title),
                content: new Text(detail),
                actions: <Widget>[
                    // new CupertinoDialogAction(
                    //     child: const Text('Discard'),
                    //     isDestructiveAction: true,
                    //     onPressed: () {
                    //       Navigator.pop(context, 'Discard');
                    //     }),
                    new CupertinoDialogAction(
                        child: const Text('Ok'),
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ])
            : new AlertDialog(
                title: new Text(title),
                content: new Text(
                  detail,
                ),
                actions: <Widget>[
                    new FlatButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    // new FlatButton(
                    //   child: const Text('DISCARD'),
                    //   onPressed: () { Navigator.pop(context, DialogDemoAction.discard); }
                    // )
                  ]));
  }

  static Future<String> getData(String api, String headers) async {
    var requestURL = api;
//    requestURL = requestURL + "calltype=" + calltypeParm;
//    requestURL = requestURL + "&mod=" + modParm;
//    requestURL = requestURL + "&?action=" + actionParm;
//    requestURL = requestURL + "&?param=" + paramsParm;
//    requestURL = requestURL + "&?foo=" + fooParm;
    requestURL = requestURL + headers;
    print("Request URL: " + requestURL);

    var url = requestURL;
    var httpClient = new HttpClient();
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        try {
          var json = await response.transform(utf8.decoder).join();
          result = json;
        } catch (exception) {
          result = 'Error Getting Data';
        }
      } else {
        result =
            'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address $exception';
    }
    print("Result: " + result);
    return result;
  }

  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
