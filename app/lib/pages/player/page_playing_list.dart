import 'package:flutter/material.dart';
import 'part_player_service.dart';
import 'channel_media_player.dart';
import 'package:blind_english/data/music.dart';

class PlayingListDialog extends StatelessWidget {
  Widget buildHeader(BuildContext context, int count) {
    PlayMode playMode =
        PlayerState.of(context, aspect: PlayerStateAspect.playMode)
            .value
            .playMode;
    IconData icon;
    String name;
    switch (playMode) {
      case PlayMode.single:
        icon = Icons.repeat_one;
        name = "单曲循环";
        break;
      case PlayMode.sequence:
        icon = Icons.repeat;
        name = "列表循环";
        break;
      case PlayMode.shuffle:
        icon = Icons.shuffle;
        name = "随机播放";
        break;
    }
    return Material(
      elevation: 0.5,
      child: Container(
        height: 48,
        child: Row(
          children: <Widget>[
            TextButton.icon(
                onPressed: () {
                  quiet.changePlayMode();
                },
                icon: Icon(icon),
                label: Text("$name($count)")),
            Spacer(),
            TextButton.icon(
                onPressed: null,
                icon: Icon(Icons.add_box),
                label: Text("收藏全部")),
            IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  quiet.quiet();
                })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Music> playingList =
        PlayerState.of(context, aspect: PlayerStateAspect.playlist)
            .value
            .playingList;
    Music music =
        PlayerState.of(context, aspect: PlayerStateAspect.music).value.current;

    Widget header = buildHeader(context, playingList.length);

    double offset = playingList.indexOf(music) * _HEIGHT_MUSIC_TILE;
    if (offset < 0) {
      offset = 0;
    }

    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        children: <Widget>[
          header,
          Expanded(
            child: ListView.builder(
                controller: ScrollController(initialScrollOffset: offset),
                itemCount: playingList.length,
                itemBuilder: (context, index) {
                  debugPrint("build $index");
                  var item = playingList[index];
                  return _MusicTile(music: item, playing: item == music);
                }),
          )
        ],
      ),
    );
  }
}

const _HEIGHT_MUSIC_TILE = 48.0;

class _MusicTile extends StatelessWidget {
  final Music music;
  final bool playing;

  const _MusicTile({Key key, this.music, this.playing = false})
      : assert(music != null && playing != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget leading;
    Color name, artist;
    if (playing) {
      Color color = Theme.of(context).textTheme.headline2.color;
      leading = Container(
        margin: EdgeInsets.only(right: 4),
        child: Icon(
          Icons.volume_up,
          color: color,
          size: 18,
        ),
      );
      name = color;
      artist = color;
    } else {
      leading = Container();
      name = Theme.of(context).textTheme.bodyText1.color;
      artist = Theme.of(context).textTheme.caption.color;
    }

    return InkWell(
      onTap: () {
        quiet.play(music: music);
      },
      child: Container(
        padding: EdgeInsets.only(left: 8),
        height: _HEIGHT_MUSIC_TILE,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).dividerColor, width: 0.3))),
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
                child: Text(
                    '${music.artist[0].name.split(' ')[0]}: ${music.title} ',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: name))),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  quiet.removeFromPlayingList(music);
                })
          ],
        ),
      ),
    );
  }
}
