import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Counter with ChangeNotifier {
  int _count = 30;
  int _count2 = 30;
  get count => _count;
  get count2 => _count2;

  addCount() {
    _count--;
    notifyListeners();
    print(_count);
  }

  addCount2() {
    _count2--;
    notifyListeners();
    print(_count2);
  }
}
