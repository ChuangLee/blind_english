import 'package:flutter/material.dart';
import "package:blind_english/pages/page_main.dart";
import "package:blind_english/pages/player/page_playing.dart";

const ROUTE_MAIN = "/";

const ROUTE_LOGIN = "/login";

const ROUTE_PLAYLIST_DETAIL = "/playlist/detail";

const ROUTE_PAYING = "/playing";

const ROUTE_LEADERBOARD = "/leaderboard";

const ROUTE_DAILY = "/daily";

///app routers
final Map<String, WidgetBuilder> routes = {
  ROUTE_MAIN: (context) => MainPage(),
  ROUTE_PAYING: (context) => PlayingPage(),
};
