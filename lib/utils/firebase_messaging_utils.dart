import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/bid_list_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../provider/services/service_detail_screen.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/chat/user_chat_list_screen.dart';
import 'constant.dart';

bool _topicRetryOnFcmTokenRefreshAttached = false;

/// FCM tracking event guide (search logs by `FCM_TRACKING:`):
/// - init/permission/listener: setup stages.
/// - on_message_foreground_*: received while app is open.
/// - on_message_opened_app: notification tap when app is in background.
/// - get_initial_message_opened_app: notification tap that launches a killed app.
/// - background_handler_*: message processing in background isolate.
/// - notification_click_*: routing decision after a notification click.
/// - show_local_notification: local notification shown by the app.
void logFcmTracking(String event, {RemoteMessage? message, String? note}) {
  final backendData = message?.data ?? const <String, dynamic>{};
  final payload = <String, dynamic>{
    'event': event,
    'messageId': message?.messageId,
    'from': message?.from,
    'sentTime': message?.sentTime?.toIso8601String(),
    'hasNotificationBlock': message?.notification != null,
    'dataKeys': message?.data.keys.toList(),
    'data': message?.data,
    'backendType': backendData['type'],
    'backendNotificationType':
        backendData['notification-type'] ?? backendData['notification_type'],
    'backendActivityType': backendData['activity_type'],
    'backendId': backendData['id'],
    'backendBookingId': backendData['booking_id'],
    'backendClickAction': backendData['click_action'],
    if (note != null && note.isNotEmpty) 'note': note,
  };
  log('FCM_TRACKING: ${jsonEncode(payload)}');
}

void _attachTopicRetryOnFcmTokenRefresh() {
  if (_topicRetryOnFcmTokenRefreshAttached || Firebase.apps.isEmpty) return;
  _topicRetryOnFcmTokenRefreshAttached = true;
  FirebaseMessaging.instance.onTokenRefresh.listen((_) {
    logFcmTracking('fcm_token_refresh_retry_topics');
    trySubscribeFirebaseTopicsWhenPossible();
  });
}

/// Subscribes to FCM topics when safe (APNS ready on iOS). Used after token refresh.
Future<void> trySubscribeFirebaseTopicsWhenPossible() async {
  if (Firebase.apps.isEmpty || !appStore.isLoggedIn) {
    logFcmTracking(
      'try_subscribe_topics_skipped',
      note:
          'firebaseAppsEmpty=${Firebase.apps.isEmpty}, isLoggedIn=${appStore.isLoggedIn}',
    );
    return;
  }
  try {
    if (Platform.isIOS) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns == null || apns.isEmpty) {
        logFcmTracking('try_subscribe_topics_ios_apns_missing');
        return;
      }
      logFcmTracking('try_subscribe_topics_ios_apns_available');
    }
    await _subscribeFirebaseTopicsCore();
    logFcmTracking('try_subscribe_topics_success');
  } catch (e) {
    log('trySubscribeFirebaseTopicsWhenPossible: $e');
    logFcmTracking('try_subscribe_topics_error', note: e.toString());
  }
}

DateTime? _lastIosResumeTopicTry;

/// Called from [WidgetsBindingObserver.didChangeAppLifecycleState] on resume.
/// Throttled so we do not hit Firestore/FCM on every foreground transition.
Future<void> trySubscribeFirebaseTopicsOnIosResume() async {
  if (!Platform.isIOS || Firebase.apps.isEmpty || !appStore.isLoggedIn) {
    logFcmTracking(
      'ios_resume_topic_try_skipped',
      note:
          'isIOS=${Platform.isIOS}, firebaseAppsEmpty=${Firebase.apps.isEmpty}, isLoggedIn=${appStore.isLoggedIn}',
    );
    return;
  }
  final now = DateTime.now();
  if (_lastIosResumeTopicTry != null &&
      now.difference(_lastIosResumeTopicTry!) < const Duration(seconds: 20)) {
    logFcmTracking('ios_resume_topic_try_throttled');
    return;
  }
  _lastIosResumeTopicTry = now;
  logFcmTracking('ios_resume_topic_try_start');
  await trySubscribeFirebaseTopicsWhenPossible();
}

