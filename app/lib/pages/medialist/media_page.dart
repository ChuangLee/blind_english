import 'package:blind_english/pages/medialist/media_inherited.dart';
import 'package:blind_english/pages/medialist/media_listview.dart';
import 'package:flutter/material.dart';

class MediaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootIW = MediaInheritedWidget.of(context);

    return rootIW.isLoading
          ? new Center(child: new CircularProgressIndicator())
          : new Scrollbar(child: new MediaListView());
  }
}
