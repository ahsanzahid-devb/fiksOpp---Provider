enum FilterByStatus {
  customer,
  service,
  date_range,
  provider,
  handyman,
  booking_status,
  payment_type,
  payment_status,
}

class FilterByStatusModel {
  FilterByStatus status;
  String name;

  FilterByStatusModel({
    this.status = FilterByStatus.customer,
    this.name = "",
  });
}