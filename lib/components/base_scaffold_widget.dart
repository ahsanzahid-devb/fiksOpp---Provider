import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';
import 'app_widgets.dart';
import 'back_widget.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;

  final Widget body;
  final Color? scaffoldBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool showLoader;
  final Observable<bool>? isLoading;

  AppScaffold({
    this.appBarTitle,
    required this.body,
    this.actions,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBar,
    this.showLoader = true,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle != null
          ? AppBar(
              title: Text(appBarTitle.validate(),
                  style: boldTextStyle(
                      color: Colors.white, size: APP_BAR_TEXT_SIZE)),
              elevation: 0.0,
              backgroundColor: context.primaryColor,
              leading: context.canPop ? BackWidget() : null,
              actions: actions,
            )
          : null,
      backgroundColor: scaffoldBackgroundColor,
      body: Observer(
        builder: (_) {
          final loading = showLoader && (isLoading?.value ?? false);
          return Stack(
            children: [
              AbsorbPointer(
                absorbing: loading,
                child: body,
              ),
              if (loading)  LoaderWidget().center(),
            ],
          );
        },
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}