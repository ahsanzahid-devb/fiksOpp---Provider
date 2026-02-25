import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/cash_management/view/cash_balance_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

/// Main cash management hub: shows total cash and navigation to balance detail.
class CashManagementScreen extends StatelessWidget {
  final num totalCashInHand;

  const CashManagementScreen({Key? key, required this.totalCashInHand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.cashManagement,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                CashBalanceDetailScreen(totalCashInHand: totalCashInHand).launch(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: boxDecorationDefault(
                  borderRadius: radius(defaultRadius),
                  color: context.primaryColor,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: boxDecorationDefault(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(12),
                      child: Image.asset(un_fill_wallet, color: Colors.white, height: 28),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languages.totalCash,
                            style: primaryTextStyle(color: Colors.white, size: 14),
                          ),
                          4.height,
                          PriceWidget(
                            price: totalCashInHand,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ),
            24.height,
            Text(
              languages.cashBalance,
              style: boldTextStyle(size: LABEL_TEXT_SIZE),
            ),
            8.height,
            Text(
              languages.cashList,
              style: secondaryTextStyle(),
            ),
            8.height,
            AppButton(
              width: context.width(),
              color: context.primaryColor,
              text: languages.cashBalance,
              onTap: () {
                CashBalanceDetailScreen(totalCashInHand: totalCashInHand).launch(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
