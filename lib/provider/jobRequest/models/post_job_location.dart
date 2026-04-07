import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/utils/lat_lng_valid.dart';
import 'package:nb_utils/nb_utils.dart';

import 'post_job_data.dart';

class PostJobLocation {
  PostJobLocation._();

  static bool hasUsableLocation(PostJobData? detail) {
    if (detail == null) return false;
    if (_postRequestLevelUsable(detail)) return true;
    for (final s in detail.service ?? <ServiceData>[]) {
      if (s.hasUsableServiceLocation) return true;
    }
    return false;
  }

  static bool _postRequestLevelUsable(PostJobData d) {
    if (isUsableLatLngStrings(d.latitude, d.longitude)) return true;
    if (d.address.validate().trim().isNotEmpty) return true;
    if (d.cityId != null && d.cityId! > 0) return true;
    final m = d.serviceAddressMapping;
    if (m != null && m.isNotEmpty) return true;
    return false;
  }
}

extension PostJobDataLocation on PostJobData {
  bool get hasUsableLocationForBid => PostJobLocation.hasUsableLocation(this);
}
