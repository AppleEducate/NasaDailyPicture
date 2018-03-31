import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;
import 'package:share/share.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsPage extends StatelessWidget {
  @override
  void initState() {}
  bool pushNotifications = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Settings"),
        ),
        body: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Text(
                    'Daily Image Notification?',
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
                new Switch(
                  value: pushNotifications,
                  onChanged: (bool value) {
                    value == false
                        ? pushNotifications = true
                        : pushNotifications = false;
                  },
                ),
              ],
            )
          ],
        ));
  }
}
