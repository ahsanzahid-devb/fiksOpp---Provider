import 'package:nb_utils/nb_utils.dart';

import 'bidder_data.dart';
import 'post_job_data.dart';

/// When the post only has [PostJobData.cityId], [get-post-job-detail] may still
/// include a matching `city_name` on a bidder's [UserData] (same API response).
void enrichPostJobCityNameFromBidderProviders(
  PostJobData post,
  List<BidderData>? bidders,
) {
  if (post.cityName.validate().trim().isNotEmpty) return;
  final cid = post.cityId;
  if (cid == null || cid <= 0 || bidders == null) return;
  for (final b in bidders) {
    final u = b.provider;
    if (u == null || u.cityId == null) continue;
    if (u.cityId != cid) continue;
    final name = u.cityName.validate().trim();
    if (name.isEmpty) continue;
    post.cityName = name;
    final list = post.service;
    if (list != null && list.isNotEmpty) {
      final s = list.first;
      if (s.cityName.validate().trim().isEmpty &&
          s.cityId != null &&
          s.cityId == cid) {
        s.cityName = name;
      }
    }
    return;
  }
}
