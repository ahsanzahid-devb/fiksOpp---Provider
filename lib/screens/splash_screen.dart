import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/generated/assets.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/screens/maintenance_mode_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../components/app_widgets.dart';
import '../networks/rest_apis.dart';
import '../utils/constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool appNotSynced = false;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      setStatusBarColor(
        Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness:
            appStore.isDarkMode ? Brightness.light : Brightness.dark,
      );

      init();
    });
  }

  Future<void> init() async {
    await getAppConfigurations().then((value) {}).catchError((e) async {
      if (!await isNetworkAvailable()) {
        toast(errorInternetNotAvailable);
      }
      log(e.toString());
    });

    if (!mounted) return;

    appStore.setLoading(false);

    /// If app configuration failed
    if (!getBoolAsync(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE)) {
      appNotSynced = true;
      setState(() {});
      return;
    }

    /// Load selected language
    appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE),
      context: context,
    );

    /// Apply theme mode
    int themeModeIndex = getIntAsync(
      THEME_MODE_INDEX,
      defaultValue: THEME_MODE_SYSTEM,
    );
    if (themeModeIndex == THEME_MODE_SYSTEM) {
      appStore.setDarkMode(
        MediaQuery.of(context).platformBrightness == Brightness.dark,
      );
    }

    /// Maintenance mode check
    if (appConfigurationStore.maintenanceModeStatus) {
      if (!mounted) return;
      MaintenanceModeScreen().launch(
        context,
        pageRouteAnimation: PageRouteAnimation.Fade,
      );
      return;
    }

    /// If user unauthorized but logged in
    if (!appConfigurationStore.isUserAuthorized && appStore.isLoggedIn) {
      await clearPreferences();
    }

    if (!mounted) return;

    /// Handle navigation
    if (!appStore.isLoggedIn) {
      SignInScreen().launch(
        context,
        isNewTask: true,
        pageRouteAnimation: PageRouteAnimation.Fade,
      );
    } else {
       updateProfilePhoto();
      attachFcmTokenRefreshSync();
      syncFcmTokenWithBackend();

      if (!mounted) return;

      if (isUserTypeProvider) {
        setStatusBarColor(primaryColor);
        ProviderDashboardScreen(index: 0).launch(
          context,
          isNewTask: true,
          pageRouteAnimation: PageRouteAnimation.Fade,
        );
      } else if (isUserTypeHandyman) {
        setStatusBarColor(primaryColor);
        HandymanDashboardScreen(index: 0).launch(
          context,
          isNewTask: true,
          pageRouteAnimation: PageRouteAnimation.Fade,
        );
      } else {
        SignInScreen().launch(context, isNewTask: true);
      }
    }
  }

  Future<void> updateProfilePhoto() async {
    await getUserDetail(appStore.userId).then((value) async {
      final data = value.data;
      if (data != null) {
        await appStore.setUserProfile(data.profileImage.validate());
      }
    }).catchError((e) {
      log('Error updating profile photo: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSystemDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bgColor = isSystemDark ? scaffoldColorDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.image,
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              if (appNotSynced)
                Observer(
                  builder: (_) {
                    return appStore.isLoading
                        ? LoaderWidget().center()
                        : TextButton(
                            child: Text(
                              languages.reload,
                              style: boldTextStyle(),
                            ),
                            onPressed: () {
                              appStore.setLoading(true);
                              init();
                            },
                          );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
