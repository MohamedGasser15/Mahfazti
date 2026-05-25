import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/themes/app_colors.dart';
import 'package:my_wallet/core/themes/app_text_styles.dart';

void main() {
  group('AppTextStyles', () {
    group('body()', () {
      test('returns TextStyle with correct defaults', () {
        final style = AppTextStyles.body();
        expect(style.fontFamily, 'Inter');
        expect(style.fontSize, 14);
        expect(style.fontWeight, FontWeight.w400);
        expect(style.color, isNull);
        expect(style.height, isNull);
      });

      test('accepts custom size, weight, color, height', () {
        final style = AppTextStyles.body(
          size: 16,
          weight: FontWeight.w600,
          color: Colors.red,
          height: 1.5,
        );
        expect(style.fontSize, 16);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.color, Colors.red);
        expect(style.height, 1.5);
      });
    });

    group('heading()', () {
      test('returns TextStyle with correct defaults', () {
        final style = AppTextStyles.heading();
        expect(style.fontFamily, 'Inter');
        expect(style.fontSize, 18);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.color, AppColors.primaryBlack);
      });

      test('accepts custom size, color, weight', () {
        final style = AppTextStyles.heading(
          size: 24,
          color: Colors.blue,
          weight: FontWeight.w300,
        );
        expect(style.fontSize, 24);
        expect(style.color, Colors.blue);
        expect(style.fontWeight, FontWeight.w300);
      });
    });

    group('label()', () {
      test('returns TextStyle with correct defaults', () {
        final style = AppTextStyles.label();
        expect(style.fontFamily, 'Inter');
        expect(style.fontSize, 12);
        expect(style.fontWeight, FontWeight.w500);
        expect(style.color, isNull);
      });
    });

    group('button()', () {
      test('returns TextStyle with correct defaults', () {
        final style = AppTextStyles.button();
        expect(style.fontFamily, 'Inter');
        expect(style.fontSize, 15);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.color, Colors.white);
      });
    });

    group('fieldLabel()', () {
      test('returns TextStyle with correct defaults', () {
        final style = AppTextStyles.fieldLabel();
        expect(style.fontFamily, 'Inter');
        expect(style.fontSize, 14);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.color, AppColors.primaryBlack);
      });
    });

    group('fieldHint()', () {
      test('returns TextStyle with correct defaults', () {
        final style = AppTextStyles.fieldHint();
        expect(style.fontFamily, 'Inter');
        expect(style.color, AppColors.error);
        expect(style.fontSize, 13);
        expect(style.fontWeight, FontWeight.w500);
      });
    });

    test('all styles use Inter font family', () {
      expect(AppTextStyles.body().fontFamily, 'Inter');
      expect(AppTextStyles.heading().fontFamily, 'Inter');
      expect(AppTextStyles.label().fontFamily, 'Inter');
      expect(AppTextStyles.button().fontFamily, 'Inter');
      expect(AppTextStyles.fieldLabel().fontFamily, 'Inter');
      expect(AppTextStyles.fieldHint().fontFamily, 'Inter');
    });
  });
}
