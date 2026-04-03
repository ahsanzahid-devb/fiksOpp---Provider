import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/shimmer/job_request_shimmer.dart';
import 'package:handyman_provider_flutter/provider/services/add_services.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import '../../booking_filter/components/filter_service_list_component.dart';
import 'components/job_item_widget.dart';
import 'models/post_job_data.dart';

class JobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late Future<List<PostJobData>> future;
  List<PostJobData> myPostJobList = [];

  int page = 1;
  bool isLastPage = false;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    LiveStream().on(LIVESTREAM_UPDATE_BOOKINGS, (p0) {
      init(resetPage: true);
    });
    init(resetPage: true);
  }

  Future<void> init({bool resetPage = false}) async {
    if (isFetching) return;

    if (resetPage) {
      page = 1;
      isLastPage = false;
      myPostJobList.clear();
    }

    isFetching = true;
    final request = getPostJobList(
      page,
      postJobList: myPostJobList,
      lastPageCallback: (val) => isLastPage = val,
      serviceIds:
          filterStore.serviceId.isNotEmpty ? filterStore.serviceId : null,
    );
    future = request;
    setState(() {});
    try {
      await request;
    } finally {
      isFetching = false;
      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKINGS);
    super.dispose();
  }

  void _showServiceFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.height() * 0.8,
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.scaffoldBackgroundColor,
          borderRadius:
              radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius:
                    radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
              ),
              child: Row(
                children: [
                  Text(languages.selectService, style: boldTextStyle(size: 18))
                      .expand(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => finish(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FilterServiceListComponent(),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
              ),
              child: Row(
                children: [
                  AppButton(
                    text: languages.hintAddService,
                    textColor: Colors.white,
                    color: context.primaryColor,
                    onTap: () {
                      finish(context);
                      AddServices().launch(context).then((value) {
                        if (value == true) {
                          init(resetPage: true);
                        }
                      });
                    },
                  ).expand(),
                  16.width,
                  AppButton(
                    text: languages.apply,
                    textColor: Colors.white,
                    color: context.primaryColor,
                    onTap: () {
                      finish(context);
                      init(resetPage: true);
                    },
                  ).expand(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // appBarTitle: languages.jobRequestList,
      // actions: [
      //   IconButton(
      //     icon: Image.asset(ic_filter, color: white, width: 22, height: 22),
      //     onPressed: () {
      //       _showServiceFilterBottomSheet();
      //     },
      //   ),
      // ],
      body: Stack(
        children: [
          SnapHelperWidget<List<PostJobData>>(
            future: future,
            onSuccess: (data) {
              return AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration:
                    FadeInConfiguration(duration: Duration(milliseconds: 350)),
                padding: EdgeInsets.all(16),
                itemCount: data.validate().length,
                shrinkWrap: true,
                emptyWidget: NoDataWidget(
                  title: languages.noDataFound,
                  imageWidget: EmptyStateWidget(),
                ),
                itemBuilder: (_, i) => JobItemWidget(data: data[i]),
                onNextPage: () {
                  if (!isLastPage && !isFetching) {
                    page++;
                    appStore.setLoading(true);

                    init();
                  }
                },
                onSwipeRefresh: () async {
                  await init(resetPage: true);
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  appStore.setLoading(true);
                  init(resetPage: true);
                },
              );
            },
            loadingWidget: JobPostRequestShimmer(),
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
