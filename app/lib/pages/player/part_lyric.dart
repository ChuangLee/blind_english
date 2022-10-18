import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:blind_english/utils/utils.dart';

class Lyric extends StatefulWidget {
  Lyric(
      {@required this.lyric,
      this.lyricLineStyle,
      this.highlightStyle,
      this.position,
      this.textAlign = TextAlign.start,
      @required this.size});

  final TextStyle lyricLineStyle;

  final LyricContent lyric;

  final TextAlign textAlign;

  final ValueNotifier<int> position;

  final TextStyle highlightStyle;

  final Size size;

  @override
  State<StatefulWidget> createState() => LyricState();
}

class LyricState extends State<Lyric> with TickerProviderStateMixin {
  LyricPainter lyricPainter;

  AnimationController _flingController;

  AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    lyricPainter = LyricPainter(
        widget.lyricLineStyle, widget.lyric, widget.highlightStyle,
        textAlign: widget.textAlign);
    widget.position?.addListener(_onPositionChange);
  }

  void _onPositionChange() {
    int milliseconds = widget.position.value;

    int line = widget.lyric
        .findLineByTimeStamp(milliseconds, lyricPainter.currentLine);

//    debugPrint("is being dragging : $isDragging");

    if (lyricPainter.currentLine != line && !isDragging) {
      double offset = lyricPainter.computeScrollTo(line);
//      debugPrint("find line : $line , isDragging = $isDragging");
//      debugPrint("start _lineController : $offset");
      _lineController?.dispose();
      _lineController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800),
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _lineController.dispose();
            _lineController = null;
          }
        });
      Animation<double> animation = Tween<double>(
              begin: lyricPainter.offsetScroll,
              end: lyricPainter.offsetScroll + offset)
          .chain(CurveTween(curve: Curves.easeInOut))
          .animate(_lineController);
      animation.addListener(() {
        lyricPainter.offsetScroll = animation.value;
      });
      _lineController.forward();
    }
    lyricPainter.currentLine = line;
  }

  bool isDragging = false;

  @override
  void dispose() {
    widget.position?.removeListener(_onPositionChange);
    _flingController?.dispose();
    _flingController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    return Container(
      constraints: BoxConstraints(minWidth: 300, minHeight: 120),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          isDragging = true;
        },
        onPointerUp: (_) {
          isDragging = false;
        },
        onPointerCancel: (_) {
          isDragging = false;
        },
        child: GestureDetector(
          onVerticalDragStart: (details) {
            _flingController?.dispose();
            _flingController = null;
          },
          onVerticalDragUpdate: (details) {
            lyricPainter.offsetScroll += details.primaryDelta;
          },
          onVerticalDragEnd: (details) {
            isDragging = true;
            _flingController = AnimationController.unbounded(
                vsync: this, duration: const Duration(milliseconds: 300))
              ..addListener(() {
                double value = _flingController.value;

                if (value < -lyricPainter.height || value >= 0) {
                  _flingController.dispose();
                  _flingController = null;
                  isDragging = false;
                  value = value.clamp(-lyricPainter.height, 0.0);
                }
                lyricPainter.offsetScroll = value;
                lyricPainter.repaint();
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  isDragging = false;
                }
              })
              ..animateWith(ClampingScrollSimulation(
                  position: lyricPainter.offsetScroll,
                  velocity: details.primaryVelocity));
          },
          child: CustomPaint(
            size: widget.size,
            painter: lyricPainter,
          ),
        ),
      ),
    );
  }
}

class LyricPainter extends ChangeNotifier implements CustomPainter {
  LyricContent lyric;
  List<TextPainter> lyricPainters;

  double padding = 8.0;
  double _offsetScroll = 0;

  double get offsetScroll => _offsetScroll;

  set offsetScroll(double value) {
    _offsetScroll = value.clamp(-height, 0.0);
    repaint();
  }

  int currentLine = 0;

  TextAlign textAlign;

  TextStyle styleHighlight;

  ///param lyric must not be null
  LyricPainter(TextStyle style, this.lyric, TextStyle highlight,
      {this.textAlign = TextAlign.start}) {
    assert(lyric != null);
    lyricPainters = [];
    for (int i = 0; i < lyric.size; i++) {
      var painter = TextPainter(
          text: TextSpan(style: style, text: lyric[i].line),
          textAlign: textAlign);
      painter.textDirection = TextDirection.ltr;
//      painter.layout();//layout first, to get the height
      lyricPainters.add(painter);
    }
    styleHighlight = highlight;
  }

  void repaint() {
    notifyListeners();
  }

  double get height => _height;
  double _height = 0;

  Paint debugPaint = Paint();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    _layoutPainterList(size);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

//    canvas.drawLine(Offset(0, size.height / 2),
//        Offset(size.width, size.height / 2), debugPaint);

    double dy = offsetScroll + size.height / 2 - lyricPainters[0].height / 2;