Future<String?> _pollIosApnsToken({
  required Duration timeout,
  Duration interval = const Duration(milliseconds: 450),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final t = await FirebaseMessaging.instance.getAPNSToken();
    if (t != null && t.isNotEmpty) return t;
    await Future<void>.delayed(interval);
  }
  return null;
}

Future<void> _deferIosTopicSubscriptionRetries() async {
  const delays = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 3),
    Duration(seconds: 5),
    Duration(seconds: 8),
    Duration(seconds: 10),
    Duration(seconds: 15),
  ];
  for (final d in delays) {
    await Future<void>.delayed(d);
    if (!appStore.isLoggedIn || Firebase.apps.isEmpty) {
      logFcmTracking('ios_deferred_topic_retry_stopped',
          note:
              'isLoggedIn=${appStore.isLoggedIn}, firebaseAppsEmpty=${Firebase.apps.isEmpty}');
      return;
    }
    try {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null && apns.isNotEmpty) {
        await _subscribeFirebaseTopicsCore();
        logFcmTracking('ios_deferred_topic_retry_success');
        if (kDebugMode) {
          log('subscribeToFirebaseTopic: topics subscribed after delayed APNS registration');
        }
        return;
      }
      logFcmTracking('ios_deferred_topic_retry_apns_missing');
    } catch (e) {
      logFcmTracking('ios_deferred_topic_retry_error', note: e.toString());
      if (kDebugMode) {
        log('subscribeToFirebaseTopic delayed retry: $e');
      }
    }
  }
  if (kDebugMode) {
    log('subscribeToFirebaseTopic: APNS token still unavailable (e.g. simulator or missing Push capability). Topics not subscribed.');
  }
}

Future<void> _subscribeFirebaseTopicsCore() async {
  logFcmTracking('subscribe_topics_core_start',
      note: 'userId=${appStore.userId}');
  await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
  log('topic-----subscribed----> user_${appStore.userId}');
  final topicTag = isUserTypeHandyman ? HANDYMAN_APP_TAG : PROVIDER_APP_TAG;
  await FirebaseMessaging.instance.subscribeToTopic(topicTag);
  log('topic-----subscribed----> $topicTag');
  await appStore.setPushNotificationSubscriptionStatus(true);
  logFcmTracking('subscribe_topics_core_complete', note: 'topicTag=$topicTag');
}

Future<void> initFirebaseMessaging() async {
  if (Firebase.apps.isEmpty) {
    log('initFirebaseMessaging: skipped (Firebase not initialized)');
    return;
  }
  logFcmTracking('init_firebase_messaging_start');
  await FirebaseMessaging.instance
      .requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  )
      .then((value) async {
    logFcmTracking(
      'notification_permission_result',
      note: value.authorizationStatus.name,
    );
    if (value.authorizationStatus == AuthorizationStatus.authorized) {
      await registerNotificationListeners().catchError((e) {
        log('------Notification Listener REGISTRATION ERROR-----------');
        log('Notification Listener Registration Error: $e');
      });

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true)
              
          .catchError((e) {
        log('------setForegroundNotificationPresentationOptions ERROR-----------');
      });

      _attachTopicRetryOnFcmTokenRefresh();
    }
  });
}

