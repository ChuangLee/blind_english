import 'dart:math';
import 'dart:ui';

import 'package:blind_english/utils/image_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'page_playing_list.dart';
import 'channel_media_player.dart';
import 'part_player_service.dart';
import 'package:blind_english/utils/utils.dart';
import 'package:blind_english/data/music.dart';
import 'part_lyric.dart';

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Quiet(
        child: Stack(
          children: <Widget>[
            _BlurBackground(),
            Material(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  _PlayingTitle(),
                  _CenterSection(),
                  //暂时不需要喜爱操作栏
                  // _OperationBar(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  _DurationProgressBar(),
                  _ControllerBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///player controller
/// pause,play,play next,play previous...
class _ControllerBar extends StatelessWidget {
  Widget getPlayModeIcon(context, Color color) {
    var playMode = PlayerState.of(context, aspect: PlayerStateAspect.playMode)
        .value
        .playMode;
    switch (playMode) {
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: color,
        );
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: color,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: color,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;
    var state =
        PlayerState.of(context, aspect: PlayerStateAspect.playbackState).value;

    Widget iconPlayPause;
    if (state.isPlaying) {
      iconPlayPause = IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause_circle_outline,
            color: color,
          ),
          onPressed: () {
            quiet.pause();
          });
    } else if (state.isBuffering) {
      iconPlayPause = SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      iconPlayPause = IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_circle_outline,
            color: color,
          ),
          onPressed: () {
            quiet.play();
          });
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: getPlayModeIcon(context, color),
              onPressed: () {
                quiet.changePlayMode();
              }),
          IconButton(
              tooltip: "上一句",
              iconSize: 36,
              icon: Icon(
                Icons.fast_rewind,
                color: color,
              ),
              onPressed: () {
                quiet.rewind();
              }),
          iconPlayPause,
          IconButton(
              tooltip: "上一条",
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                quiet.playPrevious();
              }),
          IconButton(
              tooltip: "下一条",
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                quiet.playNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.menu,
                color: color,
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return PlayingListDialog();
                    });
              }),
        ],
      ),
    );
  }
}

///a seek bar for current position
class _DurationProgressBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DurationProgressBarState();
}

class _DurationProgressBarState extends State<_DurationProgressBar> {
  bool isUserTracking = false;

  double trackingPosition = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).primaryTextTheme;
    var state = PlayerState.of(context).value;

    Widget progressIndicator;

    String durationText;
    String positionText;

    if (state.initialized) {
      var duration = state.duration.inMilliseconds;
      var position = isUserTracking
          ? trackingPosition.round()
          : state.position.inMilliseconds;

      durationText = getTimeStamp(duration);
      positionText = getTimeStamp(position);

      int maxBuffering = 0;
      for (DurationRange range in state.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
//          LinearProgressIndicator(
//            value: maxBuffering / duration,
//            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
//            backgroundColor: Colors.white12,
//          ),
          Slider(
            value: position.toDouble().clamp(0.0, duration.toDouble()),
            min: 0.0,
            activeColor: theme.bodyText2.color.withOpacity(0.75),
            inactiveColor: theme.caption.color.withOpacity(0.3),
            max: duration.toDouble(),
            onChangeStart: (value) {
              setState(() {
                isUserTracking = true;
                trackingPosition = value;
              });
            },
            onChanged: (value) {
              setState(() {
                trackingPosition = value;
              });
            },
            onChangeEnd: (value) async {
              isUserTracking = false;
              quiet.seekTo(value.round());
              if (!quiet.value.playWhenReady) {
                quiet.play();
              }
            },
          ),
        ],
      );
    } else {
      //a disable slider if media is not available
      progressIndicator = Slider(value: 0, onChanged: (_) => {});
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(positionText ?? "00:00", style: theme.bodyText2),
          Padding(padding: EdgeInsets.only(left: 4)),
          Expanded(
            child: progressIndicator,
          ),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text(durationText ?? "00:00", style: theme.bodyText2),
        ],
      ),
    );
  }
}

class _OperationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).primaryIconTheme.color;

    var music = quiet.value.current;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.file_download,
              color: iconColor,
            ),
            onPressed: null),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: () {
              if (music == null) {
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                // return CommentPage(
                //   threadId: CommentThreadId(music.id, CommentType.song,
                //       playload: CommentThreadPayload.music(music)),
                // );
              }));
            }),
        IconButton(
            icon: Icon(
              Icons.share,
              color: iconColor,
            ),
            onPressed: null),
      ],
    );
  }
}

