import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/components/bid_price_dialog.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/provider/services/service_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/lat_lng_valid.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/post_job_bid_diagnostics.dart';
import 'package:handyman_provider_flutter/utils/reverse_geocode_address.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import 'models/bidder_data.dart';
import 'models/post_job_city_enrichment.dart';
import 'models/post_job_data.dart';

class JobPostDetailScreen extends StatefulWidget {
  final PostJobData postJobData;

  JobPostDetailScreen({required this.postJobData});

  @override
  _JobPostDetailScreenState createState() => _JobPostDetailScreenState();
}

class _JobPostDetailScreenState extends State<JobPostDetailScreen> {
  late Future<PostJobDetailResponse> future;

  int page = 1;

  num? _bidDiagnosticsLoggedForPostId;

  /// Reverse geocode for post-level lat/lng when [PostJobData.address] is empty.
  String? _resolvedAddressFromCoords;
  bool _resolvingAddressFromCoords = false;
  int _addressResolveGen = 0;
  String? _resolvedCoordKey;

  @override
  void initState() {
    super.initState();
    LiveStream().on(LIVESTREAM_UPDATE_BOOKINGS, (p0) {
      init();
      setState(() {});
    });
    init();
  }

  void init() async {
    future = getPostJobDetail(
        {PostJob.postRequestId: widget.postJobData.id.validate()});
  }

