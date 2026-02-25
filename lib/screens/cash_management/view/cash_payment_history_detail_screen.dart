import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/screens/cash_management/cash_constant.dart';
import 'package:handyman_provider_flutter/screens/cash_management/model/payment_history_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/color_extension.dart';
import 'package:nb_utils/nb_utils.dart';

/// Full-screen detail for a single payment history entry (PaymentHistoryData).
class CashPaymentHistoryDetailScreen extends StatelessWidget {
  final PaymentHistoryData data;

  const CashPaymentHistoryDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.paymentHistory,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationDefault(color: context.cardColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.action.validate().isNotEmpty)
                    Text(
                      data.action.validate().replaceAll('_', ' ').capitalizeFirstLetter(),
                      style: boldTextStyle(size: 16),
                    ),
                  8.height,
                  if (data.datetime != null)
                    Text(
                      formatDate(data.datetime.toString(), format: DATE_FORMAT_9),
                      style: secondaryTextStyle(size: 12),
                    ),
                  16.height,
                  Row(
                    children: [
                      PriceWidget(
                        price: data.totalAmount.validate(),
                        size: 18,
                        color: context.primaryColor,
                      ),
                      if (data.type.validate().isNotEmpty) ...[
                        8.width,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: radius(8),
                          ),
                          child: Text(
                            handleBankText(status: data.type.validate()),
                            style: boldTextStyle(color: primaryColor, size: 12),
                          ),
                        ),
                      ],
                      if (data.status.validate().isNotEmpty) ...[
                        4.width,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: data.status.validate().getCashPaymentStatusBackgroundColor.withValues(alpha: 0.1),
                            borderRadius: radius(8),
                          ),
                          child: Text(
                            handleStatusText(status: data.status.validate()),
                            style: boldTextStyle(
                              color: data.status.validate().getCashPaymentStatusBackgroundColor,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (data.text.validate().isNotEmpty) ...[
                    16.height,
                    Text(
                      data.text.validate().replaceAll('_', ' '),
                      style: secondaryTextStyle(),
                      maxLines: 10,
                    ),
                  ],
                  if (data.bookingId != null && data.bookingId.validate() > 0) ...[
                    16.height,
                    Divider(color: context.dividerColor),
                    _detailRow(
                      label: '${languages.lblBookingID}',
                      value: data.bookingId.toString().suffixText(value: '#'),
                    ),
                  ],
                  if (data.isTypeBank && data.txnId.validate().isNotEmpty) ...[
                    Divider(color: context.dividerColor),
                    _detailRow(label: '${languages.refNumber}', value: data.txnId.validate()),
                  ],
                ],
              ),
            ),
            24.height,
            if (data.bookingId != null && data.bookingId.validate() > 0)
              AppButton(
                width: context.width(),
                color: context.primaryColor,
                text: languages.viewBooking,
                onTap: () {
                  BookingDetailScreen(bookingId: data.bookingId.validate().toInt()).launch(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: secondaryTextStyle()),
        8.width,
        Expanded(
          child: Text(
            value,
            style: boldTextStyle(size: 12),
            textAlign: TextAlign.right,
            maxLines: 3,
          ),
        ),
      ],
    ).paddingSymmetric(vertical: 4);
  }
}
