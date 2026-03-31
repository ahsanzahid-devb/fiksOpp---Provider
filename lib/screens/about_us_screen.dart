import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/about_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/data_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/base_scaffold_widget.dart';
import '../utils/app_configuration.dart';
import '../utils/constant.dart';

class AboutUsScreen extends StatelessWidget {
  Future<void> _openRateUsLink() async {
    bool isValidStoreLink(String url) {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;
      final host = uri.host.toLowerCase();
      return host.contains('play.google.com') || host.contains('apps.apple.com');
    }

    if (isAndroid) {
      final configured = getStringAsync(PROVIDER_PLAY_STORE_URL);
      if (configured.isNotEmpty && isValidStoreLink(configured)) {
        await commonLaunchUrl(configured,
            launchMode: LaunchMode.externalApplication);
      } else {
        await commonLaunchUrl(
          '${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}',
          launchMode: LaunchMode.externalApplication,
        );
      }
    } else if (isIOS) {
      final configured = getStringAsync(PROVIDER_APPSTORE_URL);
      if (configured.isNotEmpty && isValidStoreLink(configured)) {
        await commonLaunchUrl(configured,
            launchMode: LaunchMode.externalApplication);
      } else {
        await commonLaunchUrl(IOS_LINK_FOR_PARTNER,
            launchMode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AboutModel> aboutList = getAboutDataModel(context: context);

    return AppScaffold(
      appBarTitle: languages.lblAbout,
      body: AnimatedWrap(
        spacing: 16,
        runSpacing: 16,
        itemCount: aboutList.length,
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        scaleConfiguration: ScaleConfiguration(
            duration: 400.milliseconds, delay: 50.milliseconds),
        itemBuilder: (context, index) {
          return Container(
            width: context.width() * 0.5 - 26,
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(),
              backgroundColor: context.cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(aboutList[index].image.toString(),
                    height: 22, width: 22, color: context.iconColor),
                8.height,
                Text(aboutList[index].title.toString(),
                    style: primaryTextStyle(size: LABEL_TEXT_SIZE)),
              ],
            ),
          ).onTap(
            () async {
              final title = aboutList[index].title;

              if (title == languages.lblTermsAndConditions) {
                openTermsInExternalBrowser();
              } else if (title == languages.lblPrivacyPolicy) {
                openPrivacyInExternalBrowser();
              } else if (title == languages.lblHelpAndSupport) {
                if (appConfigurationStore.helpAndSupport.isNotEmpty) {
                  checkIfLink(context, appConfigurationStore.helpAndSupport,
                      title: languages.lblHelpAndSupport);
                } else {
                  checkIfLink(context, appConfigurationStore.inquiryEmail,
                      title: languages.lblHelpAndSupport);
                }
              } else if (title == languages.lblHelpLineNum) {
                final phone = appConfigurationStore.helplineNumber.validate();
                if (phone.isNotEmpty) {
                  launchCall(phone);
                } else {
                  toast(languages.noDataFound);
                }
              } else if (title == 'Rate us') {
                _openRateUsLink();
              }
            },
            borderRadius: radius(),
          );
        },
      ).paddingAll(16),
    );
  }
}
