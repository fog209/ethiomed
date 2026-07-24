import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethiomed/features/articles/presentation/article_detail_screen.dart';
import 'package:ethiomed/core/widgets/skeleton_widget.dart';

void main() {
  testWidgets('ArticleDetailScreen shows skeleton during loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ArticleDetailScreen(articleId: 'test-article-id'),
        ),
      ),
    );

    // Immediately after pump, the loading state should show skeleton widgets
    expect(find.byType(SkeletonWidget), findsWidgets);
  });
}