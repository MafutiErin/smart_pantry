import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../ai/ai_provider.dart';

const String _aiSummaryCacheBoxName = 'ai_summary_cache';

class AiSummaryCacheService {
  static const Duration defaultTtl = Duration(days: 7);

  late Box<String> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox<String>(_aiSummaryCacheBoxName);
    _initialized = true;
  }

  String _buildKey({
    required AiProvider provider,
    required String itemName,
    required String? category,
    required String? notes,
  }) {
    final normalizedName = itemName.trim().toLowerCase();
    final normalizedCategory = (category ?? '').trim().toLowerCase();
    final normalizedNotes = (notes ?? '').trim().toLowerCase();

    return '${provider.name}|$normalizedName|$normalizedCategory|$normalizedNotes';
  }

  Future<Map<String, String>?> get({
    required AiProvider provider,
    required String itemName,
    required String? category,
    required String? notes,
    Duration ttl = defaultTtl,
  }) async {
    await init();

    final key = _buildKey(
      provider: provider,
      itemName: itemName,
      category: category,
      notes: notes,
    );

    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final ts = decoded['ts'] as int?;
      final data = decoded['data'] as Map<String, dynamic>?;

      if (ts == null || data == null) return null;

      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(ts),
      );

      if (age > ttl) {
        await _box.delete(key);
        return null;
      }

      return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    } catch (_) {
      return null;
    }
  }

  Future<void> put({
    required AiProvider provider,
    required String itemName,
    required String? category,
    required String? notes,
    required Map<String, String> value,
  }) async {
    await init();

    final key = _buildKey(
      provider: provider,
      itemName: itemName,
      category: category,
      notes: notes,
    );

    final payload = jsonEncode({
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': value,
    });

    await _box.put(key, payload);
  }
}
