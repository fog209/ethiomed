import 'package:flutter_test/flutter_test.dart';
import 'package:ethiomed/features/articles/presentation/article_markdown_helpers.dart';

void main() {
  group('applyHighYieldFilter — scoped tier filtering', () {
    test('drops only 🟡 Strong bullets within a tagged section', () {
      const body = '''
- 🔴 Core: Always check the airway.
- 🟡 Strong: Document the time of onset.
- ⭐ Sharp: Suspect dissection if back pain.
- Plain untagged bullet that must stay.
''';
      final result = applyHighYieldFilter(body);
      expect(result.contains('🔴 Core'), isTrue);
      expect(result.contains('⭐ Sharp'), isTrue);
      expect(result.contains('Plain untagged bullet'), isTrue);
      expect(result.contains('🟡 Strong'), isFalse);
    });

    test('leaves an untagged section (zero tier tags) completely unchanged', () {
      const body = '''
A prose paragraph explaining the mechanism.

- First necessary bullet.
- Second necessary bullet.
''';
      final result = applyHighYieldFilter(body);
      expect(result, equals(body));
    });

    test('section with only Core/Sharp tags keeps every line', () {
      const body = '''
- 🔴 Core: Step one.
- ⭐ Sharp: Step two.
''';
      final result = applyHighYieldFilter(body);
      expect(result, equals(body));
    });

    test('section containing only Strong tags is emptied of bullets', () {
      const body = '''
- 🟡 Strong: Optional detail A.
- 🟡 Strong: Optional detail B.
''';
      final result = applyHighYieldFilter(body);
      expect(result.trim(), isEmpty);
    });
  });
}