  Widget titleWidget(
      {required String title,
      required String detail,
      bool isReadMore = false,
      required TextStyle detailTextStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.validate(), style: secondaryTextStyle()),
        8.height,
        if (isReadMore)
          ReadMoreText(
            detail,
            style: detailTextStyle,
            colorClickableText: context.primaryColor,
          )
        else
          Text(detail.validate(), style: detailTextStyle),
        16.height,
      ],
    );
  }

  Widget postJobDetailWidget({required PostJobData data}) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.title.validate().isNotEmpty)
            titleWidget(
              title: languages.postJobTitle,
              detail: data.title.validate(),
              detailTextStyle: boldTextStyle(),
            ),
          if (data.description.validate().isNotEmpty)
            titleWidget(
              title: languages.postJobDescription,
              detail: data.description.validate(),
              detailTextStyle: primaryTextStyle(),
              isReadMore: true,
            ),
        ],
      ),
    );
  }

  Widget postJobServiceWidget({required List<ServiceData> serviceList}) {
    if (serviceList.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(languages.lblServices, style: boldTextStyle(size: LABEL_TEXT_SIZE))
            .paddingOnly(left: 16, right: 16),
        AnimatedListView(
          itemCount: serviceList.length,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.imageAttachments.validate().isNotEmpty
                        ? data.imageAttachments!.first.validate()
                        : "",
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(),
                          style: primaryTextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                      .expand(),
                ],
              ),
            ).onTap(() async {
              if (data.id != null) {
                // Check if service belongs to a different provider
                // Services from other providers cannot be viewed via service-detail API
                if (data.providerId != null &&
                    data.providerId.validate() != appStore.userId.validate()) {
                  toast(languages.noServiceFound);
                  return;
                }
                ServiceDetailScreen(serviceId: data.id.validate())
                    .launch(context);
              }
            });
          },
        ),
      ],
    );
  }

  String _getJobLocation(PostJobData data) => data.displayJobLocationLabel;

  /// [booking-list] rows include `address` for `user_post_job`; [get-post-job-detail]
  /// often does not. Re-use a matching cached booking so bidding matches booking UX.
  PostJobData _mergeJobLocation(PostJobData raw) {
    var d = PostJobData.withLocationFallbackFromList(raw, widget.postJobData);
    if (PostJobLocation.hasUsableLocation(d)) return d;

    final cid = d.customerId;
    final sid = d.service.validate().firstOrNull?.id;
    final bookings = cachedBookingList;
    if (cid == null || sid == null || bookings == null || bookings.isEmpty) {
      return d;
    }

    for (final b in bookings) {
      if (!b.isPostJob) continue;
      if (b.customerId != cid) continue;
      if (b.serviceId != sid) continue;
      final addr = b.address.validate().trim();
      if (addr.isEmpty) continue;
      if (kDebugMode) {
        log(
          '[PostJobBid] location fallback: using address from cached '
          'user_post_job booking id=${b.id} → $addr',
        );
      }
      return d.copyWithLocationOverlay(address: addr);
    }
    return d;
  }

  void _scheduleReverseGeocodeForPostLevelCoords(PostJobData d) {
    final addrEmpty = d.address.validate().trim().isEmpty;
    final hasCoords = isUsableLatLngStrings(d.latitude, d.longitude);

    if (!addrEmpty || !hasCoords) {
      _addressResolveGen++;
      if (_resolvedAddressFromCoords != null ||
          _resolvingAddressFromCoords ||
          _resolvedCoordKey != null) {
        setState(() {
          _resolvedAddressFromCoords = null;
          _resolvingAddressFromCoords = false;
          _resolvedCoordKey = null;
        });
      }
      return;
    }

    final key = '${d.latitude!.trim()}|${d.longitude!.trim()}';
    if (_resolvedCoordKey == key &&
        (_resolvedAddressFromCoords != null || !_resolvingAddressFromCoords)) {
      return;
    }
    if (_resolvingAddressFromCoords && _resolvedCoordKey == key) {
      return;
    }

    _resolvedCoordKey = key;
    final gen = ++_addressResolveGen;
    setState(() => _resolvingAddressFromCoords = true);

    final lat = double.parse(d.latitude!.trim());
    final lng = double.parse(d.longitude!.trim());
    reverseGeocodeLatLng(lat, lng).then((resolved) {
      if (!mounted || gen != _addressResolveGen) return;
      setState(() {
        _resolvingAddressFromCoords = false;
        _resolvedAddressFromCoords = resolved;
      });
    });
  }

  Widget locationWidget(PostJobData data) {
    final location = _getJobLocation(data);
    final hasUsable = PostJobLocation.hasUsableLocation(data);
    final showResolvedRow = data.address.validate().trim().isEmpty &&
        isUsableLatLngStrings(data.latitude, data.longitude);
    final displayText = showResolvedRow && _resolvedAddressFromCoords != null
        ? _resolvedAddressFromCoords!
        : location;
    if (!hasUsable && location.isEmpty) {
      return Container(
        width: context.width(),
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          languages.lblJobNoSavedLocationRepost,
          style: secondaryTextStyle(color: Colors.orange.shade900),
        ),
      );
    }
    if (hasUsable && location.isEmpty) {
      return Container(
        width: context.width(),
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined,
                size: 18, color: context.primaryColor),
            8.width,
            Expanded(
              child: Text(
                "Oslo",
                style: secondaryTextStyle(size: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: context.width(),
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined,
              size: 18, color: context.primaryColor),
          8.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: primaryTextStyle(size: 13),
                ),
                if (showResolvedRow &&
                    _resolvedAddressFromCoords != null &&
                    location != _resolvedAddressFromCoords) ...[
                  4.height,
                  Text(
                    location,
                    style: secondaryTextStyle(size: 11),
                  ),
                ],
              ],
            ),
          ),
          if (showResolvedRow &&
              _resolvingAddressFromCoords &&
              _resolvedAddressFromCoords == null) ...[
            8.width,
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget providerWidget(List<BidderData> bidderList) {
    try {
      if (bidderList.any((element) => element.providerId == appStore.userId)) {
        BidderData? bidderData = bidderList
            .firstWhere((element) => element.providerId == appStore.userId);
        UserData? user = bidderData.provider;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text(languages.myBid, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: user!.profileImage.validate(),
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    circle: true,
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                          user.displayName.validate(),
                          style: boldTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      4.height,
                      PriceWidget(price: bidderData.price.validate()),
                    ],
                  ).expand(),
                ],
              ),
            ),
            16.height,
          ],
        ).paddingOnly(left: 16, right: 16);
      }
    } catch (e) {
      print(e);
    }

    return Offstage();
  }

  Widget customerWidget(PostJobData? postJobData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(languages.lblAboutCustomer,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            children: [
              CachedImageWidget(
                url: postJobData!.customerProfile.validate(),
                fit: BoxFit.cover,
                height: 60,
                width: 60,
                circle: true,
              ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Marquee(
                    directionMarguee: DirectionMarguee.oneDirection,
                    child: Text(
                      postJobData.customerName.validate(),
                      style: boldTextStyle(),
                    ),
                  ),
                  Marquee(
                    directionMarguee: DirectionMarguee.oneDirection,
                    child: Text(
                      postJobData.jobPrice?.toString().validate() ?? "0.00",
                      style: secondaryTextStyle(),
                    ),
                  ),
                  if (postJobData.service.validate().isNotEmpty)
                    Text(
                      '${postJobData.service!.first.categoryName.validate()}',
                      style: boldTextStyle(size: 13),
                    ),
                ],
              ).expand(),
            ],
          ),
        ),
        16.height,
      ],
    ).paddingOnly(left: 16, right: 16);
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: "Job Detail",
      body: Stack(
        children: [
          SnapHelperWidget<PostJobDetailResponse>(
            future: future,
            initialData: cachedPostJobList
                .firstWhere(
                    (element) =>
                        element?.$1 == widget.postJobData.id.validate(),
                    orElse: () => null)
                ?.$2,
            onSuccess: (data) {
              final raw = data.postRequestDetail!;
              final merged = _mergeJobLocation(raw);
              enrichPostJobCityNameFromBidderProviders(merged, data.bidderData);
              final detail = merged;
              if (kDebugMode && _bidDiagnosticsLoggedForPostId != detail.id) {
                _bidDiagnosticsLoggedForPostId = detail.id;
                logPostJobBidLocation('detail_loaded', detail);
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _scheduleReverseGeocodeForPostLevelCoords(detail);
              });
              return Stack(
                children: [
                  AnimatedScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    physics: AlwaysScrollableScrollPhysics(),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration: FadeInConfiguration(
                      duration: Duration(milliseconds: 350),
                    ),
                    onSwipeRefresh: () async {
                      page = 1;

                      init();
                      setState(() {});

                      return await 2.seconds.delay;
                    },
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          postJobDetailWidget(data: detail).paddingAll(16),
                          Text(languages.lblAddress,
                                  style: boldTextStyle(size: LABEL_TEXT_SIZE))
                              .paddingOnly(left: 16, right: 16),
                          8.height,
                          locationWidget(detail),
                          8.height,
                          customerWidget(detail),
                          providerWidget(data.bidderData.validate()),
                          postJobServiceWidget(
                              serviceList: detail.service.validate()),
                          24.height,
                        ],
                      ),
                    ],
                  ),
                  if (detail.canBid.validate())
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: AppButton(
                        child: Text(languages.bid,
                            style: boldTextStyle(color: white)),
                        color: context.primaryColor,
                        width: context.width(),
                        onTap: () async {
                          if (!PostJobLocation.hasUsableLocation(detail)) {
                            logPostJobBidLocation(
                                'bid_tap_blocked_no_job_address', detail);
                            toast(languages.lblJobNoSavedLocationRepost);
                            return;
                          }
                          logPostJobBidLocation(
                              'bid_tap_job_address_ok_open_dialog', detail);
                          // Job site is on the server (see PostJobLocation /
                          // ServerJobSite); no device location permission for bidding.
                          bool? res = await showInDialog(
                            context,
                            contentPadding: EdgeInsets.zero,
                            hideSoftKeyboard: true,
                            backgroundColor: context.cardColor,
                            builder: (_) => BidPriceDialog(data: detail),
                          );

                          if (res ?? false) {
                            init();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                ],
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
            loadingWidget: LoaderWidget(),
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
