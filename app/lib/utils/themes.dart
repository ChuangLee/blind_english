/*
 * @Author: lichuang
 * @Date: 2019-02-12 16:15:09
 * @LastEditors: lichuang
 * @@Copyright: (c) 2018 CFCA [http://www.cfca.com.cn] All rights reserved.
 * @Description: 
 */
import 'package:flutter/material.dart';

enum CurrentTheme { dark, light }

final ThemeData darkTheme = new ThemeData(
    brightness: Brightness.dark,
    buttonColor: Colors.white,
    unselectedWidgetColor: Colors.white,
    dividerColor: Colors.grey,
    textTheme: TextTheme(
      headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyText1:
          TextStyle(fontSize: 13.0, fontFamily: 'Hind', color: Colors.white70),
      headline4: TextStyle(
          fontSize: 30.0,
          fontFamily: 'YaHei',
          color: Colors.white30,
          height: 1.0),
      headline3: TextStyle(
          fontSize: 20.0,
          fontFamily: 'Hind',
          color: Colors.lightBlue,
          height: 0.9),
      headline2: TextStyle(
          fontSize: 13.0, fontFamily: 'Hind', color: Colors.lightBlueAccent),
    ),
    primaryTextTheme: new TextTheme(
      caption: new TextStyle(color: Colors.white),
      bodyText1:
          TextStyle(fontSize: 22.0, fontFamily: 'Hind', color: Colors.blue),
    ));

final ThemeData lightTheme = new ThemeData(
    primaryColor: Colors.blue,
    backgroundColor: Colors.white,
    buttonColor: Colors.black,
    unselectedWidgetColor: Colors.white,
    dividerColor: Colors.grey,
    textTheme: TextTheme(
      headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      headline4: TextStyle(
          fontSize: 30.0,
          fontFamily: 'YaHei',
          color: Colors.white30,
          height: 1.0),
      headline3: TextStyle(
          fontSize: 20.0, fontFamily: 'Hind', color: Colors.blue, height: 0.9),
      headline2:
          TextStyle(fontSize: 13.0, fontFamily: 'Hind', color: Colors.blue),
    ),
    primaryTextTheme: new TextTheme(
      caption: new TextStyle(color: Colors.white),
      bodyText1:
          TextStyle(fontSize: 22.0, fontFamily: 'Hind', color: Colors.blue),
    ));
