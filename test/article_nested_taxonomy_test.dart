import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/core/database/app_database.dart';
import 'package:ethiomed/features/articles/data/article_repository.dart';

// End-to-end coverage of the NESTED taxonomy filtering path: articles stored
// with derived parent_category / subcategory / category_path columns, then
// exercised through the repository's parent-scope and subcategory drill-down
// queries plus the dynamic subcategory list.
void main() {
  late AppDatabase db;
  late ArticleRepository repo;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory' ||
          call.method == 'getTemporaryDirectory' ||
          call.method == 'getApplicationSupportDirectory') {
        return Directory.systemTemp.createTempSync('wardready_test').path;
      }
      return null;
    });
    db = AppDatabase();
    repo = ArticleRepository(null, db, () {}, () {}, () {}, () {}, () {});
    await db.delete(db.articles).go();

    Future<void> seed({
      required String id,
      required String title,
      required String parent,
      required String sub,
    }) =>
        db.into(db.articles).insert(
              ArticlesCompanion.insert(
                id: id,
                title: title,
                category: Value(sub),
                parentCategory: Value(parent),
                subcategory: Value(sub),
                categoryPath: Value('["$parent","$sub"]'),
              ),
            );

    await seed(id: 'c1', title: 'MI Management', parent: 'Internal Medicine', sub: 'Cardiology');
    await seed(id: 'n1', title: 'Stroke Protocol', parent: 'Internal Medicine', sub: 'Neurology');
    await seed(id: 'a1', title: 'Heart Anatomy', parent: 'Anatomy', sub: 'Gross Anatomy');
    await seed(id: 'x1', title: 'Tropical Oddity', parent: 'Unmapped Field', sub: 'Misc');
  });

  tearDown(() async {
    await db.close();
  });

  test('parent-scope query returns only that parent across all subs', () async {
    final page = await repo
        .watchArticlesPaged(
          category: 'Internal Medicine',
          parentCategory: 'Internal Medicine',
          limit: 100,
          offset: 0,
        )
        .first;
    final titles = page.map((a) => a.title).toList();
    expect(titles, containsAll(['MI Management', 'Stroke Protocol']));
    expect(titles, isNot(contains('Heart Anatomy')));
    expect(titles, isNot(contains('Tropical Oddity')));
  });

  test('drill into subcategory narrows to that sub only', () async {
    final page = await repo
        .watchArticlesPaged(
          category: 'Internal Medicine',
          parentCategory: 'Internal Medicine',
          subcategory: 'Cardiology',
          limit: 100,
          offset: 0,
        )
        .first;
    expect(page.map((a) => a.title).toList(), ['MI Management']);
  });

  test('subcategory drill-down is mutually exclusive across subs', () async {
    final neuro = await repo
        .watchArticlesPaged(
          category: 'Internal Medicine',
          parentCategory: 'Internal Medicine',
          subcategory: 'Neurology',
          limit: 100,
          offset: 0,
        )
        .first;
    expect(neuro.map((a) => a.title).toList(), ['Stroke Protocol']);
  });

  test('dynamic subcategory list reflects the parent taxonomy', () async {
    final subs = await db.fetchSubcategories('Internal Medicine');
    expect(subs, containsAll(['Cardiology', 'Neurology']));
    expect(subs, isNot(contains('Gross Anatomy')));
    expect(subs, isNot(contains('Misc')));
  });

  test('parent-only scope (no subcategory) still respects parent boundary',
      () async {
    final count = await repo.countArticlesInCategory(
      'Internal Medicine',
      parentCategory: 'Internal Medicine',
    );
    expect(count, 2);
  });
}
