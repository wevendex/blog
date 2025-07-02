import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> init() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      // Store not available.
      return;
    }

    await _queryProducts();

    _subscription = _iap.purchaseStream.listen((purchases) {
      _listenToPurchases(purchases);
    });
  }

  static const _productIds = {'coins_pack_1', 'remove_ads'};

  Future<void> _queryProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      // Handle error
      return;
    }
    // Store product details for later purchase flow
    // TODO: expose via getter or provider
  }

  void _listenToPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyPurchaseWithServer(purchase);
      }
    }
  }

  Future<void> _verifyPurchaseWithServer(PurchaseDetails purchase) async {
    // Replace with your HTTPS endpoint.
    const endpoint = 'https://yourserver.com/iap/verify';
    // Send purchaseDetails to server for validation (signature / receipt).
    // final response = await http.post(Uri.parse(endpoint), body: jsonEncode(purchase.verificationData));
    // if (response.statusCode == 200) {
    //   // Deliver entitlements here.
    //   await _iap.completePurchase(purchase);
    // }
  }

  Future<void> dispose() async {
    await _subscription.cancel();
  }
}