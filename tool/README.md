# Locale tools

## Missing locale tracker

Compares `language_no.dart` (or another locale) with the base/English definitions and reports **missing** keys (still showing English) and optionally keys that have the **same value as English** (candidates for translation).

Run from **project root** (directory that contains `pubspec.yaml`).

Default (missing Norwegian keys only):

```bash
dart tool/missing_locale_tracker.dart
```

Include keys that have the same value as English:

```bash
dart tool/missing_locale_tracker.dart --show-same-as-en
```

Save report to a file:

```bash
dart tool/missing_locale_tracker.dart > tool/missing_no_report.txt
```

Use another locale (e.g. a future `language_de.dart`):

```bash
dart tool/missing_locale_tracker.dart --locale=de
```

**Tip:** Run one command at a time. Do not paste the whole block into the terminal—copy only the single line you need (without the `#` comment lines).
