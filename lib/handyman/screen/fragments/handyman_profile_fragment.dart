import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/change_password_screen.dart';
import 'package:handyman_provider_flutter/auth/edit_profile_screen.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/theme_selection_dailog.dart';
import 'package:handyman_provider_flutter/handyman/component/handyman_comission_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/about_us_screen.dart';
import 'package:handyman_provider_flutter/screens/languages_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/firebase_messaging_utils.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/base_scaffold_widget.dart';
import '../../../helpDesk/help_desk_list_screen.dart';
import '../../../provider/wallet/wallet_history_screen.dart';

class HandymanProfileFragment extends StatefulWidget {
  @override
  _HandymanProfileFragmentState createState() => _HandymanProfileFragmentState();
}

class _HandymanProfileFragmentState extends State<HandymanProfileFragment> {
  UniqueKey keyForExperienceWidget = UniqueKey();
  bool isAvailable = false;
  String yearsOfExp = '';
  int yearsOfExpInDays = 0;

  @override
  void initState() {
    super.initState();
    init();
    calculateYearsOfExp();
  }

  void init() async {
    setStatusBarColor(primaryColor);
    isAvailable = appStore.handymanAvailability == 1 ? true : false;

    /// get wallet balance api call
    appStore.setUserWalletAmount();
  }

