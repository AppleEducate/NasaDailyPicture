import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageDetailsPage extends StatelessWidget {
  String title = "";
  String hdImageUrl = globals.id;
  String dateCreated = "";

  @override
  void initState() {
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Image Details"),
        ),
        body: new Column(
          children: <Widget>[
            new Text(
              title,
              textAlign: TextAlign.center,
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            new Expanded(
              child: new Image.network(
                hdImageUrl,
              ),
            ),
            new Text(
              dateCreated,
              style: new TextStyle(fontSize: 10.0),
            ),
          ],
        ));
  }
}
