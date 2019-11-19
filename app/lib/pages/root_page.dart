import 'package:blind_english/pages/now_playing.dart';
import 'package:blind_english/widgets/mp_inherited.dart';
import 'package:blind_english/widgets/mp_lisview.dart';
import 'package:blind_english/flute_music_player.dart';
import 'package:flutter/material.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootIW = MPInheritedWidget.of(context);
    //Goto Now Playing Page
    void goToNowPlaying(Song s, {bool nowPlayTap: false}) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new NowPlaying(
                    rootIW.songData,
                    s,
                    nowPlayTap: nowPlayTap,
                  )));
    }

    //Shuffle Songs and goto now playing page
    void shuffleSongs() {
      goToNowPlaying(rootIW.songData.randomSong);
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("My Blind Demo"),
        actions: <Widget>[
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Center(
              child: new InkWell(
                  child: new Text("Now Playing"),
                  onTap: () => goToNowPlaying(
                        rootIW.songData.songs[
                            (rootIW.songData.currentIndex == null ||
                                    rootIW.songData.currentIndex < 0)
                                ? 0
                                : rootIW.songData.currentIndex],
                        nowPlayTap: true,
                      )),
            ),
          )
        ],
      ),
      // drawer: new MPDrawer(),
      body: rootIW.isLoading
          ? new Center(child: new CircularProgressIndicator())
          : new Scrollbar(child: new MPListView()),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.shuffle), onPressed: () => shuffleSongs()),
    );
  }
}
