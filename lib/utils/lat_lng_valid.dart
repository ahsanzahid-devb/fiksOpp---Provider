/// Shared "usable coordinates" check for post-job / service payloads (provider ↔ user app contract).
bool isUsableLatLngStrings(String? latStr, String? lngStr) {
  if (latStr == null || lngStr == null) return false;
  final lt = latStr.trim();
  final ln = lngStr.trim();
  if (lt.isEmpty || ln.isEmpty) return false;
  final lat = double.tryParse(lt);
  final lng = double.tryParse(ln);
  if (lat == null || lng == null) return false;
  if (lat == 0 && lng == 0) return false;
  if (lat < -90 || lat > 90) return false;
  if (lng < -180 || lng > 180) return false;
  return true;
}
