import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incidents/core/time_format.dart';

void main() {
  final now = DateTime(2026, 11, 10, 12);

  test('recent times are relative', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now: now), 'Just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now), '5 min ago');
    expect(timeAgo(now.subtract(const Duration(hours: 1)), now: now), '1 hour ago');
    expect(timeAgo(now.subtract(const Duration(hours: 2)), now: now), '2 hours ago');
    expect(timeAgo(now.subtract(const Duration(days: 3)), now: now), '3 days ago');
  });

  test('older dates switch to a calendar date', () {
    expect(timeAgo(DateTime(2026, 10, 1), now: now), '1 Oct 2026');
  });
}
