import 'package:blind_english/data/media_data.dart';
import 'package:blind_english/data/news_data.dart';
import 'package:flutter/material.dart';

class NewsInheritedWidget extends InheritedWidget {
  final NewsData newsData;
  final bool isLoading;

  const NewsInheritedWidget(this.newsData, this.isLoading, child)
      : super(child: child);

  static NewsInheritedWidget of(BuildContext context) {
    // return context.inheritFromWidgetOfExactType(NewsInheritedWidget);
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(NewsInheritedWidget oldWidget) =>
      newsData != oldWidget.newsData || isLoading != oldWidget.isLoading;
}
