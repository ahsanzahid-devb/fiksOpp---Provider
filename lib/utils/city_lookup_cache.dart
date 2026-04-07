import 'package:handyman_provider_flutter/models/city_list_response.dart';

/// In-memory id → name from [city-list] for the provider's state (used by job list rows).
class CityLookupCache {
  CityLookupCache._();

  static final Map<int, String> _names = {};
  static int? _loadedForStateId;

  static Future<void> warmForStateIfNeeded(
    int stateId,
    Future<List<CityListResponse>> Function(int stateId) load,
  ) async {
    if (stateId <= 0) return;
    if (_loadedForStateId == stateId && _names.isNotEmpty) return;
    try {
      final rows = await load(stateId);
      for (final c in rows) {
        final id = c.id;
        final n = c.name?.trim();
        if (id != null && n != null && n.isNotEmpty) {
          _names[id] = n;
        }
      }
      _loadedForStateId = stateId;
    } catch (_) {}
  }

  static String? nameForCityId(num? cityId) {
    if (cityId == null || cityId <= 0) return null;
    return _names[cityId.toInt()];
  }
}
