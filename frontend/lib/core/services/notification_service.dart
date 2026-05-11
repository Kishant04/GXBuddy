import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService(this._prefs) : _shownIds = _loadShownIds(_prefs);

  final SharedPreferences? _prefs;
  final Set<String> _shownIds;

  static const String _kShownIdsKey = 'notif_shown_ids';

  static Set<String> _loadShownIds(SharedPreferences? prefs) {
    if (prefs == null) return {};
    final list = prefs.getStringList(_kShownIdsKey);
    return list?.toSet() ?? {};
  }

  bool shouldShow(String eventId) {
    if (_shownIds.contains(eventId)) return false;
    _shownIds.add(eventId);
    _prefs?.setStringList(_kShownIdsKey, _shownIds.toList());
    return true;
  }

  void reset() {
    _shownIds.clear();
    _prefs?.remove(_kShownIdsKey);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(null);
});
