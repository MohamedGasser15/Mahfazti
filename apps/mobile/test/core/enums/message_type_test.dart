import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/enums/message_type.dart';

void main() {
  group('MessageType', () {
    test('contains all 4 values', () {
      expect(MessageType.values.length, 4);
    });

    test('contains success', () {
      expect(MessageType.values.contains(MessageType.success), isTrue);
    });

    test('contains error', () {
      expect(MessageType.values.contains(MessageType.error), isTrue);
    });

    test('contains info', () {
      expect(MessageType.values.contains(MessageType.info), isTrue);
    });

    test('contains warning', () {
      expect(MessageType.values.contains(MessageType.warning), isTrue);
    });

    test('.name returns correct string for success', () {
      expect(MessageType.success.name, 'success');
    });

    test('.name returns correct string for error', () {
      expect(MessageType.error.name, 'error');
    });

    test('.name returns correct string for info', () {
      expect(MessageType.info.name, 'info');
    });

    test('.name returns correct string for warning', () {
      expect(MessageType.warning.name, 'warning');
    });
  });
}
