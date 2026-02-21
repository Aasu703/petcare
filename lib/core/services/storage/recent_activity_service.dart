import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRecentActivity {
  final String title;
  final String subtitle;
  final String kind; // page | chat
  final DateTime openedAt;

  const UserRecentActivity({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.openedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'kind': kind,
      'openedAt': openedAt.toIso8601String(),
    };
  }

  factory UserRecentActivity.fromJson(Map<String, dynamic> json) {
    return UserRecentActivity(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      kind: (json['kind'] ?? 'page').toString(),
      openedAt:
          DateTime.tryParse((json['openedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

final recentActivityServiceProvider = Provider<RecentActivityService>((ref) {
  return RecentActivityService(prefs: ref.read(sharedPrefsProvider));
});

class RecentActivityService {
  final SharedPreferences _prefs;

  static const int _maxHistory = 12;

  RecentActivityService({required SharedPreferences prefs}) : _prefs = prefs;

  String _keyForUser(String userId) => 'recent_activity_$userId';

  List<UserRecentActivity> _read(String userId) {
    final raw = _prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                UserRecentActivity.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList()
        ..sort((a, b) => b.openedAt.compareTo(a.openedAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> _write(String userId, List<UserRecentActivity> items) async {
    final payload = jsonEncode(
      items.take(_maxHistory).map((item) => item.toJson()).toList(),
    );
    await _prefs.setString(_keyForUser(userId), payload);
  }

  Future<void> pushActivity({
    required String userId,
    required String title,
    required String subtitle,
    String kind = 'page',
  }) async {
    final list = _read(userId);
    final now = DateTime.now();

    if (list.isNotEmpty) {
      final top = list.first;
      final isSame =
          top.title.toLowerCase() == title.toLowerCase() &&
          top.subtitle.toLowerCase() == subtitle.toLowerCase();
      final withinTwoMinutes = now.difference(top.openedAt).inMinutes < 2;
      if (isSame && withinTwoMinutes) {
        final refreshed = [
          UserRecentActivity(
            title: title,
            subtitle: subtitle,
            kind: kind,
            openedAt: now,
          ),
          ...list.skip(1),
        ];
        await _write(userId, refreshed);
        return;
      }
    }

    final next = [
      UserRecentActivity(
        title: title,
        subtitle: subtitle,
        kind: kind,
        openedAt: now,
      ),
      ...list,
    ];
    await _write(userId, next);
  }

  List<UserRecentActivity> getActivities(String userId, {int limit = 4}) {
    return _read(userId).take(limit).toList();
  }

  Future<void> clear(String userId) async {
    await _prefs.remove(_keyForUser(userId));
  }
}
