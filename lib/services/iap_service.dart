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

    _subscription = _iap.purchaseStream.listen((purchases) {
      _listenToPurchases(purchases);
    });
  }

  void _listenToPurchases(List<PurchaseDetails> purchases) {
    // TODO: verify & deliver purchases
  }

  Future<void> dispose() async {
    await _subscription.cancel();
  }
}