class _CenterSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  bool showLyric = true;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView(
        children: [_CloudLyric(), _Transcript()],
        //设置滑动方向
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class _Transcript extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TranscriptState();
}

class _TranscriptState extends State<_Transcript> {
  Music music;

  ///
  /// 0 -> loading
  /// 1 -> no lyric
  /// 2 -> load success
  /// 3 -> load failed
  int get state => _state;

  set state(int state) {
    if (state < 0 || state > 3 || state == _state) {
      return;
    }
    setState(() {
      debugPrint("lyric load state : $state");
      _state = state;
    });
  }

  int _state = 0;

  ValueNotifier<int> position = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    quiet.addListener(_onMusicStateChanged);
    _onMusicStateChanged();
  }

  Future _onMusicStateChanged() async {
    if (quiet.value.current == music) {
      if (music == null) {
        state = 1;
      }
    } else {
      music = quiet.value.current;
      if (music.transcript == null) {
        state = 0;
        var transcriptFile =
            await DefaultCacheManager().getSingleFile(music.transcriptUrl);
        if (transcriptFile == null) {
          state = 1;
          return;
        }
        String contents = await transcriptFile.readAsString();
        if (contents == null) {
          state = 3;
        }
        music.transcript = contents;
      }
      if (music.transcript != null) {
        state = 2;
      }
    }
  }

  @override
  void dispose() {
    quiet.removeListener(_onMusicStateChanged);
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.headline4;
    TextStyle contentStyle = style.copyWith(
        color: style.color.withAlpha(200),
        fontSize: style.fontSize - 2,
        height: 1.1);

    if (state == 2) {
      //load success
      return new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Text(music.transcript, style: contentStyle),
      );
    }

    Widget widget;
    if (state == 0) {
      widget = Text(
        "加载中...",
        style: style,
      );
    } else if (state == 1) {
      widget = Text(
        "暂无文稿",
        style: style,
      );
    } else if (state == 3) {
      widget = Text(
        "加载失败",
        style: style,
      );
    } else {
      throw Exception("state erro :$state");
    }
    return Container(
      child: Center(
        child: widget,
      ),
    );
  }
}

class _CloudLyric extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CloudLyricState();
}

class _CloudLyricState extends State<_CloudLyric> {
  Music music;

  ///
  /// 0 -> loading
  /// 1 -> no lyric
  /// 2 -> load success
  /// 3 -> load failed
  int get state => _state;

  set state(int state) {
    if (state < 0 || state > 3 || state == _state) {
      return;
    }
    setState(() {
      debugPrint("lyric load state : $state");
      _state = state;
    });
  }

  int _state = 0;

  ValueNotifier<int> position = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    quiet.addListener(_onMusicStateChanged);
    _onMusicStateChanged();
  }

  Future _onMusicStateChanged() async {
    if (quiet.value.current == music) {
      if (music == null) {
        state = 1;
      }
    } else {
      music = quiet.value.current;
      if (music.lyric == null) {
        state = 0;
        var file = await DefaultCacheManager().getSingleFile(music.lyricUrl);
        if (file == null) {
          state = 1;
          return;
        }
        String contents = await file.readAsString();
        if (contents == null) {
          state = 3;
        } else {
          try {
            music.lyric = LyricContent.from(contents);
          } catch (e) {
            //parse lyric error
            state = 3;
          }
        }
      }
      if (music.lyric != null) {
        state = 2;
      }
    }

    position.value = quiet.value.position.inMilliseconds;
  }

  @override
  void dispose() {
    quiet.removeListener(_onMusicStateChanged);
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.headline4;

    if (state == 2) {
      //load success
      return LayoutBuilder(builder: (context, constraints) {
        return Container(
          child: Lyric(
            lyric: music.lyric,
            lyricLineStyle: style.copyWith(
                color: style.color.withAlpha(159),
                fontSize: style.fontSize,
                height: 1),
            highlightStyle: style.copyWith(color: Colors.white),
            position: position,
            size: Size(
                constraints.maxWidth,
                constraints.maxHeight == double.infinity
                    ? 0
                    : constraints.maxHeight),
          ),
        );
      });
    }

    Widget widget;
    if (state == 0) {
      widget = Text(
        "加载中...",
        style: style,
      );
    } else if (state == 1) {
      widget = Text(
        "暂无文稿",
        style: style,
      );
    } else if (state == 3) {
      widget = Text(
        "加载失败",
        style: style,
      );
    } else {
      throw Exception("state erro :$state");
    }
    return Container(
      child: Center(
        child: widget,
      ),
    );
  }
}