Future<void> registerNotificationListeners() async {
  if (Firebase.apps.isEmpty) return;
  log('registerNotificationListeners: Firebase.apps.isEmpty: ${Firebase.apps.isEmpty}');
  FirebaseMessaging.instance.setAutoInitEnabled(true).then((_) {
    logFcmTracking('register_notification_listeners_ready',
        note: 'autoInitEnabled=true');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logFcmTracking('on_message_foreground_received', message: message);
      final String title =
          message.notification?.title.validate().isNotEmpty == true
              ? message.notification!.title.validate()
              : (message.data['title']?.toString().validate().isNotEmpty == true
                  ? message.data['title'].toString().validate()
                  : message.data['subject']?.toString().validate() ?? '');

      final String body =
          message.notification?.body.validate().isNotEmpty == true
              ? message.notification!.body.validate()
              : (message.data['body']?.toString().validate().isNotEmpty == true
                  ? message.data['body'].toString().validate()
                  : message.data['message']?.toString().validate() ?? '');

      final String finalTitle = title.isNotEmpty ? title : 'FiksOpp';
      final String finalBody =
          body.isNotEmpty ? body : 'You have a new notification';

      if (Platform.isIOS && message.notification != null) {
        return;
      }

      if (message.notification != null || message.data.isNotEmpty) {
        logFcmTracking('on_message_foreground_show_local_notification',
            message: message);
        showNotification(
          currentTimeStamp(),
          finalTitle,
          parseHtmlString(finalBody),
          message,
        );
      }
    }, onError: (e) {
      log("setAutoInitEnabled error $e");
      logFcmTracking('on_message_foreground_listener_error', note: e.toString());
    });
  
     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logFcmTracking('on_message_opened_app', message: message);
      handleNotificationClick(message);
    }, onError: (e) {
      log("onMessageOpenedApp Error $e");
      logFcmTracking('on_message_opened_app_error', note: e.toString());
    });

     FirebaseMessaging.instance.getInitialMessage().then(
        (RemoteMessage? message) {
      if (message != null) {
        logFcmTracking('get_initial_message_opened_app', message: message);
        handleNotificationClick(message);
      } else {
        logFcmTracking('get_initial_message_empty');
      }
    }, onError: (e) {
      log("getInitialMessage error : $e");
      logFcmTracking('get_initial_message_error', note: e.toString());
    });
  }).onError((error, stackTrace) {
    log("onGetInitialMessage error: $error");
    logFcmTracking('register_notification_listeners_error',
        note: error.toString());
  });
}

Future<bool> subscribeToFirebaseTopic() async {
  if (Firebase.apps.isEmpty) {
    log('subscribeToFirebaseTopic: skipped (Firebase not initialized)');
    return appStore.isSubscribedForPushNotification;
  }
  bool result = appStore.isSubscribedForPushNotification;
  try {
    logFcmTracking('subscribe_to_firebase_topic_start',
        note:
            'isLoggedIn=${appStore.isLoggedIn}, isSubscribed=${appStore.isSubscribedForPushNotification}');
    await initFirebaseMessaging();
    if (!appStore.isLoggedIn) {
      logFcmTracking('subscribe_to_firebase_topic_skipped_not_logged_in');
      return result;
    }

    if (Platform.isIOS) {
      // Encourages native registration; may still return before APNS is ready.
      try {
        await FirebaseMessaging.instance.getToken();
      } catch (_) {}

      String? apnsToken = await _pollIosApnsToken(
        timeout: const Duration(seconds: 8),
      );
      apnsToken ??= await FirebaseMessaging.instance.getAPNSToken();
      logFcmTracking('subscribe_to_firebase_topic_ios_apns_check',
          note: 'apnsAvailable=${apnsToken != null && apnsToken.isNotEmpty}');
      if (kDebugMode) {
        log('Apn Token=========$apnsToken');
      }

      if (apnsToken == null || apnsToken.isEmpty) {
        if (kDebugMode) {
          log('subscribeToFirebaseTopic: APNS not ready yet; retrying in background '
              '(expected on iOS Simulator; use a real device for push)');
        }
        unawaited(_deferIosTopicSubscriptionRetries());
        logFcmTracking('subscribe_to_firebase_topic_ios_deferred_retry_started');
        return result;
      }
    }

    await _subscribeFirebaseTopicsCore();
    result = true;
    logFcmTracking('subscribe_to_firebase_topic_success');
  } catch (e) {
    log('subscribeToFirebaseTopic error: $e');
    logFcmTracking('subscribe_to_firebase_topic_error', note: e.toString());
  }
  return result;
}

Future<bool> unsubscribeFirebaseTopic(int userId) async {
  bool result = appStore.isSubscribedForPushNotification;
  if (Firebase.apps.isEmpty) {
    log('unsubscribeFirebaseTopic: skipped (Firebase not initialized)');
    return result;
  }
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('user_$userId')
      .then((_) {
    result = false;
    log("topic-----unsubscribed----> user_$userId");
    logFcmTracking('unsubscribe_user_topic_success', note: 'userId=$userId');
  });
  final topicTag = isUserTypeHandyman ? HANDYMAN_APP_TAG : PROVIDER_APP_TAG;
  await FirebaseMessaging.instance.unsubscribeFromTopic(topicTag).then((_) {
    result = false;
    log('topic-----unsubscribed---->------> $topicTag');
    logFcmTracking('unsubscribe_role_topic_success', note: 'topicTag=$topicTag');
  });

  await appStore.setPushNotificationSubscriptionStatus(result);
  logFcmTracking('unsubscribe_topics_complete',
      note: 'userId=$userId, topicTag=$topicTag, result=$result');
  return result;
}

