import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class DashboardController extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  toggleTabs(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
