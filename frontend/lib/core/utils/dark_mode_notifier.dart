import 'package:flutter/foundation.dart';

class DarkModeNotifier extends ValueNotifier<bool> {
  DarkModeNotifier() : super(false);

  void toggle() {
    value = !value;
  }

  void setDarkMode(bool isDark) {
    value = isDark;
  }
}

