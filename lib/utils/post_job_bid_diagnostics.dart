import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_data.dart';
import 'package:nb_utils/nb_utils.dart';

/// Debug-only: explains why bidding may be blocked (API job location vs device GPS).
void logPostJobBidLocation(String stage, PostJobData data) {
  if (!kDebugMode) return;

  final pid = data.id;
  final rootAddr = data.address.validate().trim().isNotEmpty;
  final rootLatLng = data.latitude.validate().isNotEmpty &&
      data.longitude.validate().isNotEmpty;
  final rootCity = data.cityId != null && data.cityId! > 0;
  final list = data.service;

  if ((list == null || list.isEmpty) && !rootAddr && !rootLatLng && !rootCity) {
    developer.log(
      'post_request_id=$pid stage=$stage → BLOCK: no service[] and no post-level '
      'address/lat/lng/city_id.',
      name: 'PostJobBid',
    );
    return;
  }

  final serviceLine = (list != null && list.isNotEmpty)
      ? list.first.bidLocationAuditLine
      : 'no_service_array';
  developer.log(
    'post_request_id=$pid stage=$stage → hasUsableLocationForBid=${data.hasUsableLocationForBid} '
    '| post.address=${data.address} cityId=${data.cityId} lat/lng set=$rootLatLng '
    '| $serviceLine '
    '| NOTE: Uses post_request + service fields (address, city_id, service_address_mapping). '
    'It is NOT your phone Settings → Location permission.',
    name: 'PostJobBid',
  );
}
