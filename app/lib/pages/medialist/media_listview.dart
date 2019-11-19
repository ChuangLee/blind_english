import 'package:blind_english/data/media_data.dart';
import 'package:blind_english/my_app.dart';
import 'package:blind_english/pages/medialist/media_inherited.dart';
import 'package:blind_english/pages/newslist/news_page.dart';
import 'package:blind_english/utils/image_util.dart';
import 'package:flutter/material.dart';
import 'package:blind_english/pages/root_page.dart';

class MediaListView extends StatelessWidget {
  final List<MaterialColor> _colors = Colors.primaries;
  @override
  Widget build(BuildContext context) {
    final rootIW = MediaInheritedWidget.of(context);
    MediaData mediaData = rootIW.mediaData;
    return new ListView.builder(
      itemCount: mediaData.medias == null ? 0 : mediaData.medias.length,
      itemBuilder: (context, int index) {
        final media = mediaData.medias[index];
        String icon = media.icon;
        Widget iconImage = imageAssetsThenServer(icon,
            width: 60.0, height: 60.0, fit: BoxFit.cover);

        return new Card(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                dense: false,
                leading: new Hero(
                  child: new ClipRRect(
                      borderRadius: new BorderRadius.circular(5.0),
                      child: iconImage),
                  tag: media.title,
                ),
                title: new Text(media.title),
                subtitle: new Text(
                  media.description,
                  style: Theme.of(context).textTheme.caption,
                ),
                onTap: () {
                  mediaData.setCurrentIndex(index);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new NewsPage(media)));
                },
              )
            ],
          ),
        );
      },
    );
  }
}
