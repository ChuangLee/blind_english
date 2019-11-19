import 'package:dio/dio.dart';

//var serverULR = "http://192.168.203.83:8000/api/";
// var serverULR = "http://192.168.1.25:8000/api/";
var serverULR = "https://lichuang.pro/blind_server/api/";
var serverImagesULR = serverULR + "images/";

Options options =
    new Options(baseUrl: serverULR, connectTimeout: 5000, receiveTimeout: 10000);
Dio dio = new Dio(options); // 使用默认配置
