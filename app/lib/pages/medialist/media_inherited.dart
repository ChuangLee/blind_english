/*
 * @Author: lichuang
 * @Date: 2018-12-29 14:06:01
 * @LastEditors: lichuang
 * @@Copyright: (c) 2018 CFCA [http://www.cfca.com.cn] All rights reserved.
 * @Description: 
 */
import 'package:blind_english/data/media_data.dart';
import 'package:flutter/material.dart';

class MediaInheritedWidget extends InheritedWidget {
  final MediaData mediaData;
  final bool isLoading;

  const MediaInheritedWidget(this.mediaData, this.isLoading, child)
      : super(child: child);

  static MediaInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
    // return context.inheritFromWidgetOfExactType(MediaInheritedWidget);
  }

  @override
  bool updateShouldNotify(MediaInheritedWidget oldWidget) =>
      mediaData != oldWidget.mediaData || isLoading != oldWidget.isLoading;
}
