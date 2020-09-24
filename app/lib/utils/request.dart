import 'package:dio/dio.dart';
import 'dart:io';

//var serverULR = "http://192.168.203.83:8000/api/";
// var serverULR = "http://192.168.1.25:8000/api/";
var serverULR = "https://lichuang.pro/blind_server/api/";
var serverImagesULR = serverULR + "images/";

BaseOptions options = new BaseOptions(
  baseUrl: serverULR,
  connectTimeout: 5000,
  receiveTimeout: 10000,
  headers: {HttpHeaders.userAgentHeader: 'dio', 'common-header': 'xx'},
);
Dio dio = new Dio(options);

///   var dio = Dio(BaseOptions(
///    baseUrl: "http://www.dtworkroom.com/doris/1/2.0.0/",
///    connectTimeout: 5000,
///    receiveTimeout: 5000,
///    headers: {HttpHeaders.userAgentHeader: 'dio', 'common-header': 'xx'},
///   ));
///  ```
