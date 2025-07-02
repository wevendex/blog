import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

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
    // TODO: verify & deliver purchases
  }

  Future<void> dispose() async {
    await _subscription.cancel();
  }
}