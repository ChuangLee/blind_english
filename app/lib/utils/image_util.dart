import 'package:blind_english/utils/request.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

var _assetsImages = [
  'npr_morning_edition.jpg',
  'npr_weekend_edition.jpg',
  'npr_wait_wait_dont_tell_me.jpg',
  'npr_up_first.jpg',
  'npr_planet_money.jpg',
  'npr_on_point.jpg',
  'npr_how_i_build_this_with_guy_raz.jpg',
  'npr_hidden_brain.jpg',
  'npr_fresh_air.jpg',
  'npr_ask_me_another.jpg',
  'npr_all_things_considered.jpg',
  'voa_learning_english.png'
];
Widget imageAssetsThenServer(
  imageName, {
  width,
  height,
  fit,
}) {
  if (_assetsImages.contains(imageName)) {
    return Image.asset(
      "assets/" + imageName,
      width: width,
      height: height,
      fit: fit,
    );
  } else {
    return CachedNetworkImage(
      imageUrl: serverImagesULR + imageName,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
