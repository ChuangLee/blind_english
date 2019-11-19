import 'package:blind_english/data/news_data.dart';
import 'package:blind_english/pages/newslist/news_inherited.dart';
import 'package:blind_english/pages/newslist/news_page.dart';
import 'package:blind_english/utils/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NewsApp extends StatefulWidget {
  @override
  NewsAppState createState() {
    return new NewsAppState();
  }
}

class NewsAppState extends State<NewsApp> {
  NewsData newsData;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    _isLoading = true;
    _loadFailed = false;
    try {
      Response newsRes = await dio.get('news?mediaID=0');
      String newsCsv = newsRes.toString();
      // newsData = NewsData.fromCSV(newsCsv);
    } catch (e) {
      _loadFailed = true;
      print("Failed to get medialist: '${e.message}'.");
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new NewsInheritedWidget(newsData, _isLoading, new NewsPage(null));
  }
}
