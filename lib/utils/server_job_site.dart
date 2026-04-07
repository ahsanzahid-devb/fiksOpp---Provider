import 'package:nb_utils/nb_utils.dart';

import '../models/booking_detail_response.dart';
import '../models/booking_list_response.dart';
import '../provider/jobRequest/models/post_job_data.dart';

/// Whether the **backend** already described where the work is (address, lat/lng,
/// city, mapping on post or service). In that case the app should not require
/// **device** GPS for bid / “where is the job?” flows.
///
/// **Not** for live tracking during `onGoing` bookings (that still needs GPS).
class ServerJobSite {
  ServerJobSite._();

  static bool knownFromPostJob(PostJobData? postJob) =>
      PostJobLocation.hasUsableLocation(postJob);

  /// [BookingData] as returned by [booking-list] / list rows.
  static bool knownFromBookingRow(BookingData? b) {
    if (b == null) return false;
    if (b.address.validate().trim().isNotEmpty) return true;
    if (b.bookingAddressId != null && b.bookingAddressId! > 0) return true;
    return false;
  }

  /// [BookingDetailResponse] (detail + nested service + optional post job).
  static bool knownFromBookingDetail(BookingDetailResponse? detail) {
    if (detail == null) return false;
    if (knownFromBookingRow(detail.bookingDetail)) return true;
    final svc = detail.service;
    if (svc != null && svc.hasUsableServiceLocation) return true;
    return knownFromPostJob(detail.postRequestDetail);
  }
}
