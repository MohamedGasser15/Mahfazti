import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

/// Cross-platform in-app purchase and subscription service for Mahfazti.
///
/// Handles iOS StoreKit 2 and Android Google Play Billing subscription lifecycles,
/// product queries, purchase handling, restoring previous purchases, and
/// backend verification against the ASP.NET Core API.
class IapSubscriptionService extends ChangeNotifier {
  static final IapSubscriptionService _instance =
      IapSubscriptionService._internal();
  factory IapSubscriptionService() => _instance;

  IapSubscriptionService._internal();

  // --- Subscription Product IDs ---
  static const String monthlySubscriptionId = 'mahfazti_premium_monthly';
  static const String yearlySubscriptionId = 'mahfazti_premium_yearly';
  static const Set<String> subscriptionProductIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
  };

  // --- Internal Dependencies & State ---
  InAppPurchasePlatform? _platformForTesting;
  Future<void> Function(PurchaseDetails)? _purchaseVerifierForTesting;
  InAppPurchasePlatform? get _platform {
    if (_platformForTesting != null) return _platformForTesting;
    try {
      // Accessing InAppPurchase.instance registers the underlying platform
      // if not registered already.
      InAppPurchase.instance;
      return InAppPurchasePlatform.instance;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _isInitialized = false;
  bool _isAvailable = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  String? _errorMessage;

  List<ProductDetails> _products = [];
  Map<String, dynamic>? _currentSubscription;

  // Stream controller to broadcast one-shot purchase outcome events to UI
  final StreamController<IapPurchaseEvent> _eventController =
      StreamController<IapPurchaseEvent>.broadcast();

  // --- Public Getters ---
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  bool get isRestoring => _isRestoring;
  String? get errorMessage => _errorMessage;

  List<ProductDetails> get products => List.unmodifiable(_products);
  Stream<IapPurchaseEvent> get events => _eventController.stream;

  ProductDetails? get monthlyProduct {
    try {
      return _products.firstWhere((p) => p.id == monthlySubscriptionId);
    } catch (_) {
      return null;
    }
  }

  ProductDetails? get yearlyProduct {
    try {
      return _products.firstWhere((p) => p.id == yearlySubscriptionId);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? get currentSubscription => _currentSubscription;

  /// Returns true if user has an active Pro subscription either from backend
  /// verification or active store status.
  bool get isPro {
    if (_currentSubscription == null) return false;
    final status = _currentSubscription?['status']?.toString().toLowerCase();
    return status == 'active';
  }

  @visibleForTesting
  set platformForTesting(InAppPurchasePlatform? platform) {
    _platformForTesting = platform;
  }

  @visibleForTesting
  set purchaseVerifierForTesting(
    Future<void> Function(PurchaseDetails)? verifier,
  ) {
    _purchaseVerifierForTesting = verifier;
  }

  @visibleForTesting
  void resetForTesting({InAppPurchasePlatform? platform}) {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _isInitialized = false;
    _isAvailable = false;
    _isLoading = false;
    _isPurchasing = false;
    _isRestoring = false;
    _errorMessage = null;
    _products = [];
    _currentSubscription = null;
    _purchaseVerifierForTesting = null;
    if (platform != null) {
      _platformForTesting = platform;
    }
  }

  // --- Initialization ---

  /// Initializes the purchase stream listener, queries product details,
  /// and synchronizes active subscription state with the backend.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final platform = _platform;
    if (platform == null) {
      _isAvailable = false;
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // Listen to store purchase updates
    _purchaseSubscription?.cancel();
    _purchaseSubscription = platform.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (dynamic error) {
        _isPurchasing = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );

    try {
      _isAvailable = await platform.isAvailable();
      if (_isAvailable) {
        await fetchProducts();
      }
    } catch (e) {
      _isAvailable = false;
      _errorMessage = e.toString();
    }

    // Refresh user's subscription record from backend if logged in
    await fetchCurrentSubscription();

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Queries available subscription products from Apple StoreKit / Google Play Billing.
  Future<void> fetchProducts() async {
    final platform = _platform;
    if (platform == null) return;

    try {
      final response = await platform.queryProductDetails(
        subscriptionProductIds,
      );

      if (response.notFoundIDs.isNotEmpty && kDebugMode) {
        debugPrint(
          '[IAP] Products not found in store: ${response.notFoundIDs}',
        );
      }

      if (response.error != null) {
        _errorMessage = response.error!.message;
      } else {
        _products = response.productDetails;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Initiates non-consumable (auto-renewable) subscription purchase flow.
  Future<bool> buySubscription(ProductDetails product) async {
    final platform = _platform;
    if (platform == null || !_isAvailable) {
      _eventController.add(
        const IapPurchaseEvent(
          type: IapPurchaseEventType.error,
          message: 'Store is not available.',
        ),
      );
      return false;
    }

    _isPurchasing = true;
    _errorMessage = null;
    notifyListeners();

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      final success = await platform.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!success) {
        _isPurchasing = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _isPurchasing = false;
      _errorMessage = e.toString();
      notifyListeners();
      _eventController.add(
        IapPurchaseEvent(
          type: IapPurchaseEventType.error,
          message: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Restores previous purchases on iOS / Google Play.
  Future<void> restorePurchases() async {
    final platform = _platform;
    if (platform == null || !_isAvailable) {
      _eventController.add(
        const IapPurchaseEvent(
          type: IapPurchaseEventType.error,
          message: 'Store is not available.',
        ),
      );
      return;
    }

    _isRestoring = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await platform.restorePurchases();
    } catch (e) {
      _errorMessage = e.toString();
      _eventController.add(
        IapPurchaseEvent(
          type: IapPurchaseEventType.error,
          message: e.toString(),
        ),
      );
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  /// Simulates a local-only purchase for development. It never writes to the API.
  Future<void> simulateLocalPurchase(String productId) async {
    if (!kDebugMode) {
      throw StateError(
        'Local purchase simulation is only available in debug builds.',
      );
    }
    _isPurchasing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSubscription = {
        'status': 'active',
        'productId': productId,
        'isLocalSimulation': true,
      };

      _isPurchasing = false;
      notifyListeners();

      _eventController.add(
        IapPurchaseEvent(
          type: IapPurchaseEventType.purchased,
          productId: productId,
        ),
      );
    } catch (e) {
      _isPurchasing = false;
      _errorMessage = e.toString();
      notifyListeners();
      _eventController.add(
        IapPurchaseEvent(
          type: IapPurchaseEventType.error,
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetches the authenticated user's current subscription from the backend.
  Future<void> fetchCurrentSubscription() async {
    final token = SharedPrefs.authToken;
    if (token == null || token.isEmpty) return;

    try {
      final response = await ApiService().get(
        ApiEndpoints.mySubscription,
        requiresAuth: true,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          _currentSubscription = data;
        } else {
          _currentSubscription = null;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[IAP] Fetch current subscription error: $e');
      }
    }
    notifyListeners();
  }

  /// Cancels the active subscription on the backend and resets local state.
  Future<bool> cancelSubscription() async {
    _isLoading = true;
    notifyListeners();

    bool success = false;
    try {
      if (_currentSubscription?['isLocalSimulation'] == true) {
        _currentSubscription = null;
        success = true;
        return success;
      }
      final token = SharedPrefs.authToken;
      if (token != null && token.isNotEmpty) {
        final response = await ApiService().post(
          ApiEndpoints.cancelSubscription,
          {},
          requiresAuth: true,
        );
        success = response.statusCode == 200;
      } else {
        success = true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[IAP] Error canceling subscription: $e');
      }
    } finally {
      if (success) _currentSubscription = null;
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  // --- Internal Purchase Updates Handler ---

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _isPurchasing = true;
          notifyListeners();
          break;

        case PurchaseStatus.error:
          _isPurchasing = false;
          _errorMessage = purchaseDetails.error?.message ?? 'Purchase error';
          if (purchaseDetails.pendingCompletePurchase && _platform != null) {
            await _platform!.completePurchase(purchaseDetails);
          }
          notifyListeners();
          _eventController.add(
            IapPurchaseEvent(
              type: IapPurchaseEventType.error,
              message: _errorMessage,
            ),
          );
          break;

        case PurchaseStatus.canceled:
          _isPurchasing = false;
          if (purchaseDetails.pendingCompletePurchase && _platform != null) {
            await _platform!.completePurchase(purchaseDetails);
          }
          notifyListeners();
          _eventController.add(
            const IapPurchaseEvent(type: IapPurchaseEventType.canceled),
          );
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final isRestore = purchaseDetails.status == PurchaseStatus.restored;
          try {
            // Verify with Mahfazti backend
            final verifier = _purchaseVerifierForTesting;
            if (verifier == null) {
              await _verifyPurchaseWithBackend(purchaseDetails);
            } else {
              await verifier(purchaseDetails);
            }
          } catch (e) {
            _isPurchasing = false;
            _isRestoring = false;
            _errorMessage = e.toString();
            notifyListeners();
            _eventController.add(
              IapPurchaseEvent(
                type: IapPurchaseEventType.error,
                message: e.toString(),
              ),
            );
            continue;
          }

          // Complete transaction with storekit / play billing
          if (purchaseDetails.pendingCompletePurchase && _platform != null) {
            await _platform!.completePurchase(purchaseDetails);
          }

          _isPurchasing = false;
          _isRestoring = false;
          notifyListeners();

          _eventController.add(
            IapPurchaseEvent(
              type: isRestore
                  ? IapPurchaseEventType.restored
                  : IapPurchaseEventType.purchased,
              productId: purchaseDetails.productID,
            ),
          );
          break;
      }
    }
  }

  /// Verifies receipt/transaction with ASP.NET Core backend to credit user subscription.
  Future<void> _verifyPurchaseWithBackend(PurchaseDetails purchase) async {
    final token = SharedPrefs.authToken;
    if (token == null || token.isEmpty) {
      throw StateError('Sign in before verifying a subscription purchase.');
    }

    final body = {
      'productId': purchase.productID,
      'transactionId': purchase.purchaseID ?? '',
      'purchaseToken': purchase.verificationData.serverVerificationData,
      'platform': Platform.isIOS ? 'ios' : 'android',
    };

    try {
      final response = await ApiService().post(
        ApiEndpoints.verifyIapSubscription,
        body,
        requiresAuth: true,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          _currentSubscription = data;
          return;
        }
      }
      throw StateError(
        'The backend did not confirm the subscription purchase.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[IAP] Failed to verify purchase with backend: $e');
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _eventController.close();
    super.dispose();
  }
}

/// Event types emitted by [IapSubscriptionService.events].
enum IapPurchaseEventType { purchased, restored, canceled, error }

/// Single event model emitted during purchase lifecycle.
class IapPurchaseEvent {
  final IapPurchaseEventType type;
  final String? productId;
  final String? message;

  const IapPurchaseEvent({required this.type, this.productId, this.message});
}
