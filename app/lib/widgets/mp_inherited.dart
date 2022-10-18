/*
 * @Author: lichuang
 * @Date: 2018-12-20 16:22:15
 * @LastEditors: lichuang
 * @@Copyright: (c) 2018 CFCA [http://www.cfca.com.cn] All rights reserved.
 * @Description: 
 */
import 'package:blind_english/data/song_data.dart';
import 'package:flutter/material.dart';

class MPInheritedWidget extends InheritedWidget {
  final SongData songData;
  final bool isLoading;

  const MPInheritedWidget(this.songData, this.isLoading, child)
      : super(child: child);

  static MPInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
    // return context.inheritFromWidgetOfExactType(MPInheritedWidget);
  }

  @override
  bool updateShouldNotify(MPInheritedWidget oldWidget) =>
      // TODO: implement updateShouldNotify
      songData != oldWidget.songData || isLoading != oldWidget.isLoading;
}