class _AlbumCover extends StatefulWidget {
  @override
  State createState() => _AlbumCoverState();
}

class _AlbumCoverState extends State<_AlbumCover>
    with TickerProviderStateMixin {
  //album cover rotation animation
  AnimationController controller;

  //cover needle controller
  AnimationController needleController;

  //cover needle in and out animation
  Animation<double> needleAnimation;

  //album cover rotation
  double rotation = 0;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    needleController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 700),
        animationBehavior: AnimationBehavior.normal);
    needleAnimation = Tween<double>(begin: -1 / 12, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(needleController);

    controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 13),
        animationBehavior: AnimationBehavior.normal)
      ..addListener(() {
        setState(() {
          rotation = controller.value * 2 * pi;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && controller.value == 1) {
          controller.forward(from: 0);
        }
      });

    quiet.addListener(_onMusicStateChanged);
  }

  void _onMusicStateChanged() {
    var state = quiet.value;

    var _isPlaying = state.isPlaying;

    //handle album cover animation
    if (_isPlaying && !isPlaying) {
      debugPrint("controller status : ${controller.status}");
      controller.forward(from: (rotation) / (2 * pi));
    } else if (!_isPlaying) {
      controller.stop();
    }

    //handle needle rotation animation
    if (isPlaying != _isPlaying) {
      if (_isPlaying) {
        needleController.forward(from: controller.value);
      } else {
        needleController.reverse(from: controller.value);
      }
    }

    isPlaying = _isPlaying;
  }

  @override
  void dispose() {
    quiet.removeListener(_onMusicStateChanged);
    controller.dispose();
    needleController.dispose();
    super.dispose();
  }

  static const double HEIGHT_SPACE_ALBUM_TOP = 100;

  @override
  Widget build(BuildContext context) {
    var music = PlayerState.of(context).value.current;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: HEIGHT_SPACE_ALBUM_TOP),
          margin: const EdgeInsets.symmetric(horizontal: 64),
          child: Transform.rotate(
            angle: rotation,
            child: Material(
              elevation: 3,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(500),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: "album_cover",
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/playing_page_disc.png"))),
                    padding: EdgeInsets.all(30),
                    child: ClipOval(
                      //TODO
                      child: imageAssetsThenServer(
                          music != null
                              ? music.album.coverImageUrl
                              : 'npr_on_point.jpg',
                          width: 60.0,
                          height: 60.0,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ClipRect(
          child: Container(
            child: Align(
              alignment: Alignment(0, -1),
              child: Transform.translate(
                offset: Offset(40, -15),
                child: RotationTransition(
                  turns: needleAnimation,
                  alignment:
                      //44,37 是针尾的圆形的中心点像素坐标, 273,402是playing_page_needle.png的宽高
                      //所以对此计算旋转中心点的偏移,以保重旋转动画的中心在针尾圆形的中点
                      const Alignment(-1 + 44 * 2 / 273, -1 + 37 * 2 / 402),
                  child: Image.asset(
                    "assets/playing_page_needle.png",
                    height: HEIGHT_SPACE_ALBUM_TOP * 1.8,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _BlurBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var music = PlayerState.of(context).value.current;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/grey_hair.jpg"),
        fit: BoxFit.cover,
      )),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 127, sigmaX: 97),
        child: Container(
          color: Colors.black87.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _PlayingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var music =
        PlayerState.of(context, aspect: PlayerStateAspect.music).value.current;
    return AppBar(
      elevation: 0,
      leading: IconButton(
          tooltip: '返回上一层',
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          onPressed: () => Navigator.pop(context)),
      title: Text(music != null ? music.title : "no title",
          style: Theme.of(context).textTheme.headline3, maxLines: 3),
      backgroundColor: Colors.transparent,
      // centerTitle: false,
      actions: <Widget>[
        // PopupMenuButton(
        //   itemBuilder: (context) {
        //     return [
        //       PopupMenuItem(
        //         child: Text("下载"),
        //       ),
        //     ];
        //   },
        //   icon: Icon(
        //     Icons.more_vert,
        //     color: Theme.of(context).primaryIconTheme.color,
        //   ),
        // )
      ],
    );
  }
}
