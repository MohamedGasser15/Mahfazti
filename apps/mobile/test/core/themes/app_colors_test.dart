import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/themes/app_colors.dart';

void main() {
  group('AppColors', () {
    test('all primary colors are defined', () {
      expect(AppColors.primaryBlack, isNotNull);
      expect(AppColors.primaryWhite, isNotNull);
    });

    test('primaryBlack is black', () {
      expect(AppColors.primaryBlack, const Color(0xFF000000));
    });

    test('primaryWhite is white', () {
      expect(AppColors.primaryWhite, const Color(0xFFFFFFFF));
    });

    group('gray colors', () {
      test('gray100 is defined', () {
        expect(AppColors.gray100, const Color(0xFFF5F5F5));
      });
      test('gray200 is defined', () {
        expect(AppColors.gray200, const Color(0xFFEEEEEE));
      });
      test('gray300 is defined', () {
        expect(AppColors.gray300, const Color(0xFFE0E0E0));
      });
      test('gray400 is defined', () {
        expect(AppColors.gray400, const Color(0xFFBDBDBD));
      });
      test('gray500 is defined', () {
        expect(AppColors.gray500, const Color(0xFF9E9E9E));
      });
      test('gray600 is defined', () {
        expect(AppColors.gray600, const Color(0xFF757575));
      });
      test('gray700 is defined', () {
        expect(AppColors.gray700, const Color(0xFF616161));
      });
      test('gray800 is defined', () {
        expect(AppColors.gray800, const Color(0xFF424242));
      });
      test('gray900 is defined', () {
        expect(AppColors.gray900, const Color(0xFF212121));
      });
    });

    group('accent colors', () {
      test('accentBlue is defined', () {
        expect(AppColors.accentBlue, const Color(0xFF2962FF));
      });
      test('accentGreen is defined', () {
        expect(AppColors.accentGreen, const Color(0xFF00C853));
      });
      test('accentRed is defined', () {
        expect(AppColors.accentRed, const Color(0xFFD32F2F));
      });
      test('accentYellow is defined', () {
        expect(AppColors.accentYellow, const Color(0xFFFFD600));
      });
    });

    group('semantic colors', () {
      test('success is defined', () {
        expect(AppColors.success, const Color(0xFF4CAF50));
      });
      test('warning is defined', () {
        expect(AppColors.warning, const Color(0xFFFF9800));
      });
      test('error is defined', () {
        expect(AppColors.error, const Color(0xFFF44336));
      });
      test('info is defined', () {
        expect(AppColors.info, const Color(0xFF2196F3));
      });
    });
  });
}
