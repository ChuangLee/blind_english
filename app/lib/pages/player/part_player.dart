import 'package:blind_english/pages/player/page_playing_list.dart';
import 'package:blind_english/route.dart';
import 'package:blind_english/utils/image_util.dart';
import 'package:flutter/material.dart';

import 'part_player_service.dart';

class BoxWithBottomPlayerController extends StatelessWidget {
  BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: child),
        BottomControllerBar(),
      ],
    );
  }
}

class BottomControllerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state =
        PlayerState.of(context, aspect: PlayerStateAspect.playbackState).value;
    var music =
        PlayerState.of(context, aspect: PlayerStateAspect.music).value.current;
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        if (music != null) {
           Navigator.pushNamed(context, ROUTE_PAYING);
        }
      },
      child: Card(
        elevation: 24.0,
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(4.0),
                topRight: const Radius.circular(4.0))),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: Theme.of(context).dividerColor,),
            ),
          ),
          height: 68,
          child: Row(
            children: <Widget>[
              Hero(
                tag: "album_cover",
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: music.album.coverImageUrl == null
                          ? Container(color: Colors.grey)
                          : imageAssetsThenServer(music.album.coverImageUrl,
                              width: 60.0, height: 60.0, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Padding(padding: const EdgeInsets.only(top: 2)),
                    Text(
                      music.title,
                      maxLines: 4,
                      style: Theme.of(context).textTheme.body1,
                    ),
//                    Padding(padding: const EdgeInsets.only(top: 2)),
//                    Text(
//                      music.subTitle,
//                      maxLines: 1,
//                      overflow: TextOverflow.ellipsis,
//                      style: Theme.of(context).textTheme.caption,
//                    ),
                    Spacer(),
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (state.isPlaying) {
                  return IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        quiet.pause();
                      });
                } else if (state.isBuffering) {
                  return Container(
                    height: 24,
                    width: 24,
                    //to fit  IconButton min width 48
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(4),
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        quiet.play();
                      });
                }
              }),
              IconButton(
                  tooltip: "当前播放列表",
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                           return PlayingListDialog();
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
