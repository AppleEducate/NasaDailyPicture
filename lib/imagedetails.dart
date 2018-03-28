import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageDetailsPage extends StatelessWidget {
  String title = globals.firstname;
  String hdImageUrl = globals.id;
  String dateCreated = globals.lastname;
  String description = globals.description;

  @override
  void initState() {}

  Future openImage() async {
    globals.Utility.launchURL(hdImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Image Details"),
        ),
        body: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            new Text(
              title,
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            new InkWell(
              onTap: openImage,
              child: new Image.network(
                hdImageUrl,
              ),
            ),
            new Text(
              description,
              style: new TextStyle(fontSize: 14.0),
            ),
            new Text(
              dateCreated,
              style: new TextStyle(fontSize: 10.0),
            ),
          ],
        ));
  }
}