    for (int line = 0; line < lyricPainters.length; line++) {
      TextPainter painter = lyricPainters[line];

      if (line == currentLine) {
        painter = TextPainter(
            text: TextSpan(
                text: painter.text.toPlainText(), style: styleHighlight),
            textAlign: textAlign);
        painter.textDirection = TextDirection.ltr;
        painter.layout(maxWidth: size.width - padding * 2);
      }
      drawLine(canvas, painter, dy, size);
      dy += painter.height;
    }
  }

  ///draw a lyric line
  void drawLine(
      ui.Canvas canvas, TextPainter painter, double dy, ui.Size size) {
    if (dy > size.height || dy < 0 - painter.height) {
      return;
    }
    canvas.save();

    double dx = 0;
    if (textAlign == TextAlign.center) {
      dx = (size.width - painter.width) / 2 + padding;
    }
    canvas.translate(dx, dy);

    painter.paint(canvas, Offset(padding, padding));
    canvas.restore();
  }

  @override
  bool shouldRepaint(LyricPainter oldDelegate) {
    return true;
  }

  void _layoutPainterList(ui.Size size) {
    _height = 0;
    lyricPainters.forEach((p) {
      p.layout(maxWidth: size.width - padding * 2);
      _height += p.height;
    });
  }

  //compute the offset current offset to destination line
  double computeScrollTo(int destination) {
    if (lyricPainters.length <= 0 || this.height == 0) {
      return 0;
    }

    double height = -lyricPainters[0].height / 2;
    for (int i = 0; i < lyricPainters.length; i++) {
      if (i == destination) {
        height += lyricPainters[i].height / 2;
        break;
      }
      height += lyricPainters[i].height;
    }
    return -(height + offsetScroll);
  }

  @override
  bool hitTest(ui.Offset position) => null;

  @override
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      shouldRebuildSemantics(oldDelegate);
}

class LyricContent {
  ///splitter lyric content to line
  static const LineSplitter _SPLITTER = const LineSplitter();

  LyricContent.from(String text) {
    List<String> lines = _SPLITTER.convert(text);
    Map map = <int, String>{};
    lines.forEach((l) => LyricAudEntry.inflate(l, map));

    List<int> keys = map.keys.toList()..sort();
    keys.forEach((key) {
      _durations.add(key);
      _lyricEntries.add(LyricAudEntry(map[key], getTimeStamp(key)));
    });
  }

  List<int> _durations = [];
  List<LyricAudEntry> _lyricEntries = [];

  int get size => _durations.length;

  LyricAudEntry operator [](int index) {
    return _lyricEntries[index];
  }

  ///根据第几行找时间
  int findTimeStampByLine(int index) {
    return _durations[index];
  }

  ///
  ///根据时间戳来寻找匹配当前时刻的歌词
  ///
  ///@param timeStamp  歌词的时间戳(毫秒)
  ///@param anchorLine the start line to search
  ///@return index to getLyricEntry
  ///
  int findLineByTimeStamp(final int timeStamp, final int anchorLine) {
    int position = anchorLine;
    if (position < 0 || position > size - 1) {
      position = 0;
    }
    if (findTimeStampByLine(position) > timeStamp) {
      //look forward
      while (findTimeStampByLine(position) > timeStamp) {
        position--;
        if (position <= 0) {
          position = 0;
          break;
        }
      }
    } else {
      while (findTimeStampByLine(position) < timeStamp) {
        position++;
        if (position <= size - 1 && findTimeStampByLine(position) > timeStamp) {
          position--;
          break;
        }
        if (position >= size - 1) {
          position = size - 1;
          break;
        }
      }
    }
    return position;
  }

  @override
  String toString() {
    return 'Lyric{_lyricEntries: $_lyricEntries}';
  }
}

class LyricAudEntry {
//  static RegExp pattern = RegExp(r"\[\d{2}:\d{2}.\d{2,3}]");
  static RegExp pattern = RegExp(r"\[\d{2~6}.\d{3}]");

  static int _stamp2int(final String stamp) {
    return int.parse(stamp.replaceAll(".", ""));
  }

  ///build from a .lrc file line .such as: [11:44.100] what makes your beautiful
  static void inflate(String line, Map<int, String> map) {
    //TODO lyric info
    if (line.startsWith("[ti:")) {
    } else if (line.startsWith("[ar:")) {
    } else if (line.startsWith("[al:")) {
    } else if (line.startsWith("[au:")) {
    } else if (line.startsWith("[by:")) {
    } else {
      var stampsContent = line.split("\t");
      if (stampsContent.length < 3) {
        return;
      }
      var stamp = stampsContent[0];
      var content = stampsContent[2];
      int timeStamp = _stamp2int(stamp);
      map[timeStamp] = content;
    }
  }

  LyricAudEntry(this.line, this.timeStamp);

  final String timeStamp;
  final String line;

  @override
  String toString() {
    return 'LyricEntry{line: $line, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricAudEntry &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          timeStamp == other.timeStamp;

  @override
  int get hashCode => line.hashCode ^ timeStamp.hashCode;
}
