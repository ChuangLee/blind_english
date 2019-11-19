import 'package:blind_english/data/media_data.dart';
import 'package:blind_english/pages/medialist/media_inherited.dart';
import 'package:blind_english/pages/medialist/media_page.dart';
import 'package:blind_english/utils/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MediaApp());

class MediaApp extends StatefulWidget {
  @override
  MediaAppState createState() {
    return new MediaAppState();
  }
}

class MediaAppState extends State<MediaApp> {
  MediaData mediaData;
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

    List<Media> medias = new List();
    try {
      Response medialistJson = await dio.get('medialist');
      List medialistMap = medialistJson.data['newsmedia'];
      if (medialistMap != null) {
        for (var mediaMap in medialistMap) {
          medias.add(Media.fromMap(mediaMap));
        }
      }
      // print('Response:${medialistJson.data}');
      // json

    } catch (e) {
      _loadFailed = true;
      print("Failed to get medialist: '${e.message}'.");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      mediaData = new MediaData((medias));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loadFailed
        ? new Center(
            child: new IconButton(
                tooltip: "",
                iconSize: 60,
                icon: Icon(
                  Icons.refresh,
                ),
                onPressed: () {
                  setState(() {
                    initPlatformState();
                  });
                }))
        : new MediaInheritedWidget(mediaData, _isLoading, new MediaPage());
    // return new MediaInheritedWidget(mediaData, _isLoading, new MediaPage());
  }
}
