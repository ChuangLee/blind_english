import 'package:blind_english/data/media_data.dart';
import 'package:blind_english/data/news_data.dart';
import 'package:blind_english/widgets/mp_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:blind_english/pages/player/part_player_service.dart';
import 'package:blind_english/data/music.dart';
import 'package:blind_english/route.dart';

class NewsListView extends StatelessWidget {
  final List<MaterialColor> _colors = Colors.primaries;
  final NewsData newsData;
  final Media media;
  List<Music> musics = new List<Music>();
  String token;

  NewsListView(this.newsData, this.media) : super();

  //song item length plus a header
  get size => musics.length + 1;

  void _playAll(BuildContext context) {
    if (quiet.value.token == token && quiet.value.isPlaying) {
      //open playing page
      Navigator.pushNamed(context, ROUTE_PAYING);
    } else {
      quiet.playWithList(musics[0], musics, token);
    }
  }

  void _play(int index, BuildContext context) {
    var toPlay = musics[index];
    token = newsData.news[index].mp3Name;
    if (quiet.value.token == token &&
        quiet.value.isPlaying &&
        quiet.value.current == toPlay) {
      //open playing page
//      Navigator.pushNamed(context, ROUTE_PAYING);
    } else {
      quiet.playWithList(toPlay, musics, token);
    }
    Navigator.pushNamed(context, ROUTE_PAYING);
  }

  void initializeMusics() {
    if (newsData == null || newsData.news == null) {
      return;
    }
    for (var news in newsData.news) {
      musics.add(Music.fromNews(news, media));
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeMusics();
    return new ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount:
          newsData == null || newsData.news == null ? 0 : newsData.news.length,
      itemBuilder: (context, int index) {
        final s = newsData.news[index];
        final MaterialColor color = _colors[index % _colors.length];
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new ListTile(
                dense: false,
                leading: new Hero(
                  child: avatarPlay(
                      null, s.duration, color, Theme.of(context).textTheme),
                  tag: s.title,
                ),
                title: new Text(s.title),
                subtitle: new Text(
                  s.refreshTime,
                  style: Theme.of(context).textTheme.caption,
                ),
                onTap: () {
                  newsData.setCurrentIndex(index);
                  _play(index, context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
