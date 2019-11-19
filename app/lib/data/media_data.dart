class Media {
  int id;
  String title;
  String description;
  String refreshTime;
  String icon;

  Media(this.id, this.title, this.description, this.refreshTime, this.icon);
  Media.fromMap(Map m) {
    id = m["id"];
    title = m["name"];
    description = m["description"];
    refreshTime = m["refreshTime"];
    icon = m["icon"];
  }
}

class MediaData {
  List<Media> _medias;
  int _currentIndex = -1;
  MediaData(this._medias);

  List<Media> get medias => _medias;
  int get length => _medias.length;
  int get currentIndex => _currentIndex;
  setCurrentIndex(int index) {
    _currentIndex = index;
  }
}
