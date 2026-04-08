import 'package:geocoding/geocoding.dart';

final Map<String, String> _reverseGeocodeMemoryCache = {};
final Map<String, Future<String?>> _reverseGeocodeInFlight = {};

String _reverseGeocodeCacheKey(double lat, double lng) =>
    '${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}';

/// Same as [reverseGeocodeLatLng] but shares in-flight work and caches successful strings
/// so list tiles and detail do not repeat platform lookups for the same coordinates.
Future<String?> reverseGeocodeLatLngCached(double lat, double lng) async {
  final key = _reverseGeocodeCacheKey(lat, lng);
  final cached = _reverseGeocodeMemoryCache[key];
  if (cached != null) return cached;

  final existing = _reverseGeocodeInFlight[key];
  if (existing != null) return existing;

  final fut = reverseGeocodeLatLng(lat, lng).then((value) {
    _reverseGeocodeInFlight.remove(key);
    if (value != null && value.isNotEmpty) {
      _reverseGeocodeMemoryCache[key] = value;
    }
    return value;
  });
  _reverseGeocodeInFlight[key] = fut;
  return fut;
}

/// One-line postal-style label from a platform [Placemark] (same shape as post-job flow).
String? singleLineAddressFromPlacemark(Placemark p) {
  final parts = [
    p.street,
    p.subLocality,
    p.locality,
    p.postalCode,
    p.country,
  ].where((e) => e != null && e.toString().trim().isNotEmpty);
  final s = parts.join(', ');
  return s.isEmpty ? null : s;
}

/// Reverse geocode; returns null on empty result or failure (no throw).
Future<String?> reverseGeocodeLatLng(double lat, double lng) async {
  try {
    final marks = await placemarkFromCoordinates(lat, lng);
    if (marks.isEmpty) return null;
    return singleLineAddressFromPlacemark(marks.first);
  } catch (_) {
    return null;
  }
}
