import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/city_lookup_cache.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/extensions/color_extension.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/lat_lng_valid.dart';
import 'package:handyman_provider_flutter/utils/reverse_geocode_address.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../job_post_detail_screen.dart';
import '../models/post_job_data.dart';

class JobItemWidget extends StatefulWidget {
  final PostJobData? data;

  const JobItemWidget({required this.data, Key? key}) : super(key: key);

  @override
  State<JobItemWidget> createState() => _JobItemWidgetState();
}

class _JobItemWidgetState extends State<JobItemWidget> {
  String? _geocodedLine;
  int _geocodeGen = 0;

  @override
  void initState() {
    super.initState();
    _scheduleReverseGeocodeIfNeeded();
  }

  @override
  void didUpdateWidget(JobItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final o = oldWidget.data;
    final n = widget.data;
    if (o?.id != n?.id ||
        o?.latitude != n?.latitude ||
        o?.longitude != n?.longitude ||
        o?.address != n?.address) {
      _geocodedLine = null;
      _scheduleReverseGeocodeIfNeeded();
    }
  }

  void _scheduleReverseGeocodeIfNeeded() {
    final d = widget.data;
    if (d == null) return;

    final addrEmpty = d.address.validate().trim().isEmpty;
    final hasCoords = isUsableLatLngStrings(d.latitude, d.longitude);
    if (!addrEmpty || !hasCoords) {
      return;
    }

    final id = d.id;
    final lat = double.parse(d.latitude!.trim());
    final lng = double.parse(d.longitude!.trim());
    final gen = ++_geocodeGen;

    reverseGeocodeLatLngCached(lat, lng).then((resolved) {
      if (!mounted || gen != _geocodeGen) return;
      if (widget.data?.id != id) return;
      if (resolved == null || resolved.isEmpty) return;
      setState(() => _geocodedLine = resolved);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return Offstage();
    final data = widget.data!;

    final String fromPayload = data.displayJobLocationLabel;
    final String? fromCityCache = CityLookupCache.nameForCityId(data.cityId);
    final String baseLocation =
        fromPayload.isNotEmpty ? fromPayload : (fromCityCache ?? '');

    final bool wantGeocoded = data.address.validate().trim().isEmpty &&
        isUsableLatLngStrings(data.latitude, data.longitude);
    final String displayLocation =
        wantGeocoded && _geocodedLine != null && _geocodedLine!.isNotEmpty
            ? _geocodedLine!
            : baseLocation;

    final bool hasUsableLoc = PostJobLocation.hasUsableLocation(data);
    final String locationLine = displayLocation.isNotEmpty
        ? displayLocation
        : (hasUsableLoc
            ? languages.lblJobLocationCityAreaFallback
            : languages.lblJobNoSavedLocationRepost);

    final bool locationLooksOk = displayLocation.isNotEmpty || hasUsableLoc;

    return Container(
      width: context.width(),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: boxDecorationDefault(
          color: context.cardColor, borderRadius: radius()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedImageWidget(
            url: data.service.validate().isNotEmpty &&
                    data.service
                        .validate()
                        .first
                        .imageAttachments
                        .validate()
                        .isNotEmpty
                ? data.service
                    .validate()
                    .first
                    .imageAttachments!
                    .first
                    .validate()
                : "",
            fit: BoxFit.cover,
            height: 60,
            width: 60,
            radius: defaultRadius,
          ),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title.validate(),
                  style: primaryTextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              2.height,
              Text(
                data.service.validate().isNotEmpty
                    ? data.service!.first.categoryName.validate()
                    : '',
                style: boldTextStyle(size: 14),
              ),
              2.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: locationLooksOk
                        ? context.primaryColor
                        : Colors.orange.shade700,
                  ),
                  4.width,
                  Expanded(
                    child: Text(
                      locationLine,
                      style: secondaryTextStyle(
                        size: 12,
                        color: locationLooksOk ? null : Colors.orange.shade800,
                      ),
                      maxLines: displayLocation.isNotEmpty ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              2.height,
              Text(formatDate(data.createdAt.validate()),
                  style: secondaryTextStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ).expand(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: data.status
                  .validate()
                  .getJobStatusColor
                  .withValues(alpha: 0.1),
              borderRadius: radius(8),
            ),
            child: Text(
              data.status.validate().toPostJobStatus(),
              style: boldTextStyle(
                  color: data.status.validate().getJobStatusColor, size: 12),
            ),
          ),
        ],
      ).onTap(() {
        JobPostDetailScreen(postJobData: data).launch(context);
      }, borderRadius: radius()),
    );
  }
}
