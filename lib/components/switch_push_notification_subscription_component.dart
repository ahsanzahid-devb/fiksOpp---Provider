import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/constant.dart';
import '../utils/firebase_messaging_utils.dart';
import '../utils/images.dart';

class SwitchPushNotificationSubscriptionComponent extends StatefulWidget {
  const SwitchPushNotificationSubscriptionComponent({Key? key})
      : super(key: key);

  @override
  State<SwitchPushNotificationSubscriptionComponent> createState() =>
      _SwitchPushNotificationSubscriptionComponentState();
}

class _SwitchPushNotificationSubscriptionComponentState
    extends State<SwitchPushNotificationSubscriptionComponent> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isSubscribed =
      getBoolAsync("IS_SUBSCRIBED_NOTIFICATION", defaultValue: true);

  void init() async {
    await appStore.setPushNotificationSubscriptionStatus(isSubscribed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final isProvider = appStore.userType == USER_TYPE_PROVIDER;
        return SettingItemWidget(
          leading: ic_notification.iconImage(size: isProvider ? 16 : 18),
          title: languages.pushNotification,
          titleTextStyle:
              isProvider ? boldTextStyle(size: 12) : primaryTextStyle(),
          padding: isProvider ? null : EdgeInsets.all(16),
          decoration: isProvider
              ? boxDecorationDefault(
                  color: context.cardColor, borderRadius: radius(0))
              : null,
          trailing: Transform.scale(
            scale: isProvider ? 0.6 : 0.7,
            child: Switch.adaptive(
              value: FirebaseAuth.instance.currentUser != null &&
                  getBoolAsync(IS_SUBSCRIBED_NOTIFICATION, defaultValue: true),
              onChanged: (v) async {
                await setValue(IS_SUBSCRIBED_NOTIFICATION, v);
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
            ).withHeight(18),
          ),
        );
      },
    );
  }
}
