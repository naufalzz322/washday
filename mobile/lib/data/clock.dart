import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time in UTC+7 (WIB). The seed is rebuilt from this on every launch,
/// so the timeline always starts on the current shop day.
DateTime washdayNow() {
  final utc = DateTime.now().toUtc();
  return utc.add(const Duration(hours: 7));
}

/// Injectable clock. Tests override this with a fixed instant so date
/// filters stay deterministic.
final washdayClockProvider = Provider<DateTime Function()>((ref) => washdayNow);

/// Midnight-normalised shop date for the current session.
final washdayTodayProvider = Provider<DateTime>((ref) {
  final now = ref.watch(washdayClockProvider)();
  return DateTime(now.year, now.month, now.day);
});
