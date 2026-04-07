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

void _attachTopicRetryOnFcmTokenRefresh() {
  if (_topicRetryOnFcmTokenRefreshAttached || Firebase.apps.isEmpty) return;
  _topicRetryOnFcmTokenRefreshAttached = true;
  FirebaseMessaging.instance.onTokenRefresh.listen((_) {
    trySubscribeFirebaseTopicsWhenPossible();
  });
}

/// Subscribes to FCM topics when safe (APNS ready on iOS). Used after token refresh.
Future<void> trySubscribeFirebaseTopicsWhenPossible() async {
  if (Firebase.apps.isEmpty || !appStore.isLoggedIn) return;
  try {
    if (Platform.isIOS) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns == null || apns.isEmpty) return;
    }
    await _subscribeFirebaseTopicsCore();
  } catch (e) {
    log('trySubscribeFirebaseTopicsWhenPossible: $e');
  }
}

DateTime? _lastIosResumeTopicTry;

/// Called from [WidgetsBindingObserver.didChangeAppLifecycleState] on resume.
/// Throttled so we do not hit Firestore/FCM on every foreground transition.
Future<void> trySubscribeFirebaseTopicsOnIosResume() async {
  if (!Platform.isIOS || Firebase.apps.isEmpty || !appStore.isLoggedIn) return;
  final now = DateTime.now();
  if (_lastIosResumeTopicTry != null &&
      now.difference(_lastIosResumeTopicTry!) < const Duration(seconds: 20)) {
    return;
  }
  _lastIosResumeTopicTry = now;
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
    if (!appStore.isLoggedIn || Firebase.apps.isEmpty) return;
    try {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null && apns.isNotEmpty) {
        await _subscribeFirebaseTopicsCore();
        if (kDebugMode) {
          log('subscribeToFirebaseTopic: topics subscribed after delayed APNS registration');
        }
        return;
      }
    } catch (e) {
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
  await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
  log('topic-----subscribed----> user_${appStore.userId}');
  final topicTag = isUserTypeHandyman ? HANDYMAN_APP_TAG : PROVIDER_APP_TAG;
  await FirebaseMessaging.instance.subscribeToTopic(topicTag);
  log('topic-----subscribed----> $topicTag');
  await appStore.setPushNotificationSubscriptionStatus(true);
}

Future<void> initFirebaseMessaging() async {
  if (Firebase.apps.isEmpty) {
    log('initFirebaseMessaging: skipped (Firebase not initialized)');
    return;
  }
  await FirebaseMessaging.instance
      .requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  )
      .then((value) async {
    if (value.authorizationStatus == AuthorizationStatus.authorized) {
      await registerNotificationListeners().catchError((e) {
        log('------Notification Listener REGISTRATION ERROR-----------');
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
  FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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

      if (message.notification != null || message.data.isNotEmpty) {
        showNotification(
          currentTimeStamp(),
          finalTitle,
          parseHtmlString(finalBody),
          message,
        );
      }
    }, onError: (e) {
      log("setAutoInitEnabled error $e");
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    }, onError: (e) {
      log("onMessageOpenedApp Error $e");
    });

    // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then(
        (RemoteMessage? message) {
      if (message != null) {
        handleNotificationClick(message);
      }
    }, onError: (e) {
      log("getInitialMessage error : $e");
    });
  }).onError((error, stackTrace) {
    log("onGetInitialMessage error: $error");
  });
}

Future<bool> subscribeToFirebaseTopic() async {
  if (Firebase.apps.isEmpty) {
    log('subscribeToFirebaseTopic: skipped (Firebase not initialized)');
    return appStore.isSubscribedForPushNotification;
  }
  bool result = appStore.isSubscribedForPushNotification;
  try {
    await initFirebaseMessaging();
    if (!appStore.isLoggedIn) return result;

    if (Platform.isIOS) {
      // Encourages native registration; may still return before APNS is ready.
      try {
        await FirebaseMessaging.instance.getToken();
      } catch (_) {}

      String? apnsToken = await _pollIosApnsToken(
        timeout: const Duration(seconds: 8),
      );
      apnsToken ??= await FirebaseMessaging.instance.getAPNSToken();
      if (kDebugMode) {
        log('Apn Token=========$apnsToken');
      }

      if (apnsToken == null || apnsToken.isEmpty) {
        if (kDebugMode) {
          log('subscribeToFirebaseTopic: APNS not ready yet; retrying in background '
              '(expected on iOS Simulator; use a real device for push)');
        }
        unawaited(_deferIosTopicSubscriptionRetries());
        return result;
      }
    }

    await _subscribeFirebaseTopicsCore();
    result = true;
  } catch (e) {
    log('subscribeToFirebaseTopic error: $e');
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
  });
  final topicTag = isUserTypeHandyman ? HANDYMAN_APP_TAG : PROVIDER_APP_TAG;
  await FirebaseMessaging.instance.unsubscribeFromTopic(topicTag).then((_) {
    result = false;
    log('topic-----unsubscribed---->------> $topicTag');
  });

  await appStore.setPushNotificationSubscriptionStatus(result);
  return result;
}

void handleNotificationClick(RemoteMessage message) {
  if (message.data['url'] != null && message.data['url'] is String) {
    commonLaunchUrl(message.data['url'],
        launchMode: LaunchMode.externalApplication);
  }
  if (message.data.containsKey('is_chat')) {
    if (message.data.isNotEmpty) {
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (context) => ChatListScreen()));
      // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => UserChatScreen(receiverUser: UserData.fromJson(message.data))));
    }
  } else if (message.data.containsKey('additional_data')) {
    Map<String, dynamic> additionalData =
        jsonDecode(message.data["additional_data"]) ?? {};
    if (additionalData.containsKey('id') && additionalData['id'] != null) {
      if (additionalData.containsKey('check_booking_type') &&
          additionalData['check_booking_type'] == 'booking') {
        navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) =>
                BookingDetailScreen(bookingId: additionalData['id'].toInt())));
      }

      if (additionalData.containsKey('notification-type') &&
          additionalData['notification-type'] == 'user_accept_bid') {
        navigatorKey.currentState!
            .push(MaterialPageRoute(builder: (context) => BidListScreen()));
      }
    }

    if (additionalData.containsKey('service_id') &&
        additionalData["service_id"] != null) {
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(
              serviceId: additionalData["service_id"].toInt())));
    }
  }
}

void showNotification(
    int id, String title, String message, RemoteMessage remoteMessage) async {
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
