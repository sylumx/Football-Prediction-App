import 'package:flutter/foundation.dart';

class TimezoneProvider with ChangeNotifier {
  String _userTimeZone = 'UTC';

  String get userTimeZone => _userTimeZone;

  void setUserTimeZone(String timeZone) {
    _userTimeZone = timeZone;
    notifyListeners();
  }

  DateTime convertToLocalTime(DateTime utcTime) {
    // Convert UTC time to local time based on the user's timezone offset
    final localTime = utcTime.toLocal();
    return localTime;
  }
}
