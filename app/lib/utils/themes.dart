import 'package:flutter/material.dart';

enum CurrentTheme { dark, light }

final ThemeData darkTheme = new ThemeData(
    brightness: Brightness.dark,
    buttonColor: Colors.white,
    unselectedWidgetColor: Colors.white,
    dividerColor: Colors.grey,
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      body2:
          TextStyle(fontSize: 13.0, fontFamily: 'Hind', color: Colors.white70),
      display2: TextStyle(
          fontSize: 13.0, fontFamily: 'Hind', color: Colors.lightBlue),
      display3: TextStyle(
          fontSize: 13.0, fontFamily: 'Hind', color: Colors.lightBlueAccent),
    ),
    primaryTextTheme: new TextTheme(
      caption: new TextStyle(color: Colors.white),
      body2:
          TextStyle(fontSize: 30.0, fontFamily: 'Hind', color: Colors.white30),
    ));

final ThemeData lightTheme = new ThemeData(
    primaryColor: Colors.blue,
    backgroundColor: Colors.white,
    buttonColor: Colors.black,
    unselectedWidgetColor: Colors.white,
    dividerColor: Colors.grey,
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      display2:
          TextStyle(fontSize: 13.0, fontFamily: 'Hind', color: Colors.blue),
      display3:
          TextStyle(fontSize: 13.0, fontFamily: 'Hind', color: Colors.blue),
    ),
    primaryTextTheme: new TextTheme(
      caption: new TextStyle(color: Colors.white),
      body2: TextStyle(fontSize: 30.0, fontFamily: 'Hind', color: Colors.white),
    ));
