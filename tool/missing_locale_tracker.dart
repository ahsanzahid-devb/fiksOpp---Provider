// Run from project root: dart tool/missing_locale_tracker.dart [--show-same-as-en]
// See tool/README.md for usage.

import 'dart:io';

void main(List<String> args) {
  final showSameAsEn = args.contains('--show-same-as-en');
  String locale = 'no';
  for (final a in args) {
    if (a.startsWith('--locale=')) {
      locale = a.substring('--locale='.length);
      break;
    }
  }

  final projectRoot = _findProjectRoot();
  if (projectRoot == null) {
    print('Could not find project root (pubspec.yaml). Run from project root.');
    exit(1);
  }

  final basePath = '${projectRoot}lib/locale/base_language.dart';
  final enPath = '${projectRoot}lib/locale/language_en.dart';
  final localePath = '${projectRoot}lib/locale/language_$locale.dart';

  final baseFile = File(basePath);
  final enFile = File(enPath);
  final localeFile = File(localePath);

  if (!baseFile.existsSync()) {
    print('Missing: $basePath');
    exit(1);
  }
  if (!enFile.existsSync()) {
    print('Missing: $enPath');
    exit(1);
  }
  if (!localeFile.existsSync()) {
    print('Missing: $localePath');
    exit(1);
  }

  final baseKeys = _extractBaseKeys(baseFile.readAsStringSync());
  final enMap = _extractKeyValues(enFile.readAsStringSync());
  final localeMap = _extractKeyValues(localeFile.readAsStringSync());

  final missing = baseKeys.where((k) => !localeMap.containsKey(k)).toList()
    ..sort();
  final sameAsEn = <String>[];
  if (showSameAsEn && enMap.isNotEmpty) {
    for (final k in localeMap.keys) {
      final enVal = enMap[k];
      final locVal = localeMap[k];
      if (enVal != null && locVal != null && enVal == locVal) {
        sameAsEn.add(k);
      }
    }
    sameAsEn.sort();
  }

  print('Locale: $locale');
  print('Base keys (total): ${baseKeys.length}');
  print('Overridden in language_$locale: ${localeMap.length}');
  print('Missing in language_$locale: ${missing.length}');
  if (showSameAsEn) {
    print(
        'Same value as English (candidates for translation): ${sameAsEn.length}');
  }
  print('');

  if (missing.isNotEmpty) {
    print('--- Missing keys in language_$locale (still show English) ---');
    for (final k in missing) {
      final enVal = enMap[k];
      final preview = enVal != null ? _preview(enVal) : '';
      print('  $k${preview.isNotEmpty ? '  // en: $preview' : ''}');
    }
    print('');
  }

  if (showSameAsEn && sameAsEn.isNotEmpty) {
    print('--- Keys with same value as English (consider translating) ---');
    for (final k in sameAsEn) {
      final enVal = enMap[k];
      final preview = enVal != null ? _preview(enVal) : '';
      print('  $k  // $preview');
    }
  }
}

String? _findProjectRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 10; i++) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) {
      return '${dir.path}/';
    }
    dir = dir.parent;
  }
  return null;
}

String _preview(String s, [int max = 50]) {
  final t = s.replaceAll('\n', ' ').trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max)}...';
}

final _getterRegex = RegExp(
    r'^\s*(?:@override\s+)?(?:String|int|bool)\s+get\s+(\w+)\s*[;=>{]',
    multiLine: true);
final _methodRegex = RegExp(
    r'^\s*(?:@override\s+)?String\s+(\w+)\s*\([^)]*\)\s*[=>{]',
    multiLine: true);

Set<String> _extractBaseKeys(String source) {
  final keys = <String>{};
  for (final m in _getterRegex.allMatches(source)) {
    keys.add(m.group(1)!);
  }
  for (final m in _methodRegex.allMatches(source)) {
    keys.add(m.group(1)!);
  }
  // Also match abstract declarations (no body)
  final abstractGetter =
      RegExp(r'^\s*(?:String|int|bool)\s+get\s+(\w+)\s*;', multiLine: true);
  final abstractMethod =
      RegExp(r'^\s*String\s+(\w+)\s*\([^)]*\)\s*;', multiLine: true);
  for (final m in abstractGetter.allMatches(source)) {
    keys.add(m.group(1)!);
  }
  for (final m in abstractMethod.allMatches(source)) {
    keys.add(m.group(1)!);
  }
  return keys;
}

final _getterValueRegex = RegExp(
  r'^\s*(?:@override\s+)?(?:String|int|bool)\s+get\s+(\w+)\s*=>\s*(.+?)\s*;',
  multiLine: true,
  dotAll: true,
);
final _methodValueRegex = RegExp(
  r'^\s*(?:@override\s+)?String\s+(\w+)\s*\([^)]*\)\s*=>\s*(.+?)\s*;',
  multiLine: true,
  dotAll: true,
);

Map<String, String> _extractKeyValues(String source) {
  final map = <String, String>{};
  void add(String key, String value) {
    map[key] = value.trim();
  }

  for (final m in _getterValueRegex.allMatches(source)) {
    add(m.group(1)!, m.group(2)!);
  }
  for (final m in _methodValueRegex.allMatches(source)) {
    add(m.group(1)!, m.group(2)!);
  }
  return map;
}
