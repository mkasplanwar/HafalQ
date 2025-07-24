import 'package:flutter/material.dart';

class BookmarkService extends ChangeNotifier {
  final List<String> _bookmarks = [];

  List<String> get bookmarks => _bookmarks;

  void addBookmark(String ayatId) {
    if (!_bookmarks.contains(ayatId)) {
      _bookmarks.add(ayatId);
      notifyListeners();
    }
  }

  void removeBookmark(String ayatId) {
    _bookmarks.remove(ayatId);
    notifyListeners();
  }
}
