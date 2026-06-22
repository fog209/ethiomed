import 'package:flutter_test/flutter_test.dart';
import 'package:ethiomed/features/articles/domain/models/article.dart';

void main() {
  group('Article.fromJson', () {
    test('null id returns empty string, does not throw', () {
      final article = Article.fromJson({
        'title': 'Test',
      });
      expect(article.id, equals(''));
    });

    test('null title returns empty string, does not throw', () {
      final article = Article.fromJson({
        'id': '1',
      });
      expect(article.title, equals(''));
    });

    test('malformed date string in any field does not throw', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
        'createdAt': 'not-a-date',
        'updated_at': 'invalid-date-format',
        'published': 'xyz-abc',
      });
      expect(article.id, equals('1'));
      expect(article.title, equals('Test'));
    });

    test('all 10+ content fields parse without crashing when null', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Malaria',
        'content': {
          'definition': null,
          'epidemiology': null,
          'etiology': null,
          'pathophysiology': null,
          'clinicalFeatures': null,
          'diagnosis': null,
          'treatment': null,
          'complications': null,
          'ethiopianContext': null,
          'mnemonics': null,
        },
      });

      expect(article.id, equals('1'));
      expect(article.content, isNotNull);
      for (final key in [
        'definition',
        'epidemiology',
        'etiology',
        'pathophysiology',
        'clinicalFeatures',
        'diagnosis',
        'treatment',
        'complications',
        'ethiopianContext',
        'mnemonics',
      ]) {
        expect(article.content![key], isNull);
      }
    });

    test('missing content field defaults to empty map', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
      });
      expect(article.content, isNotNull);
    });

    test('content as string does not throw, defaults to empty map', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
        'content': 'some string content',
      });
      expect(article.content, isA<Map<String, dynamic>>());
    });

    test('content as int does not throw', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
        'content': 42,
      });
      expect(article.content, isA<Map<String, dynamic>>());
    });

    test('category as null defaults to General', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
        'category': null,
      });
      expect(article.category, equals('General'));
    });

    test('category as empty string defaults to General', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
        'category': '',
      });
      expect(article.category, equals('General'));
    });

    test('category as whitespace defaults to General', () {
      final article = Article.fromJson({
        'id': '1',
        'title': 'Test',
        'category': '   ',
      });
      expect(article.category, equals('General'));
    });
  });
}