// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:razorpay_flutter/razorpay_flutter.dart';

Future razorpayCustom(
  BuildContext context,
  String? keyID,
  String? price,
  String? name,
  String? description,
  String? phone,
  String? email,
  Future<dynamic> Function(String paymentId, String signature) onSuccess,
  Future<dynamic> Function() onFail,
  String? currency,
  String? orderId,
) async {
  // Add your function code here!
  Razorpay _razorpay = Razorpay();

  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) async {
    await onSuccess.call(response.paymentId ?? '', response.signature ?? '');
  });

  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
      (PaymentFailureResponse response) async {
    await onFail.call();
  });

  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
    // Handle external wallet
  });

  double amount = double.tryParse(price ?? '0') ?? 0;
  // Razorpay takes amount in paise (multiply by 100)
  int amountInSubunit = (amount * 100).round();

  var options = {
    'key': keyID ?? '',
    if (orderId == null || orderId.isEmpty) 'amount': amountInSubunit,
    if (orderId == null || orderId.isEmpty) 'currency': currency ?? 'INR',
    'name': name?.isNotEmpty == true ? name : 'Mock Station',
    'description': description?.isNotEmpty == true ? description : 'Subscription Plan',
    if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
    'prefill': {
      if (phone?.isNotEmpty == true) 'contact': phone,
      if (email?.isNotEmpty == true && email!.contains('@')) 'email': email,
    },
    'theme': {
      'color': '#3399cc',
    },
  };

  print('=== RAZORPAY OPTIONS: $options ===');

  try {
    _razorpay.open(options);
  } catch (e) {
    debugPrint('Error opening Razorpay: $e');
  }
}
