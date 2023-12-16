import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }

  ThemeData get theme {
    return Theme.of(this);
  }

  /// size 라고 이름을 명명하고 싶었지만, size는 이미 예약되어 있어서 sizeOf 로 명명함
  Size get sizeOf {
    return MediaQuery.sizeOf(this);
  }

  NavigatorState get navigator {
    return Navigator.of(this);
  }

  FocusScopeNode get focus {
    return FocusScope.of(this);
  }
}
