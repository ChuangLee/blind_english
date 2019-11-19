import 'package:blind_english/medias_app.dart';
import 'package:blind_english/pages/page_main.dart';
import 'package:blind_english/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:blind_english/pages/player/part_player_service.dart';
import 'route.dart';

void main() => runApp(new MyMaterialApp());

class MyMaterialApp extends StatefulWidget {
  @override
  MyMaterialAppState createState() {
    return new MyMaterialAppState();
  }
}

class MyMaterialAppState extends State<MyMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: MaterialApp(
        initialRoute: "/",
        routes: routes,
        title: 'BlindEnglish',
        theme: darkTheme,
      ),
    );
  }
}
