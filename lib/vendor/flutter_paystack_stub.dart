import 'package:flutter/widgets.dart';

// Local stub for flutter_paystack to allow the app to build when the real
// Paystack plugin can't be used (temporary). This provides minimal types
// used by the app so the compiler/linker doesn't fail. The stub returns
// a CheckoutResponse with status=false by default.

class PaystackPlugin {
  void initialize({required String publicKey}) {
    // no-op
  }

  Future<CheckoutResponse> checkout(
    BuildContext ctx, {
    required CheckoutMethod method,
    required Charge charge,
  }) async {
    return CheckoutResponse(
        status: false, message: 'Paystack stub - not executed', reference: '');
  }
}

class Charge {
  int amount = 0;
  String reference = '';
  String? email;
  String? currency;

  Charge();
}

class CheckoutResponse {
  final bool status;
  final String? message;
  final String? reference;

  CheckoutResponse({required this.status, this.message, this.reference});
}

enum CheckoutMethod { card }
