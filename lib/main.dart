import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:handyman_provider_flutter/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/locale/applocalizations.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';
import 'package:handyman_provider_flutter/locale/language_en.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/models/revenue_chart_data.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/models/wallet_history_list_response.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/auth_services.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/chat_messages_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/notification_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/user_services.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/screens/splash_screen.dart';
import 'package:handyman_provider_flutter/services/in_app_purchase.dart';
import 'package:handyman_provider_flutter/store/AppStore.dart';
import 'package:handyman_provider_flutter/store/filter_store.dart';
import 'package:handyman_provider_flutter/store/roles_and_permission_store.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/deep_link_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'app_theme.dart';
import 'helpDesk/model/help_desk_response.dart';
import 'models/bank_list_response.dart';
import 'models/booking_list_response.dart';
import 'models/booking_status_response.dart';
import 'models/dashboard_response.dart';
import 'models/document_list_response.dart';
import 'models/extra_charges_model.dart';
import 'models/handyman_dashboard_response.dart';
import 'models/payment_list_reasponse.dart';
import 'models/service_model.dart';
import 'provider/promotional_banner/model/promotional_banner_response.dart';
import 'provider/timeSlots/timeSlotStore/time_slot_store.dart';
import 'store/app_configuration_store.dart';
import 'utils/firebase_messaging_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//region Handle Background Firebase Message
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logFcmTracking('background_handler_received', message: message);
  log('Message Data : ${message.data}');
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    logFcmTracking('background_handler_initialized_firebase', message: message);
  }

  final String title = message.notification?.title.validate().isNotEmpty == true
      ? message.notification!.title.validate()
      : (message.data['title']?.toString().validate().isNotEmpty == true
          ? message.data['title'].toString().validate()
          : message.data['subject']?.toString().validate() ?? '');

  final String body = message.notification?.body.validate().isNotEmpty == true
      ? message.notification!.body.validate()
      : (message.data['body']?.toString().validate().isNotEmpty == true
          ? message.data['body'].toString().validate()
          : message.data['message']?.toString().validate() ?? '');

  final String finalTitle = title.isNotEmpty ? title : 'FiksOpp';
  final String finalBody =
      body.isNotEmpty ? body : 'You have a new notification';

 
  if (message.notification != null) {
    logFcmTracking('background_handler_notification_block_skip_local',
        message: message);
    return;
  }

  if (message.data.isNotEmpty) {
    logFcmTracking('background_handler_show_local_notification',
        message: message);
    showNotification(
      currentTimeStamp(),
      finalTitle,
      parseHtmlString(finalBody),
      message,
    );
  } else {
    logFcmTracking('background_handler_empty_data_payload', message: message);
  }
  logFcmTracking('background_handler_completed', message: message);
}
//endregion

//region Mobx Stores
AppStore appStore = AppStore();
TimeSlotStore timeSlotStore = TimeSlotStore();
AppConfigurationStore appConfigurationStore = AppConfigurationStore();
FilterStore filterStore = FilterStore();
RolesAndPermissionStore rolesAndPermissionStore = RolesAndPermissionStore();
//endregion

//region Firebase Services
UserService userService = UserService();
AuthService authService = AuthService();

ChatServices chatServices = ChatServices();
NotificationService notificationService = NotificationService();
//endregion

//region In App Purchase Service
InAppPurchaseService inAppPurchaseService = InAppPurchaseService();
//endregion

//region Global Variables
Languages languages = LanguageEn();
List<RevenueChartData> chartData = [];
List<ExtraChargesModel> chargesList = [];
DashboardResponse? cachedProviderDashboardResponse;
HandymanDashBoardResponse? cachedHandymanDashboardResponse;
List<BookingData>? cachedBookingList;
List<PaymentData>? cachedPaymentList;
List<NotificationData>? cachedNotifications;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<(int serviceId, ServiceDetailResponse)?> listOfCachedData = [];
List<BookingDetailResponse> cachedBookingDetailList = [];
List<(int postJobId, PostJobDetailResponse)?> cachedPostJobList = [];
List<UserData>? cachedHandymanList;
List<TotalData>? cachedTotalDataList;
List<WalletHistory>? cachedWalletList;
List<BankHistory>? cachedBankList;
List<HelpDeskListData>? cachedHelpDeskListData;
List<PromotionalBannerListData>? cachedPromotionalBannerListData;
List<ServiceData>? cachedServiceData;
List<UserData>? cachedUserData;
DocumentListResponse? cachedDocumentListResponse;

//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  if (!isDesktop) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
      if (kReleaseMode) {
        FlutterError.onError = (FlutterErrorDetails details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };
      }
      // After Firebase.initializeApp; before subscribeToFirebaseTopic (FCM v1).
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      logFcmTracking('background_handler_registered');
      
      await subscribeToFirebaseTopic();
    } catch (e) {
      log('Firebase setup failed: $e');
    }
  }
  HttpOverrides.global = MyHttpOverrides();

  defaultSettings();

  localeLanguageList = languageList();

  appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// iOS often receives APNS after the first cold-start subscribe attempt; retry
  /// when returning to foreground (no-op on Android / if already subscribed).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logFcmTracking('app_lifecycle_state_changed', note: state.name);
    if (state == AppLifecycleState.resumed && !isDesktop) {
      logFcmTracking('app_resumed_retry_topic_subscription');
      trySubscribeFirebaseTopicsOnIosResume();
    }
  }

  void init() async {
    afterBuildCreated(() {
      // Handle app routing from deep links (e.g., email verification link).
      DeepLinkService.instance.init();

      int val = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);

      if (val == THEME_MODE_LIGHT) {
        appStore.setDarkMode(false);
      } else if (val == THEME_MODE_DARK) {
        appStore.setDarkMode(true);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: SplashScreen(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return MediaQuery(
              child: child!,
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
            );
          },
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
