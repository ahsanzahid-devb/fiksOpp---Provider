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

/// Full-screen detail for a single cash payment (PaymentHistoryData).
class CashPaymentDetailScreen extends StatelessWidget {
  final PaymentHistoryData data;

  const CashPaymentDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.cashBalance,
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
                  Row(
                    children: [
                      Marquee(
                        child: PriceWidget(
                          price: data.totalAmount.validate(),
                          size: 18,
                          color: context.primaryColor,
                        ),
                      ).expand(),
                      if (data.status.validate() != APPROVED_BY_HANDYMAN)
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
                  ),
                  16.height,
                  _detailRow(label: '${languages.lblBookingID}', value: data.bookingId.toString().suffixText(value: '#')),
                  Divider(color: context.dividerColor),
                  _detailRow(
                    label: '${languages.lblDate} ${languages.ofTransfer}',
                    value: formatDate(data.datetime.toString(), format: DATE_FORMAT_9),
                  ),
                  Divider(color: context.dividerColor),
                  if (data.text.validate().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        data.text.validate(),
                        style: secondaryTextStyle(size: 12),
                        maxLines: 5,
                      ),
                    ),
                  if (data.isTypeBank) ...[
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
