import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/notification_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/services/service_detail_screen.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/job_post_detail_screen.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_data.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/provider/wallet/wallet_history_screen.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';
import '../components/app_widgets.dart';
import '../components/base_scaffold_widget.dart';
import '../components/empty_error_state_widget.dart';

class NotificationFragment extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationFragment> {
  late Future<List<NotificationData>> future;
  List<NotificationData> list = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    LiveStream().on(LIVESTREAM_UPDATE_NOTIFICATIONS, (p0) {
      appStore.setLoading(true);

      init(type: MARK_AS_READ);
      setState(() {});
    });
    init();
  }

  Future<void> init({String type = ''}) async {
    future = getNotification(
      {NotificationKey.type: type},
      notificationList: list,
      lastPageCallback: (val) => isLastPage = val,
    );
  }

  Future<void> readNotificationGeneric(
      {required String type, required int id}) async {
    final Map<String, dynamic> request = type == 'booking'
        ? {CommonKeys.bookingId: id}
        : {CommonKeys.serviceId: id};

    try {
      if (type == 'booking') {
        await bookingDetail(request);
      } else if (type == 'service') {
        await getServiceDetail(request);
      }
      init();
    } catch (e) {
      log(e.toString());
    }
  }

  int? _notificationEntityId(NotificationData item) {
    final rawId = item.data?.id;
    if (rawId == null) return null;
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    return int.tryParse(rawId.toString());
  }

  int? _bookingId(NotificationData item) {
    return item.data?.bookingId ?? _notificationEntityId(item);
  }

  int? _serviceId(NotificationData item) {
    return item.data?.serviceId ?? _notificationEntityId(item);
  }

  int? _postRequestId(NotificationData item) {
    return item.data?.postRequestId ?? _notificationEntityId(item);
  }

  void _openProfileFromNotification() {
    final profileTabIndex = appConfigurationStore.isEnableChat ? 4 : 3;
    if (Navigator.canPop(context)) {
      finish(context);
      LiveStream().emit(LIVESTREAM_PROVIDER_ALL_BOOKING, profileTabIndex);
    } else {
      ProviderDashboardScreen(index: profileTabIndex).launch(context);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_NOTIFICATIONS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: Navigator.canPop(context) ? languages.notification : null,
      actions: [
        IconButton(
          icon: Icon(Icons.clear_all_rounded, color: Colors.white),
          onPressed: () async {
            showConfirmDialogCustom(
              context,
              onAccept: (_) async {
                appStore.setLoading(true);

                init(type: MARK_AS_READ);
                setState(() {});
              },
              primaryColor: context.primaryColor,
              negativeText: languages.lblNo,
              positiveText: languages.lblYes,
              title: languages.confirmationRequestTxt,
            );
          },
        ),
      ],
      body: SnapHelperWidget<List<NotificationData>>(
        initialData: cachedNotifications,
        future: future,
        loadingWidget: LoaderWidget(),
        onSuccess: (list) {
          return AnimatedListView(
            itemCount: list.length,
            shrinkWrap: true,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            emptyWidget: NoDataWidget(
              title: languages.noNotificationTitle,
              subTitle: languages.noNotificationSubTitle,
              imageWidget: EmptyStateWidget(),
            ),
            itemBuilder: (context, index) {
              NotificationData data = list[index];
              return GestureDetector(
                onTap: () async {
                  final nType = data.data?.notificationType.validate() ?? '';
                  final activityType = data.data?.activityType.validate() ?? '';
                  final isJobNotification = nType.contains(JOB_REQUESTED) ||
                      nType.contains(USER_ACCEPT_BID) ||
                      nType.contains(PROVIDER_SEND_BID) ||
                      nType.contains(POSTJOB) ||
                      activityType.contains(JOB_REQUESTED) ||
                      activityType.contains(USER_ACCEPT_BID) ||
                      activityType.contains(PROVIDER_SEND_BID);

                  if (isUserTypeHandyman) {
                    if (nType.contains(BOOKING)) {
                      final targetId = _bookingId(data);
                      if (targetId == null) {
                        toast(languages.somethingWentWrong);
                        return;
                      }
                      readNotificationGeneric(type: 'booking', id: targetId);
                      BookingDetailScreen(bookingId: targetId).launch(context);
                    } else if (isJobNotification) {
                      final postId = _postRequestId(data);
                      if (postId == null) {
                        toast(languages.somethingWentWrong);
                        return;
                      }
                      JobPostDetailScreen(postJobData: PostJobData(id: postId))
                          .launch(context);
                    } else {
                      toast(languages.somethingWentWrong);
                    }
                  } else if (isUserTypeProvider) {
                    if (nType.contains(WALLET) || nType.contains(PAYOUT)) {
                      WalletHistoryScreen().launch(context);
                    } else if (nType.contains(BOOKING) ||
                        nType.contains(PAYMENT_MESSAGE_STATUS) ||
                        data.data?.checkBookingType == BOOKING) {
                      final targetId = _bookingId(data);
                      if (targetId == null) {
                        toast(languages.somethingWentWrong);
                        return;
                      }
                      readNotificationGeneric(type: 'booking', id: targetId);
                      BookingDetailScreen(bookingId: targetId).launch(context);
                    } else if (nType.contains(SERVICE_REQUEST_APPROVE) ||
                        nType.contains(SERVICE_REQUEST_REJECT)) {
                      final targetId = _serviceId(data);
                      if (targetId == null) {
                        toast(languages.somethingWentWrong);
                        return;
                      }
                      readNotificationGeneric(type: 'service', id: targetId);
                      ServiceDetailScreen(serviceId: targetId).launch(context);
                    } else if (nType.contains(USER_DETAIL) ||
                        activityType.contains(USER_DETAIL)) {
                      _openProfileFromNotification();
                    } else if (isJobNotification) {
                      final postId = _postRequestId(data);
                      if (postId == null) {
                        toast(languages.somethingWentWrong);
                        return;
                      }
                      JobPostDetailScreen(postJobData: PostJobData(id: postId))
                          .launch(context);
                    } else {
                      toast(languages.somethingWentWrong);
                    }
                  }
                },
                child: NotificationWidget(data: data),
              );
            },
            onSwipeRefresh: () async {
              page = 1;
              init();
              setState(() {});
              return await 2.seconds.delay;
            },
          );
        },
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
            retryText: languages.reload,
            onRetry: () {
              page = 1;
              appStore.setLoading(true);
              init();
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
