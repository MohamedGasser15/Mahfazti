import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:my_wallet/core/services/iap_subscription_service.dart';

class _FakeProductDetails extends ProductDetails {
  _FakeProductDetails({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.rawPrice,
    required super.currencyCode,
  });
}

class _FakePurchaseDetails extends PurchaseDetails {
  _FakePurchaseDetails({
    required super.productID,
    required super.purchaseID,
    required super.verificationData,
    required super.transactionDate,
    required super.status,
  });
}

class _FakeInAppPurchasePlatform extends InAppPurchasePlatform {
  final StreamController<List<PurchaseDetails>> _streamController =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  List<ProductDetails> mockProducts = [];
  bool buySuccess = true;
  PurchaseParam? lastPurchaseParam;
  PurchaseDetails? lastCompletedPurchase;
  int restoreCalls = 0;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _streamController.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
      Set<String> identifiers) async {
    return ProductDetailsResponse(
      productDetails: mockProducts,
      notFoundIDs: const [],
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    lastPurchaseParam = purchaseParam;
    return buySuccess;
  }

  @override
  Future<bool> buyConsumable(
      {required PurchaseParam purchaseParam, bool autoConsume = true}) async {
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    lastCompletedPurchase = purchase;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreCalls++;
  }

  void emitPurchases(List<PurchaseDetails> purchases) {
    _streamController.add(purchases);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeInAppPurchasePlatform fakePlatform;
  late IapSubscriptionService service;

  setUp(() async {
    fakePlatform = _FakeInAppPurchasePlatform();
    service = IapSubscriptionService();
    service.resetForTesting(platform: fakePlatform);
    await service.initialize();
  });

  group('IapSubscriptionService', () {
    test('initializes and queries subscription products', () async {
      fakePlatform.mockProducts = [
        _FakeProductDetails(
          id: IapSubscriptionService.monthlySubscriptionId,
          title: 'Mahfazti Monthly',
          description: 'Monthly Sub',
          price: '\$2.99',
          rawPrice: 2.99,
          currencyCode: 'USD',
        ),
        _FakeProductDetails(
          id: IapSubscriptionService.yearlySubscriptionId,
          title: 'Mahfazti Yearly',
          description: 'Yearly Sub',
          price: '\$24.99',
          rawPrice: 24.99,
          currencyCode: 'USD',
        ),
      ];

      await service.fetchProducts();

      expect(service.isAvailable, isTrue);
      expect(service.products.length, 2);
      expect(service.monthlyProduct?.price, '\$2.99');
      expect(service.yearlyProduct?.price, '\$24.99');
    });

    test('buySubscription initiates non-consumable purchase with store',
        () async {
      final product = _FakeProductDetails(
        id: IapSubscriptionService.monthlySubscriptionId,
        title: 'Mahfazti Monthly',
        description: 'Monthly Sub',
        price: '\$2.99',
        rawPrice: 2.99,
        currencyCode: 'USD',
      );

      final success = await service.buySubscription(product);

      expect(success, isTrue);
      expect(fakePlatform.lastPurchaseParam?.productDetails.id,
          IapSubscriptionService.monthlySubscriptionId);
    });

    test('restorePurchases calls storekit restore', () async {
      await service.restorePurchases();
      expect(fakePlatform.restoreCalls, 1);
    });

    test('handles purchased status and completes purchase', () async {
      service.purchaseVerifierForTesting = (_) async {};
      final purchase = _FakePurchaseDetails(
        productID: IapSubscriptionService.monthlySubscriptionId,
        purchaseID: 'tx_123',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local',
          serverVerificationData: 'server',
          source: 'apple_app_store',
        ),
        transactionDate: '12345678',
        status: PurchaseStatus.purchased,
      );
      purchase.pendingCompletePurchase = true;

      final events = <IapPurchaseEvent>[];
      final sub = service.events.listen(events.add);

      fakePlatform.emitPurchases([purchase]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first.type, IapPurchaseEventType.purchased);
      expect(fakePlatform.lastCompletedPurchase?.purchaseID, 'tx_123');

      await sub.cancel();
    });

    test('handles canceled purchase status and completes pending purchase',
        () async {
      final purchase = _FakePurchaseDetails(
        productID: IapSubscriptionService.monthlySubscriptionId,
        purchaseID: 'tx_456',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local',
          serverVerificationData: 'server',
          source: 'apple_app_store',
        ),
        transactionDate: '12345678',
        status: PurchaseStatus.canceled,
      );
      purchase.pendingCompletePurchase = true;

      final events = <IapPurchaseEvent>[];
      final sub = service.events.listen(events.add);

      fakePlatform.emitPurchases([purchase]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first.type, IapPurchaseEventType.canceled);
      expect(fakePlatform.lastCompletedPurchase?.purchaseID, 'tx_456');

      await sub.cancel();
    });
  });
}
