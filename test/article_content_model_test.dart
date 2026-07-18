import 'package:flutter_test/flutter_test.dart';
import 'package:ethiomed/features/articles/models/article_model.dart';

void main() {
  group('ArticleContent.fromJson — legacy (no schemaVersion) shape', () {
    test('converts non-empty fixed fields to sections in canonical order', () {
      final content = ArticleContent.fromJson({
        'definition': 'A fever illness.',
        'treatment': 'Fluids.',
        'mnemonics': 'DRIP.',
      });
      // Legacy content (no schemaVersion key) is normalized to the new
      // representation; fromJson discriminates on source shape, not on the
      // resulting schemaVersion field. The sections are what matter.
      expect(content.sections.map((s) => s.key).toList(),
          equals(['definition', 'treatment', 'mnemonics']));
      expect(content.bodyFor('definition'), equals('A fever illness.'));
      expect(content.bodyFor('treatment'), equals('Fluids.'));
    });

    test('skips empty/null legacy fields', () {
      final content = ArticleContent.fromJson({
        'definition': 'Present.',
        'epidemiology': '',
        'etiology': null,
        'mnemonics': '   ',
      });
      expect(content.sections.map((s) => s.key).toList(),
          equals(['definition']));
    });

    test('empty map yields no sections', () {
      final content = ArticleContent.fromJson({});
      expect(content.sections, isEmpty);
    });
  });

  group('ArticleContent.fromJson — new (schemaVersion: 2) shape', () {
    test('parses sections array, drops empty bodies', () {
      final content = ArticleContent.fromJson({
        'schemaVersion': 2,
        'sections': [
          {'key': 'definition', 'body': 'X'},
          {'key': 'redFlags', 'body': ''},
          {'key': '', 'body': 'orphan'},
        ],
      });
      expect(content.schemaVersion, equals(2));
      expect(content.sections.map((s) => s.key).toList(), equals(['definition']));
    });

    test('preserves section array order', () {
      final content = ArticleContent.fromJson({
        'schemaVersion': 2,
        'sections': [
          {'key': 'diagnosis', 'body': 'D'},
          {'key': 'treatment', 'body': 'T'},
        ],
      });
      expect(content.sections.map((s) => s.key).toList(),
          equals(['diagnosis', 'treatment']));
    });
  });

  group('ArticleSection serialization', () {
    test('round-trips through toJson', () {
      const section = ArticleSection(key: 'examTraps', body: 'B');
      final json = section.toJson();
      expect(json, equals({'key': 'examTraps', 'body': 'B'}));
      final back = ArticleSection.fromJson(json);
      expect(back.key, equals('examTraps'));
      expect(back.body, equals('B'));
    });
  });

  group('humanize fallback (future dynamic keys)', () {
    test('camelCase key becomes title-case label via humanize', () {
      // Mirrors the renderer's _humanizeKey behavior used for unknown keys.
      String humanize(String key) {
        final spaced = key.replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (m) => ' ${m[0]}',
        );
        final trimmed = spaced.trim();
        return trimmed[0].toUpperCase() + trimmed.substring(1);
      }

      expect(humanize('theWardScenario'), equals('The Ward Scenario'));
      expect(humanize('redFlags'), equals('Red Flags'));
    });
  });
}
