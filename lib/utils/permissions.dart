import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import '../main.dart';
import 'constant.dart';

class Permissions {
  static PermissionHandlerPlatform get _handler =>
      PermissionHandlerPlatform.instance;
  static const String _lastPermissionSettingsRedirectAt =
      'lastPermissionSettingsRedirectAt';

  static Future<bool> _isLocationAccessGranted() async {
    final loc = await Permission.location.status;
    if (loc.isGranted || loc.isLimited) return true;
    if (isIOS) {
      final whenInUse = await Permission.locationWhenInUse.status;
      if (whenInUse.isGranted || whenInUse.isLimited) return true;
    }
    return false;
  }

  /// In-app prompt + system request so bidding is blocked until location is allowed (TC-06).
  static Future<bool> ensureLocationForBid(BuildContext context) async {
    if (kDebugMode) {
      final loc = await Permission.location.status;
      final whenInUse =
          isIOS ? await Permission.locationWhenInUse.status : loc;
      developer.log(
        'ensureLocationForBid: Android/iOS device permission — '
        'Permission.location=$loc '
        '${isIOS ? "Permission.locationWhenInUse=$whenInUse " : ""}'
        '(granted/limited counts as OK)',
        name: 'PostJobBid',
      );
    }

    if (await _isLocationAccessGranted()) {
      if (kDebugMode) {
        developer.log(
          'ensureLocationForBid: device location permission OK → proceed',
          name: 'PostJobBid',
        );
      }
      await setValue(PERMISSION_STATUS, true);
      return true;
    }

    if (kDebugMode) {
      developer.log(
        'ensureLocationForBid: device location NOT granted — will prompt or open settings',
        name: 'PostJobBid',
      );
    }

    if (!context.mounted) return false;

    final loc = await Permission.location.status;
    final whenInUse =
        isIOS ? await Permission.locationWhenInUse.status : loc;
    final permanentlyDenied = loc.isPermanentlyDenied ||
        (isIOS && whenInUse.isPermanentlyDenied);
    final restricted = loc.isRestricted ||
        (isIOS && whenInUse.isRestricted);

    if (restricted) {
      if (context.mounted) {
        toast(languages.lblLocationNeededForBidMessage);
      }
      return false;
    }

    if (permanentlyDenied) {
      final openSettings = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: Text(languages.youHavePermanentlyDenied),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(languages.lblNo),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(languages.lblYes),
            ),
          ],
        ),
      );
      if (openSettings == true) openAppSettings();
      return false;
    }

    final go = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(languages.lblLocationNeededForBidTitle),
        content: Text(languages.lblLocationNeededForBidMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(languages.lblCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(languages.lblAllowLocation),
          ),
        ],
      ),
    );

    if (go != true || !context.mounted) return false;

    final granted = await locationPermissionsGranted();
    if (!granted && context.mounted) {
      toast(languages.lblLocationNeededForBidMessage);
    }
    return granted;
  }

  static Future<bool> locationPermissionsGranted() async {
    // Must match _isLocationAccessGranted: iOS "approximate only" is .limited, not .granted.
    if (await _isLocationAccessGranted()) {
      await setValue(PERMISSION_STATUS, true);
      return true;
    }

    Map<Permission, PermissionStatus> locationPermissionStatus = await _handler
        .requestPermissions([
          Permission.location,
          if (isIOS) Permission.locationWhenInUse,
        ]);

    final statuses = locationPermissionStatus.values.toList();
    final hasAccess = statuses.any(
      (element) => element.isGranted || element.isLimited,
    );
    final hasPermanentlyDenied = statuses.any(
      (element) => element == PermissionStatus.permanentlyDenied,
    );

    if (hasPermanentlyDenied) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastRedirectAt = getIntAsync(_lastPermissionSettingsRedirectAt);
      if (now - lastRedirectAt > 15000) {
        await setValue(_lastPermissionSettingsRedirectAt, now);
        openAppSettings();
      }
    }

    await setValue(PERMISSION_STATUS, hasAccess);
    return hasAccess;
  }
}
