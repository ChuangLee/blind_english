import 'dart:io';
import 'package:flutter/material.dart';

Widget avatarPlay(File f, String duration, MaterialColor color,TextTheme textTheme) {
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
          new Text(duration,
            style: textTheme.display2,
          ),
        ],
      ));
}