/// Backend FCM v1 chat payloads use [type] == `chat_message`; legacy client sends `is_chat`.
bool isChatNotificationData(Map<String, dynamic> data) {
  if (data.containsKey('is_chat')) {
    final v = data['is_chat']?.toString().toLowerCase().trim();
    if (v == '1' || v == 'true') return true;
  }
  return data['type']?.toString() == 'chat_message';
}

/// FCM [data] may use a stringified [additional_data] map (legacy) or the same flat
/// keys as [notification_list_response] (`id`, `notification-type`, …).
Map<String, dynamic> notificationAdditionalDataFromFcmPayload(
    Map<String, dynamic> data) {
  if (data.containsKey('additional_data')) {
    try {
      final raw = data['additional_data'];
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      log('FCM additional_data decode failed: $e');
    }
  }
  if (data.containsKey('id') ||
      data.containsKey('notification-type') ||
      data.containsKey('notification_type') ||
      data.containsKey('activity_type') ||
      data.containsKey('check_booking_type')) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

bool _notificationTypeLooksLikeBooking(Map<String, dynamic> additionalData) {
  final nType = (additionalData['notification-type'] ??
          additionalData['notification_type'] ??
          additionalData['activity_type'])
      ?.toString()
      .validate()
      .toLowerCase();
  final checkType =
      additionalData['check_booking_type']?.toString().validate().toLowerCase();
  if (checkType == NOTIFICATION_TYPE_BOOKING || checkType == BOOKING) {
    return true;
  }
  if (nType != null &&
      (nType.contains(BOOKING) || nType.contains(PAYMENT_MESSAGE_STATUS))) {
    return true;
  }
  const bookingKeys = <String>{
    ADD_BOOKING,
    ASSIGNED_BOOKING,
    TRANSFER_BOOKING,
    UPDATE_BOOKING_STATUS,
    CANCEL_BOOKING,
    PAID_FOR_BOOKING,
  };
  if (nType != null && bookingKeys.any((k) => nType.contains(k))) return true;
  return false;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

void _pushIfNavigatorReady(Widget page, {int attempt = 0}) {
  final state = navigatorKey.currentState;
  if (state == null) {
    logFcmTracking('notification_navigation_waiting_navigator',
        note: 'attempt=$attempt');
    if (attempt < 6) {
      Future<void>.delayed(
        const Duration(milliseconds: 250),
        () => _pushIfNavigatorReady(page, attempt: attempt + 1),
      );
    } else {
      logFcmTracking('notification_navigation_failed_navigator_unavailable');
    }
    return;
  }
  logFcmTracking('notification_navigation_push',
      note: 'page=${page.runtimeType}');
  state.push(MaterialPageRoute(builder: (context) => page));
}

int? _bookingIdForDetailFromAdditionalData(
    Map<String, dynamic> additionalData) {
  final rawBooking = additionalData['booking_id'];
  if (rawBooking != null && rawBooking.toString().trim().isNotEmpty) {
    final n = int.tryParse(rawBooking.toString().trim());
    if (n != null && n > 0) return n;
  }
  final rawId = additionalData['id'];
  if (rawId == null) return null;
  final n = rawId is int ? rawId : int.tryParse(rawId.toString());
  if (n != null && n > 0) return n;
  return null;
}

void handleNotificationClick(RemoteMessage message) {
  if (_isDuplicateNotificationTap(message)) {
    logFcmTracking('notification_click_duplicate_ignored', message: message);
    return;
  }
  logFcmTracking('notification_click_received', message: message);

  if (message.data['url'] != null && message.data['url'] is String) {
    logFcmTracking('notification_click_open_external_url', message: message);
    commonLaunchUrl(message.data['url'],
        launchMode: LaunchMode.externalApplication);
    return;
  }
  if (isChatNotificationData(message.data)) {
    if (message.data.isNotEmpty) {
      logFcmTracking('notification_click_open_chat', message: message);
      _pushIfNavigatorReady(ChatListScreen());
    }
    return;
  }

  final Map<String, dynamic> additionalData =
      notificationAdditionalDataFromFcmPayload(message.data);
  if (additionalData.isEmpty) {
    logFcmTracking('notification_click_no_additional_data', message: message);
    return;
  }

  // Bid acceptance: backend sometimes omits id/booking_id; still open bid list.
  final resolvedNotificationType = (additionalData['notification-type'] ??
          additionalData['notification_type'] ??
          additionalData['activity_type'])
      ?.toString()
      .toLowerCase();
  if (resolvedNotificationType == USER_ACCEPT_BID) {
    logFcmTracking('notification_click_open_bid_list', message: message);
    _pushIfNavigatorReady(BidListScreen());
    return;
  }

  final int? resolvedId = _bookingIdForDetailFromAdditionalData(additionalData);
  if (resolvedId != null) {
    if (_notificationTypeLooksLikeBooking(additionalData)) {
      logFcmTracking('notification_click_open_booking_detail',
          message: message, note: 'bookingId=$resolvedId');
      _pushIfNavigatorReady(BookingDetailScreen(bookingId: resolvedId));
      return;
    }
  }

  final int? serviceId = _asInt(additionalData['service_id']);
  if (serviceId != null && serviceId > 0) {
    logFcmTracking('notification_click_open_service_detail',
        message: message, note: 'serviceId=$serviceId');
    _pushIfNavigatorReady(ServiceDetailScreen(serviceId: serviceId));
    return;
  }
  logFcmTracking('notification_click_no_navigation_match', message: message);
}

String? _lastHandledNotificationKey;
DateTime? _lastHandledNotificationAt;

bool _isDuplicateNotificationTap(RemoteMessage message) {
  final key = message.messageId?.trim().isNotEmpty == true
      ? message.messageId!.trim()
      : jsonEncode(message.data);

  final now = DateTime.now();
  if (_lastHandledNotificationKey == key &&
      _lastHandledNotificationAt != null &&
      now.difference(_lastHandledNotificationAt!) <
          const Duration(seconds: 2)) {
    logFcmTracking('notification_tap_duplicate_detected', message: message);
    return true;
  }

  _lastHandledNotificationKey = key;
  _lastHandledNotificationAt = now;
  logFcmTracking('notification_tap_marked_unique', message: message);
  return false;
}

void showNotification(
    int id, String title, String message, RemoteMessage remoteMessage) async {
  logFcmTracking('show_local_notification', message: remoteMessage);
  log('Notification : ${remoteMessage.notification?.toMap()}');
  log('Message Data : ${remoteMessage.data}');
  log("Provider Message Image Url : ${remoteMessage.data["image_url"]} ");
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //code for background notification channel
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'notification',
    'Notification',
    importance: Importance.high,
    enableLights: true,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_stat_ic_notification');
  var iOS = const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  var macOS = iOS;
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      handleNotificationClick(remoteMessage);
    },
  );

  // region image logic
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  BigPictureStyleInformation? bigPictureStyleInformation =
      remoteMessage.data.containsKey("image_url")
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(await _downloadAndSaveFile(
                  remoteMessage.data["image_url"], 'bigPicture')),
              largeIcon: FilePathAndroidBitmap(await _downloadAndSaveFile(
                  remoteMessage.data["image_url"], 'largeIcon')),
            )
          : null;
  // endregion

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'notification',
    'Notification',
    importance: Importance.high,
    visibility: NotificationVisibility.public,
    autoCancel: true,
    playSound: true,
    priority: Priority.high,
    icon: '@drawable/ic_stat_ic_notification',
    largeIcon: remoteMessage.data.containsKey("image_url")
        ? FilePathAndroidBitmap(await _downloadAndSaveFile(
            remoteMessage.data["image_url"], 'largeIcon'))
        : null,
    styleInformation: remoteMessage.data.containsKey("image_url")
        ? bigPictureStyleInformation
        : null,
  );

  var darwinPlatformChannelSpecifics = const DarwinNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinPlatformChannelSpecifics,
    macOS: darwinPlatformChannelSpecifics,
  );

  flutterLocalNotificationsPlugin.show(
      id, title.validate(), message.validate(), platformChannelSpecifics);
}
