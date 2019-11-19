import 'package:blind_english/data/song_data.dart';
import 'package:blind_english/pages/root_page.dart';
import 'package:blind_english/widgets/mp_inherited.dart';
import 'package:blind_english/flute_music_player.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SongData songData;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    songData.audioPlayer.stop();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    _isLoading = true;

    var songs;
    try {
      songs = await MusicFinder.allSongs();
    } catch (e) {
      print("Failed to get songs: '${e.message}'.");
    }

    print(songs);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      songData = new SongData((songs));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MPInheritedWidget(songData, _isLoading, new RootPage());
  }
}
