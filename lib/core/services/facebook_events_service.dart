import 'dart:async';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

/// Centralized wrapper around Meta / Facebook App Events SDK.
///
/// All SDK calls are guarded so a misconfigured SDK or transient native error
/// can never crash the host app. Logging is verbose only in debug builds.
///
/// IMPORTANT: replace placeholder credentials in:
///   - android/app/src/main/res/values/strings.xml
///   - ios/Runner/Info.plist
/// before running real campaign measurement. App ID + Client Token are not
/// hard-coded in Dart on purpose — Meta SDK reads them natively at startup.
class FacebookEventsService {
  FacebookEventsService._();
  static final FacebookEventsService instance = FacebookEventsService._();

  final FacebookAppEvents _fb = FacebookAppEvents();
  bool _initialized = false;

  // ---- Standard Meta event names (mobile) ----
  static const String _evtActivateApp = 'fb_mobile_activate_app';
  static const String _evtCompleteRegistration =
      'fb_mobile_complete_registration';
  static const String _evtSearch = 'fb_mobile_search';
  static const String _evtContentView = 'fb_mobile_content_view';
  static const String _evtInitiatedCheckout = 'fb_mobile_initiated_checkout';
  static const String _evtPurchase = 'fb_mobile_purchase';

  /// Initialize the SDK. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // ATT (iOS) + auto-logging defaults: enable advertiser tracking so installs
      // can be attributed when the user has granted ATT permission. The SDK is
      // a no-op on platforms where these calls are unsupported.
      await _fb.setAdvertiserTracking(enabled: true);
      await _fb.setAutoLogAppEventsEnabled(true);
      _initialized = true;
      _debug('initialized');
    } catch (e, st) {
      _debug('initialize failed: $e\n$st');
    }
  }

  /// Call when a verified user signs in / out so Meta can deduplicate
  /// the same person across devices. We send only the raw user id (non-PII).
  Future<void> setUserId(String? userId) async {
    try {
      if (userId == null || userId.isEmpty) {
        await _fb.clearUserID();
      } else {
        await _fb.setUserID(userId);
      }
    } catch (e) {
      _debug('setUserId failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Public event helpers — keep names aligned with screens / business actions.
  // ---------------------------------------------------------------------------

  Future<void> logAppOpen() => _safeLog(
        _evtActivateApp,
        parameters: const {'source': 'app_launch'},
      );

  Future<void> logLoginSuccess({String? method, int? userId}) => _safeLog(
        'login_success',
        parameters: {
          if (method != null) 'method': method,
          if (userId != null) 'user_id': userId,
        },
      );

  Future<void> logSignUpSuccess({String? method, String? userType}) => _safeLog(
        _evtCompleteRegistration,
        parameters: {
          if (method != null) 'fb_registration_method': method,
          if (userType != null) 'user_type': userType,
        },
      );

  Future<void> logSearchFlight({
    String? fromCity,
    String? toCity,
    String? departureDate,
    String? jetSize,
  }) =>
      _safeLog(
        _evtSearch,
        parameters: {
          if (fromCity != null) 'from_city': fromCity,
          if (toCity != null) 'to_city': toCity,
          if (departureDate != null) 'departure_date': departureDate,
          if (jetSize != null) 'jet_size': jetSize,
        },
      );

  Future<void> logViewFlightDetails({
    required String flightId,
    String? fromCity,
    String? toCity,
    double? amount,
    String? currency,
  }) =>
      _safeLog(
        _evtContentView,
        parameters: {
          'fb_content_type': 'flight',
          'fb_content_id': flightId,
          if (fromCity != null) 'from_city': fromCity,
          if (toCity != null) 'to_city': toCity,
          if (amount != null) 'fb_value_to_sum': amount,
          if (currency != null) 'fb_currency': currency,
        },
      );

  Future<void> logStartBooking({
    required String flightId,
    double? amount,
    String? currency,
    String? jetSize,
  }) =>
      _safeLog(
        _evtInitiatedCheckout,
        parameters: {
          'fb_content_id': flightId,
          'fb_content_type': 'flight',
          if (amount != null) 'fb_value_to_sum': amount,
          if (currency != null) 'fb_currency': currency,
          if (jetSize != null) 'jet_size': jetSize,
        },
      );

  Future<void> logBookingCompleted({
    required String bookingId,
    String? flightId,
    double? amount,
    String? currency,
  }) =>
      _safeLog(
        'booking_completed',
        parameters: {
          'booking_id': bookingId,
          if (flightId != null) 'flight_id': flightId,
          if (amount != null) 'fb_value_to_sum': amount,
          if (currency != null) 'fb_currency': currency,
        },
      );

  /// Logs `fb_mobile_purchase` (the Meta standard purchase event) so the
  /// campaign can optimize / report on revenue.
  Future<void> logPaymentSuccess({
    required double amount,
    required String currency,
    String? bookingId,
    String? paymentMethod,
  }) async {
    if (!_initialized) await initialize();
    try {
      await _fb.logPurchase(
        amount: amount,
        currency: currency,
        parameters: {
          if (bookingId != null) 'booking_id': bookingId,
          if (paymentMethod != null) 'payment_method': paymentMethod,
        },
      );
      _debug('event=$_evtPurchase amount=$amount currency=$currency');
    } catch (e) {
      _debug('logPurchase failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _safeLog(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) await initialize();
    try {
      final cleaned = _sanitize(parameters);
      await _fb.logEvent(name: name, parameters: cleaned);
      _debug('event=$name params=$cleaned');
    } catch (e) {
      _debug('logEvent($name) failed: $e');
    }
  }

  /// Drops null values and any obviously sensitive keys before sending to Meta.
  Map<String, Object>? _sanitize(Map<String, Object?>? input) {
    if (input == null || input.isEmpty) return null;
    const blocked = {'password', 'token', 'api_token', 'email', 'phone'};
    final out = <String, Object>{};
    input.forEach((k, v) {
      if (v == null) return;
      if (blocked.contains(k.toLowerCase())) return;
      out[k] = v;
    });
    return out.isEmpty ? null : out;
  }

  void _debug(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[FacebookEvents] $msg');
    }
  }
}
