import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/screens/cash_management/model/payment_history_model.dart';
import 'package:handyman_provider_flutter/screens/cash_management/view/cash_payment_history_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentHistoryListWidget extends StatelessWidget {
  const PaymentHistoryListWidget({Key? key, required this.data, required this.index, required this.length}) : super(key: key);

  final PaymentHistoryData data;
  final int index;
  final int length;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CashPaymentHistoryDetailScreen(data: data).launch(context);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (data.datetime != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDate(data.datetime.toString(), format: DATE_FORMAT_3), style: secondaryTextStyle(size: 12)),
                    Text(formatDate(data.datetime.toString(), isTime: true), style: secondaryTextStyle(size: 12)),
                  ],
                ),
                8.height,
              ],
              TextIcon(
                expandedText: true,
                edgeInsets: EdgeInsets.only(bottom: 4),
                text: (data.action.validate().replaceAll('_', ' ')).capitalizeFirstLetter(),
                textStyle: boldTextStyle(),
              ),
              if (data.text.validate().isNotEmpty)
                Text(
                  data.text!.replaceAll('_', ' '),
                  style: secondaryTextStyle(),
                ).paddingLeft(2),
              if ((data.totalAmount ?? 0) > 0) ...[
                8.height,
                PriceWidget(price: data.totalAmount ?? 0, size: 14),
              ],
            ],
          ).paddingOnly(bottom: 18).expand(),
        ],
      ),
    );
  }
}