  void calculateYearsOfExp() async {
    Duration duration = DateTime.now().difference(DateTime.parse(appStore.createdAt));

    if (duration.inDays < 365) {
      yearsOfExp = languages.lblDay;
      yearsOfExpInDays = duration.inDays;
    } else if (duration.inDays >= 365) {
      yearsOfExp = languages.lblYear;
      yearsOfExpInDays = (duration.inDays / 365).floor();
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Observer(
        builder: (_) {
          return AnimatedScrollView(
            padding: EdgeInsets.only(top: context.statusBarHeight, bottom: 24),
            crossAxisAlignment: CrossAxisAlignment.start,
            listAnimationType: ListAnimationType.FadeIn,
            physics: AlwaysScrollableScrollPhysics(),
            fadeInConfiguration: FadeInConfiguration(duration: 200.milliseconds),
            onSwipeRefresh: () async {
              init();
              setState(() {});
              return 1.seconds.delay;
            },
            children: [
              if (appStore.isLoggedIn && isUserTypeHandyman)
                Observer(
                  builder: (context) {
                    return AnimatedContainer(
                      margin: EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: (appStore.handymanAvailability == 1 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      duration: 300.milliseconds,
                      child: SettingItemWidget(
                        padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                        title: languages.lblAvailableStatus,
                        subTitle: '${languages.lblYouAre} ${appStore.handymanAvailability == 1 ? ONLINE : OFFLINE}',
                        subTitleTextColor: appStore.handymanAvailability == 1 ? Colors.green : Colors.red,
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: Switch.adaptive(
                            value: appStore.handymanAvailability == 1 ? true : false,
                            activeColor: Colors.green,
                            onChanged: (v) {
                              ifNotTester(context, () {
                                isAvailable = v;
                                setState(() {});
                                appStore.setHandymanAvailability(isAvailable ? 1 : 0);
                                Map request = {
                                  "is_available": isAvailable ? 1 : 0,
                                  "id": appStore.userId,
                                };
                                updateHandymanAvailabilityApi(request: request).then((value) {
                                  toast(value.message);
                                }).catchError((e) {
                                  appStore.setHandymanAvailability(isAvailable ? 0 : 1);
                                  toast(e.toString());
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

              Container(
                padding: EdgeInsets.all(12),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: appStore.isDarkMode ? context.cardColor : lightPrimaryColor,
                ),
                child: Row(
                  children: [
                    if (appStore.userProfileImage.isNotEmpty)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          CachedImageWidget(
                            url: appStore.userProfileImage.validate(),
                            height: 66,
                            fit: BoxFit.cover,
                            circle: true,
                          ).paddingBottom(3),
                          /*     Positioned(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: boxDecorationDefault(
                                color: primaryColor,
                                border: Border.all(color: lightPrimaryColor, width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(languages.lblEdit.toUpperCase(), style: secondaryTextStyle(color: whiteColor)),
                            ).onTap(() {
                              EditProfileScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                            }),
                          ),*/
                        ],
                      ),
                    24.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          appStore.userFullName,
                          style: boldTextStyle(color: primaryColor, size: 16),
                        ),
                        4.height,
                        Text(appStore.userEmail, style: secondaryTextStyle()),
                      ],
                    ),
                  ],
                ),
              ).paddingOnly(left: 16, right: 16, bottom: 16).visible(appStore.isLoggedIn).onTap(() {
                EditProfileScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
              }),

              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                margin: EdgeInsets.only(top: 8, left: 16, right: 16),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(8),
                  backgroundColor: context.cardColor,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.grid_view,
                              size: 16,
                            ),
                            10.width,
                            Text(
                              "${languages.servicesDelivered}:",
                              style: boldTextStyle(size: 12),
                            )
                          ],
                        ),
                        Text("${appStore.completedBooking.validate().toString()}")
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(ic_briefcase, height: 16, width: 16, color: appStore.isDarkMode ? white : appTextSecondaryColor),
                            10.width,
                            Text(
                              "${languages.lblExperience}:",
                              style: boldTextStyle(size: 12),
                            )
                          ],
                        ),
                        Text("$yearsOfExpInDays $yearsOfExp")
                      ],
                    ),
                  ],
                ),
              ).paddingOnly(bottom: 16),

              if (getStringAsync(DASHBOARD_COMMISSION).validate().isNotEmpty) ...[
                HandymanCommissionComponent(commission: Commission.fromJson(jsonDecode(getStringAsync(DASHBOARD_COMMISSION)))),
                8.height,
              ],

              16.height,
              SettingSection(
                title: Text("${languages.general}", style: boldTextStyle(color: primaryColor)),
                headingDecoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(16)),
                ),
                divider: Offstage(),
                items: [
                  16.height,
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                    leading: ic_un_fill_wallet.iconImage(size: 16),
                    title: languages.walletBalance,
                    titleTextStyle: boldTextStyle(size: 12),
                    onTap: () {
                      if (appConfigurationStore.onlinePaymentStatus) {
                        WalletHistoryScreen().launch(context);
                      }
                    },
                    trailing: Text(
                      appStore.userWalletAmount.toPriceFormat(),
                      style: boldTextStyle(color: Colors.green),
                    ),
                  ),
                  if (appStore.isLoggedIn && rolesAndPermissionStore.helpDeskList)
                    SettingItemWidget(
                      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(16))),
                      leading: ic_help_desk.iconImage(size: 18),
                      title: languages.helpDesk,
                      titleTextStyle: boldTextStyle(size: 12),
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8), size: 24),
                      onTap: () {
                        HelpDeskListScreen().launch(context);
                      },
                    ),
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,

              /// setting module
              SettingSection(
                title: Text("${languages.setting}", style: boldTextStyle(color: primaryColor)),
                headingDecoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(16)),
                ),
                divider: Offstage(),
                items: [
                  16.height,
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                    leading: Image.asset(ic_theme, width: 16, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8)),
                    title: languages.appTheme,
                    titleTextStyle: boldTextStyle(size: 12),
                    trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8), size: 24),
                    onTap: () async {
                      await showInDialog(
                        context,
                        builder: (context) => ThemeSelectionDaiLog(context),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                    leading: Image.asset(language, width: 16, color: context.iconColor),
                    title: languages.language,
                    titleTextStyle: boldTextStyle(size: 12),
                    trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8), size: 24),
                    onTap: () {
                      LanguagesScreen().launch(context).then((value) {
                        keyForExperienceWidget = UniqueKey();
                      });
                    },
                  ),
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                    leading: Image.asset(changePassword, width: 16, color: context.iconColor),
                    title: languages.changePassword,
                    titleTextStyle: boldTextStyle(size: 12),
                    trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8), size: 24),
                    onTap: () {
                      ChangePasswordScreen().launch(context);
                    },
                  ),
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                    leading: Image.asset(about, width: 16, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8)),
                    title: languages.lblAbout,
                    titleTextStyle: boldTextStyle(size: 12),
                    trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8), size: 24),
                    onTap: () {
                      AboutUsScreen().launch(context);
                    },
                  ),
                  if (appStore.isLoggedIn)
                    SettingItemWidget(
                      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                      leading: ic_notification.iconImage(size: appStore.userType == USER_TYPE_PROVIDER ? 16 : 18),
                      title: languages.pushNotification,
                      titleTextStyle: appStore.userType == USER_TYPE_PROVIDER ? boldTextStyle(size: 12) : boldTextStyle(size: 12),
                      padding: appStore.userType == USER_TYPE_PROVIDER ? null : EdgeInsets.all(16),
                      //   decoration: appStore.userType == USER_TYPE_PROVIDER ? boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)) : null,
                      trailing: Transform.scale(
                        scale: appStore.userType == USER_TYPE_PROVIDER ? 0.6 : 0.7,
                        child: Observer(builder: (context) {
                          return Switch.adaptive(
                            value: FirebaseAuth.instance.currentUser != null && getBoolAsync("IS_SUBSCRIBED_NOTIFICATION", defaultValue: true),
                            onChanged: (v) async {
                              await setValue("IS_SUBSCRIBED_NOTIFICATION", v);
                              if (appStore.isLoading) return;
                              appStore.setLoading(true);

                              if (v) {
                                await subscribeToFirebaseTopic();
                              } else {
                                await unsubscribeFirebaseTopic(appStore.userId);
                              }
                              appStore.setLoading(false);
                              setState(() {});
                            },
                          ).withHeight(18);
                        }),
                      ),
                    ),
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(16))),
                    leading: Image.asset(ic_check_update, width: 16, color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8)),
                    title: languages.lblOptionalUpdateNotify,
                    titleTextStyle: boldTextStyle(size: 12),
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: Switch.adaptive(
                        value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
                        onChanged: (v) {
                          setValue(UPDATE_NOTIFY, v);
                          setState(() {});
                        },
                      ).withHeight(24),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,

              ///Danger zone
              SettingSection(
                title: Text("${languages.lblDangerZone.toUpperCase()}", style: boldTextStyle(color: redColor)),
                headingDecoration: BoxDecoration(
                  color: redColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(16)),
                ),
                divider: Offstage(),
                items: [
                  16.height,
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                    leading: ic_delete.iconImage(size: 16),
                    paddingBeforeTrailing: 4,
                    title: languages.lblDeleteAccount,
                    titleTextStyle: boldTextStyle(size: 12),
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        negativeText: languages.lblCancel,
                        positiveText: languages.lblDelete,
                        onAccept: (_) {
                          ifNotTester(context, () {
                            appStore.setLoading(true);

                            deleteAccountCompletely().then((value) async {
                              try {
                                await userService.removeDocument(appStore.uid);
                                await userService.deleteUser();
                              } catch (e) {
                                print(e);
                              }

                              appStore.setLoading(false);

                              await clearPreferences();
                              toast(value.message);

                              push(SignInScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                            }).catchError((e) {
                              appStore.setLoading(false);
                              toast(e.toString());
                            });
                          });
                        },
                        dialogType: DialogType.DELETE,
                        title: languages.lblDeleteAccountConformation,
                      );
                    },
                  ),
                  SettingItemWidget(
                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(16))),
                    leading: ic_logout.iconImage(size: 16),
                    paddingBeforeTrailing: 4,
                    title: languages.logout,
                    titleTextStyle: boldTextStyle(size: 12),
                    onTap: () {
                      appStore.setLoading(false);
                      logout(context);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),

              20.height,

              VersionInfoWidget(
                prefixText: 'v',
                textStyle: secondaryTextStyle(),
              ).center(),
            ],
          );
        },
      ),
    );
  }
}
