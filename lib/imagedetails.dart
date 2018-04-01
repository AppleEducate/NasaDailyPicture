import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_nasa/globals.dart' as globals;
import 'package:share/share.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageDetailsPage extends StatelessWidget {
  String title = globals.title;
  String imageUrl = globals.imageurl;
  String hdImageUrl = globals.hdimageurl;
  String dateCreated = globals.datecreated;
  String description = globals.description;

  @override
  void initState() {}

  Future openImage(String image) async {
    globals.Utility.launchURL(image);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Image Details"),
          actions: <Widget>[
          new IconButton(
            // action button
            icon: new Icon(Icons.share, size: 30.0, color: Colors.white),
            onPressed: () {
              share('Nasa Image: $title,\n\nDescription: $description\n\nImage: $hdImageUrl'); //True for Stock Camera
            },
          ),
         
        ],
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
              onTap: () { 
                openImage(hdImageUrl);
                },
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
