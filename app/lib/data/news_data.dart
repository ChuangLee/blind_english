import 'package:blind_english/utils/request.dart';

class News {
  int id;
  String title;
  String transcriptUrl;
  String refreshTime;
  String url;
  String mp3Name;
  String currentHref;
  String duration;
  String mp3Url;
  String audUrl;
  String speakers;

  News.fromMap(Map m) {
    id = m["id"];
    title = m["Title"];
    refreshTime = m["DownloadTime"];
    mp3Name = m["Mp3Name"];
    duration = m["Duration"];
    url = serverULR + "audios/" + m["Url"];
    currentHref = m["CurrentHref"];
    if (currentHref != null && currentHref.length > 0) {
      if (currentHref.contains("storyId=")) {
        List<String> temps = currentHref.split("storyId=");
        id = int.parse(temps[temps.length - 1]);
      } else if (currentHref.contains("voanews")) {
        List<String> temps = currentHref.split("/");
        String idHtml = temps[temps.length - 1];
        id = int.parse(idHtml.replaceAll(new RegExp(r'.html'), ''));
      }
    }
    initialize();
  }

  void initialize() {
    if (mp3Name != null && mp3Name.length > 5) {
      String filename = mp3Name.substring(0, mp3Name.length - 4);
      mp3Url = url + mp3Name;
      audUrl = url + filename + ".aud";
      speakers = url + filename + ".speaker";
      transcriptUrl = url + filename + ".transcript";
    }
  }
}

class NewsData {
  List<News> _news;
  int _currentIndex = -1;

  NewsData(this._news);

  List<News> get news => _news;

  int get length => _news.length;

  int get currentIndex => _currentIndex;

  setCurrentIndex(int index) {
    _currentIndex = index;
  }
}
