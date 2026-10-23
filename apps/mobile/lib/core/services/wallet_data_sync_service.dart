import 'dart:async';

/// Global event bus to synchronize wallet, transaction, and category state
/// across all screens in real-time.
class WalletDataSyncService {
  WalletDataSyncService._();

  static final StreamController<void> _controller = StreamController<void>.broadcast();

  /// Stream that emits whenever transactions, balances, or categories are mutated.
  static Stream<void> get onDataChanged => _controller.stream;

  /// Notify all listening UI screens to re-fetch their data.
  static void notifyDataChanged() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}
