import 'dart:async';
import 'dart:developer' as developer;
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_uni_links/uni_links.dart';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  StreamSubscription? _sub;
  Uri? _pendingInitialUri;

  /// Call this once (after app is built is safe).
  Future<void> init() async {
    _sub?.cancel();

    try {
      _pendingInitialUri = await getInitialUri();
    } catch (_) {
      _pendingInitialUri = null;
    }

    developer.log(
      'DeepLinkService init',
      name: 'DeepLinkService',
      error: _pendingInitialUri == null
          ? 'initialUri is null'
          : 'initialUri detected: scheme=${_pendingInitialUri!.scheme}',
    );

    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;
      _handleUri(uri);
    }, onError: (Object error) {
      log('DeepLinkService uriLinkStream error: $error');
    });

    // Try routing immediately if we already have a Navigator context.
    final context = navigatorKey.currentContext;
    if (_pendingInitialUri != null && context != null) {
      _handleUri(_pendingInitialUri!);
      _pendingInitialUri = null;
      return;
    }

    // Otherwise, wait until the widget tree is built.
    afterBuildCreated(() {
      if (_pendingInitialUri != null) {
        _handleUri(_pendingInitialUri!);
        _pendingInitialUri = null;
      }
    });
  }

  void _handleUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final query = uri.queryParameters;
    final emailParam =
        query['email'] ?? query['user_email'] ?? query['emailAddress'];

    developer.log(
      'DeepLinkService received uri',
      name: 'DeepLinkService',
      error:
          'scheme=$scheme host=$host path=$path queryKeys=${query.keys.toList()} emailParamPresent=${emailParam != null && emailParam.isNotEmpty}',
    );

    // Expected link examples we can support:
    // - fiksopp://verify-email?email=someone@example.com
    // - https://fiksopp.inoor.buzz/verify-email?email=someone@example.com
    // If your backend uses a different URL format, we can tweak this matcher.
    final isEmailVerification = (scheme == 'fiksopp' &&
            (host.contains('verify') || path.contains('verify'))) ||
        (path.contains('verify-email') || path.contains('verify_email')) ||
        (query['mode']?.toLowerCase().contains('verify') ?? false);

    if (!isEmailVerification) {
      developer.log(
        'DeepLinkService not a verify-email link',
        name: 'DeepLinkService',
        error: 'scheme=$scheme host=$host path=$path',
      );
      return;
    }

    final email =
        query['email'] ?? query['user_email'] ?? query['emailAddress'];

    final context = navigatorKey.currentContext;
    if (context == null) return;

    developer.log(
      'DeepLinkService matched verify-email link',
      name: 'DeepLinkService',
      error:
          'emailProvided=${email != null && email.isNotEmpty} emailMasked=${_maskEmail(email)}',
    );

    SignInScreen(initialEmail: email).launch(context, isNewTask: true);

    developer.log(
      'DeepLinkService navigating to SignInScreen',
      name: 'DeepLinkService',
      error: 'launch complete called',
    );
  }

  String _maskEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'null';
    final e = email.trim();
    final parts = e.split('@');
    if (parts.length != 2) return '${e.substring(0, 1)}***';
    final local = parts[0];
    final domain = parts[1];
    final firstChar = local.isNotEmpty ? local.substring(0, 1) : '';
    return '$firstChar***@$domain';
  }
}
