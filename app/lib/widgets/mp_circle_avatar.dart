/*
 * @Author: lichuang
 * @Date: 2019-02-12 16:15:09
 * @LastEditors: lichuang
 * @@Copyright: (c) 2018 CFCA [http://www.cfca.com.cn] All rights reserved.
 * @Description: 
 */
import 'dart:io';
import 'package:flutter/material.dart';

Widget avatarPlay(
    File f, String duration, MaterialColor color, TextTheme textTheme) {
  return new Material(
      borderRadius: new BorderRadius.circular(20.0),
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      elevation: 3.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          f != null
              ? new Image.file(
                  f,
                  fit: BoxFit.cover,
                )
              : new CircleAvatar(
                  child: new Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  backgroundColor: color,
                ),
          new Text(
            duration,
            style: textTheme.labelMedium,
          ),
        ],
      ));
}
