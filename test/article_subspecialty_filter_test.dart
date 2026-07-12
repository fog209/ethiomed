import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/core/database/app_database.dart';
import 'package:ethiomed/features/articles/data/article_repository.dart';

const _im = 'Internal Medicine';
const _imSubs = <String>[
  'Cardiology',
  'Neurology',
  'Nephrology',
  'Pulmonology',
  'Infectious Diseases',
  'Gastroenterology',
  'Endocrinology',
];

void main() {
  late AppDatabase db;
  late ArticleRepository repo;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // path_provider has no native impl in the unit-test runner; point the
    // documents directory at a writable temp path so the DB can open.
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

    // Seed the exact scenario described in the bug report.
    Future<void> seed({
      required String id,
      required String title,
      required String parent,
      String? sub,
    }) async {
      await db.into(db.articles).insert(
            ArticlesCompanion.insert(
              id: id,
              title: title,
              category: Value(sub?.isNotEmpty == true ? sub! : parent),
              parentCategory: Value(parent),
              subcategory: Value(sub),
            ),
          );
    }

    // Misplaced article from a DIFFERENT parent — must never leak into IM.
    await seed(id: 'a1', title: 'Acute Appendicitis', parent: 'General Surgery');
    // One article per IM subspecialty.
    await seed(id: 'c1', title: 'MI Management', parent: _im, sub: 'Cardiology');
    await seed(id: 'n1', title: 'Stroke Protocol', parent: _im, sub: 'Neurology');
    await seed(id: 'k1', title: 'Nephrotic Syndrome', parent: _im, sub: 'Nephrology');
    await seed(id: 'p1', title: 'Pneumonia', parent: _im, sub: 'Pulmonology');
    await seed(
      id: 'i1',
      title: 'Sepsis',
      parent: _im,
      sub: 'Infectious Diseases',
    );
    await seed(
      id: 'g1',
      title: 'Inflammatory Bowel Disease',
      parent: _im,
      sub: 'Gastroenterology',
    );
    await seed(
      id: 'e1',
      title: 'Diabetes Mellitus',
      parent: _im,
      sub: 'Endocrinology',
    );
    // IM articles with NO subspecialty — must match NONE of the 7 filters.
    await seed(id: 'im1', title: 'Hypertension', parent: _im);
    await seed(id: 'im2', title: 'General Medicine Overview', parent: _im);
  });

  tearDown(() async {
    await db.close();
  });

  test('subspecialty filter requires BOTH parentCategory AND subcategory',
      () async {
    for (final sub in _imSubs) {
      final page = await repo
          .watchArticlesPaged(
            category: _im,
            parentCategory: _im,
            subcategory: sub,
            limit: 100,
            offset: 0,
          )
          .first;
      expect(page.map((a) => a.title).toList(), [_titleFor(sub)],
          reason: 'sub=$sub should return exactly its own article');
    }
  });

  test('Acute Appendicitis does NOT leak into any IM subspecialty', () async {
    for (final sub in _imSubs) {
      final page = await repo
          .watchArticlesPaged(
            category: _im,
            parentCategory: _im,
            subcategory: sub,
            limit: 100,
            offset: 0,
          )
          .first;
      final titles = page.map((a) => a.title).toList();
      expect(titles, isNot(contains('Acute Appendicitis')),
          reason: 'sub=$sub must not contain the Surgery article');
    }
  });

  test('IM articles with subcategory=null match NONE of the 7 filters',
      () async {
    for (final sub in _imSubs) {
      final count = await repo.countArticlesInCategory(
        _im,
        subcategory: sub,
        parentCategory: _im,
      );
      expect(count, 1,
          reason: 'sub=$sub should have exactly 1 article (no null-sub IM leak)');
    }
  });

  test('new Pediatrics / OB-GYN / ENT subspecialties return 0 articles',
      () async {
    const cases = <(String, String)>[
      ('Pediatrics', 'Neonatology'),
      ('Pediatrics', 'Pediatric Cardiology'),
      ('OB/GYN', 'Antenatal Care & Normal Pregnancy'),
      ('OB/GYN', 'Postpartum Care'),
      ('ENT', 'Ear & Hearing (Otology)'),
      ('ENT', 'Head & Neck Masses'),
    ];
    for (final (parent, sub) in cases) {
      final count = await repo.countArticlesInCategory(
        parent,
        subcategory: sub,
        parentCategory: parent,
      );
      expect(count, 0, reason: '$parent/$sub should be empty');
    }
  });
}

String _titleFor(String sub) {
  switch (sub) {
    case 'Cardiology':
      return 'MI Management';
    case 'Neurology':
      return 'Stroke Protocol';
    case 'Nephrology':
      return 'Nephrotic Syndrome';
    case 'Pulmonology':
      return 'Pneumonia';
    case 'Infectious Diseases':
      return 'Sepsis';
    case 'Gastroenterology':
      return 'Inflammatory Bowel Disease';
    case 'Endocrinology':
      return 'Diabetes Mellitus';
    default:
      return '';
  }
}
