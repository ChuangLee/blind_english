import 'package:blind_english/data/media_data.dart';
import 'package:blind_english/data/news_data.dart';
import 'package:blind_english/pages/newslist/news_inherited.dart';
import 'package:blind_english/pages/newslist/news_listview.dart';
import 'package:blind_english/pages/player/part_player.dart';
import 'package:blind_english/pages/player/part_player_service.dart';
import 'package:blind_english/utils/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  final Media media;

  NewsPage(this.media);

  @override
  State<StatefulWidget> createState() => new _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  NewsData newsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initNewsState();
  }

  initNewsState() async {
    _isLoading = true;
    List<News> news = new List();
    try {
      Response newsRes = await dio.get('news/' + widget.media.id.toString());
      List newsList = newsRes.data["News"];
      if (newsList != null) {
        for (var newsMap in newsList) {
          news.add(News.fromMap(newsMap));
        }
      }
    } catch (e) {
      print("Failed to get medialist: '${e.message}'.");
    }
    if (!mounted) return;
    setState(() {
      newsData = new NewsData((news));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
//    return  _isLoading && newsData != null
//          ? new Center(child: new CircularProgressIndicator())
//          : new Scrollbar(child: new NewsListView(newsData));
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.media.title),
      ),
      body: _isLoading && newsData != null
          ? new Center(child: new CircularProgressIndicator())
          : Quiet(
              child: BoxWithBottomPlayerController(
                  new NewsListView(newsData, widget.media)),
            ),
//      new Scrollbar(child: new NewsListView(newsData, widget.media)),
    );
  }
}
