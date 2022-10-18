/*
 * @Author: lichuang
 * @LastEditors: lichuang
 */
import 'package:dio/dio.dart';
import 'dart:io';

var serverULR = "http://lichuang.pro:8000/api/";
// var serverULR = "http://192.168.1.25:8000/api/";
// var serverULR = "https://lichuang.pro/blind_server/api/";
var serverImagesULR = serverULR + "images/";

BaseOptions options = new BaseOptions(
  baseUrl: serverULR,
  connectTimeout: 5000,
  receiveTimeout: 10000,
);
Dio dio = new Dio(options);
// (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
//     client.badCertificateCallback=(X509Certificate cert, String host, int port){
//           return true;
//     };
// };
