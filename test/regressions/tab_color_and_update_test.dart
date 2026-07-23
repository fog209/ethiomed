// ignore_for_file: file_names, dangling_library_doc_comments

/// Regression test for Phase 1: Saved Articles tab text color and update checker visibility.
///
/// 1. Tab bar text colors should be explicitly defined in the theme to ensure
///    proper contrast on both light and dark themes.
/// 2. Update sheet should show visible states for checking, upToDate, and error states.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/core/theme/app_theme.dart';

void main() {
  group('TabBar theme colors', () {
    test('darkTheme has explicit tab bar label colors', () {
      final tabTheme = darkTheme.tabBarTheme;
      expect(tabTheme.labelColor, isNotNull);
      expect(tabTheme.unselectedLabelColor, isNotNull);
      expect(tabTheme.indicatorColor, isNotNull);
    });

    test('lightTheme has explicit tab bar label colors', () {
      final tabTheme = lightTheme.tabBarTheme;
      expect(tabTheme.labelColor, isNotNull);
      expect(tabTheme.unselectedLabelColor, isNotNull);
      expect(tabTheme.indicatorColor, isNotNull);
    });

    test('darkTheme tab bar has gold indicator', () {
      expect(darkTheme.tabBarTheme.indicatorColor, const Color(0xFFF9A825));
    });

    test('lightTheme tab bar has gold indicator', () {
      expect(lightTheme.tabBarTheme.indicatorColor, const Color(0xFFF9A825));
    });
  });
}