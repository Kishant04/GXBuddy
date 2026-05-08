import 'package:intl/intl.dart';

abstract final class DateHelpers {
  static final _dayFmt = DateFormat('EEE, d MMM');
  static final _timeFmt = DateFormat('h:mm a');
  static final _fullFmt = DateFormat('d MMM yyyy');

  static String formatDay(DateTime dt) => _dayFmt.format(dt);
  static String formatTime(DateTime dt) => _timeFmt.format(dt);
  static String formatFull(DateTime dt) => _fullFmt.format(dt);

  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      return 'Today · ${_timeFmt.format(dt)}';
    }
    if (diff.inDays == 1) return 'Yesterday · ${_timeFmt.format(dt)}';
    return '${DateFormat('EEE').format(dt)} · ${_timeFmt.format(dt)}';
  }

  static String dueDays(int days) {
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }
}
