// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ArticlesTable extends Articles
    with TableInfo<$ArticlesTable, ArticleLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoUrlMeta = const VerificationMeta(
    'videoUrl',
  );
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
    'video_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHighYieldMeta = const VerificationMeta(
    'isHighYield',
  );
  @override
  late final GeneratedColumn<bool> isHighYield = GeneratedColumn<bool>(
    'is_high_yield',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_high_yield" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    content,
    imageUrl,
    videoUrl,
    subcategory,
    isHighYield,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('video_url')) {
      context.handle(
        _videoUrlMeta,
        videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta),
      );
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('is_high_yield')) {
      context.handle(
        _isHighYieldMeta,
        isHighYield.isAcceptableOrUnknown(
          data['is_high_yield']!,
          _isHighYieldMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      videoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_url'],
      ),
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      isHighYield: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_high_yield'],
      )!,
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class ArticleLocal extends DataClass implements Insertable<ArticleLocal> {
  final String id;
  final String title;
  final String? category;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final String? subcategory;
  final bool isHighYield;
  const ArticleLocal({
    required this.id,
    required this.title,
    this.category,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.subcategory,
    required this.isHighYield,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    map['is_high_yield'] = Variable<bool>(isHighYield);
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      title: Value(title),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      isHighYield: Value(isHighYield),
    );
  }

  factory ArticleLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleLocal(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String?>(json['category']),
      content: serializer.fromJson<String?>(json['content']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      isHighYield: serializer.fromJson<bool>(json['isHighYield']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String?>(category),
      'content': serializer.toJson<String?>(content),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'subcategory': serializer.toJson<String?>(subcategory),
      'isHighYield': serializer.toJson<bool>(isHighYield),
    };
  }

  ArticleLocal copyWith({
    String? id,
    String? title,
    Value<String?> category = const Value.absent(),
    Value<String?> content = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> videoUrl = const Value.absent(),
    Value<String?> subcategory = const Value.absent(),
    bool? isHighYield,
  }) => ArticleLocal(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category.present ? category.value : this.category,
    content: content.present ? content.value : this.content,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    isHighYield: isHighYield ?? this.isHighYield,
  );
  ArticleLocal copyWithCompanion(ArticlesCompanion data) {
    return ArticleLocal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      content: data.content.present ? data.content.value : this.content,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      isHighYield: data.isHighYield.present
          ? data.isHighYield.value
          : this.isHighYield,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleLocal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('content: $content, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('subcategory: $subcategory, ')
          ..write('isHighYield: $isHighYield')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    content,
    imageUrl,
    videoUrl,
    subcategory,
    isHighYield,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleLocal &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.content == this.content &&
          other.imageUrl == this.imageUrl &&
          other.videoUrl == this.videoUrl &&
          other.subcategory == this.subcategory &&
          other.isHighYield == this.isHighYield);
}

class ArticlesCompanion extends UpdateCompanion<ArticleLocal> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> category;
  final Value<String?> content;
  final Value<String?> imageUrl;
  final Value<String?> videoUrl;
  final Value<String?> subcategory;
  final Value<bool> isHighYield;
  final Value<int> rowid;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.content = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.isHighYield = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesCompanion.insert({
    required String id,
    required String title,
    this.category = const Value.absent(),
    this.content = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.isHighYield = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<ArticleLocal> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? content,
    Expression<String>? imageUrl,
    Expression<String>? videoUrl,
    Expression<String>? subcategory,
    Expression<bool>? isHighYield,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (content != null) 'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (subcategory != null) 'subcategory': subcategory,
      if (isHighYield != null) 'is_high_yield': isHighYield,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? category,
    Value<String?>? content,
    Value<String?>? imageUrl,
    Value<String?>? videoUrl,
    Value<String?>? subcategory,
    Value<bool>? isHighYield,
    Value<int>? rowid,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      subcategory: subcategory ?? this.subcategory,
      isHighYield: isHighYield ?? this.isHighYield,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (isHighYield.present) {
      map['is_high_yield'] = Variable<bool>(isHighYield.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('content: $content, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('subcategory: $subcategory, ')
          ..write('isHighYield: $isHighYield, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, articleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String articleId;
  const Bookmark({required this.id, required this.articleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['article_id'] = Variable<String>(articleId);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(id: Value(id), articleId: Value(articleId));
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      articleId: serializer.fromJson<String>(json['articleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'articleId': serializer.toJson<String>(articleId),
    };
  }

  Bookmark copyWith({int? id, String? articleId}) =>
      Bookmark(id: id ?? this.id, articleId: articleId ?? this.articleId);
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('articleId: $articleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, articleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.articleId == this.articleId);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String> articleId;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String articleId,
  }) : articleId = Value(articleId);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? articleId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
    });
  }

  BookmarksCompanion copyWith({Value<int>? id, Value<String>? articleId}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articlesViewedCountMeta =
      const VerificationMeta('articlesViewedCount');
  @override
  late final GeneratedColumn<int> articlesViewedCount = GeneratedColumn<int>(
    'articles_viewed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [date, articlesViewedCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('articles_viewed_count')) {
      context.handle(
        _articlesViewedCountMeta,
        articlesViewedCount.isAcceptableOrUnknown(
          data['articles_viewed_count']!,
          _articlesViewedCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      articlesViewedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}articles_viewed_count'],
      )!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final DateTime date;
  final int articlesViewedCount;
  const StudySession({required this.date, required this.articlesViewedCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['articles_viewed_count'] = Variable<int>(articlesViewedCount);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      date: Value(date),
      articlesViewedCount: Value(articlesViewedCount),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      date: serializer.fromJson<DateTime>(json['date']),
      articlesViewedCount: serializer.fromJson<int>(
        json['articlesViewedCount'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'articlesViewedCount': serializer.toJson<int>(articlesViewedCount),
    };
  }

  StudySession copyWith({DateTime? date, int? articlesViewedCount}) =>
      StudySession(
        date: date ?? this.date,
        articlesViewedCount: articlesViewedCount ?? this.articlesViewedCount,
      );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      date: data.date.present ? data.date.value : this.date,
      articlesViewedCount: data.articlesViewedCount.present
          ? data.articlesViewedCount.value
          : this.articlesViewedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('date: $date, ')
          ..write('articlesViewedCount: $articlesViewedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, articlesViewedCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.date == this.date &&
          other.articlesViewedCount == this.articlesViewedCount);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<DateTime> date;
  final Value<int> articlesViewedCount;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.date = const Value.absent(),
    this.articlesViewedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required DateTime date,
    this.articlesViewedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<StudySession> custom({
    Expression<DateTime>? date,
    Expression<int>? articlesViewedCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (articlesViewedCount != null)
        'articles_viewed_count': articlesViewedCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith({
    Value<DateTime>? date,
    Value<int>? articlesViewedCount,
    Value<int>? rowid,
  }) {
    return StudySessionsCompanion(
      date: date ?? this.date,
      articlesViewedCount: articlesViewedCount ?? this.articlesViewedCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (articlesViewedCount.present) {
      map['articles_viewed_count'] = Variable<int>(articlesViewedCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('date: $date, ')
          ..write('articlesViewedCount: $articlesViewedCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizQuestionsTable extends QuizQuestions
    with TableInfo<$QuizQuestionsTable, QuizQuestionLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stemMeta = const VerificationMeta('stem');
  @override
  late final GeneratedColumn<String> stem = GeneratedColumn<String>(
    'stem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionAMeta = const VerificationMeta(
    'optionA',
  );
  @override
  late final GeneratedColumn<String> optionA = GeneratedColumn<String>(
    'option_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionBMeta = const VerificationMeta(
    'optionB',
  );
  @override
  late final GeneratedColumn<String> optionB = GeneratedColumn<String>(
    'option_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionCMeta = const VerificationMeta(
    'optionC',
  );
  @override
  late final GeneratedColumn<String> optionC = GeneratedColumn<String>(
    'option_c',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionDMeta = const VerificationMeta(
    'optionD',
  );
  @override
  late final GeneratedColumn<String> optionD = GeneratedColumn<String>(
    'option_d',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctOptionMeta = const VerificationMeta(
    'correctOption',
  );
  @override
  late final GeneratedColumn<String> correctOption = GeneratedColumn<String>(
    'correct_option',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    articleId,
    stem,
    optionA,
    optionB,
    optionC,
    optionD,
    correctOption,
    explanation,
    category,
    difficulty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizQuestionLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    }
    if (data.containsKey('stem')) {
      context.handle(
        _stemMeta,
        stem.isAcceptableOrUnknown(data['stem']!, _stemMeta),
      );
    } else if (isInserting) {
      context.missing(_stemMeta);
    }
    if (data.containsKey('option_a')) {
      context.handle(
        _optionAMeta,
        optionA.isAcceptableOrUnknown(data['option_a']!, _optionAMeta),
      );
    } else if (isInserting) {
      context.missing(_optionAMeta);
    }
    if (data.containsKey('option_b')) {
      context.handle(
        _optionBMeta,
        optionB.isAcceptableOrUnknown(data['option_b']!, _optionBMeta),
      );
    } else if (isInserting) {
      context.missing(_optionBMeta);
    }
    if (data.containsKey('option_c')) {
      context.handle(
        _optionCMeta,
        optionC.isAcceptableOrUnknown(data['option_c']!, _optionCMeta),
      );
    } else if (isInserting) {
      context.missing(_optionCMeta);
    }
    if (data.containsKey('option_d')) {
      context.handle(
        _optionDMeta,
        optionD.isAcceptableOrUnknown(data['option_d']!, _optionDMeta),
      );
    } else if (isInserting) {
      context.missing(_optionDMeta);
    }
    if (data.containsKey('correct_option')) {
      context.handle(
        _correctOptionMeta,
        correctOption.isAcceptableOrUnknown(
          data['correct_option']!,
          _correctOptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctOptionMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizQuestionLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizQuestionLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      ),
      stem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stem'],
      )!,
      optionA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_a'],
      )!,
      optionB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_b'],
      )!,
      optionC: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_c'],
      )!,
      optionD: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_d'],
      )!,
      correctOption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_option'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
    );
  }

  @override
  $QuizQuestionsTable createAlias(String alias) {
    return $QuizQuestionsTable(attachedDatabase, alias);
  }
}

class QuizQuestionLocal extends DataClass
    implements Insertable<QuizQuestionLocal> {
  final int id;
  final String? articleId;
  final String stem;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String? explanation;
  final String? category;
  final String? difficulty;
  const QuizQuestionLocal({
    required this.id,
    this.articleId,
    required this.stem,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.explanation,
    this.category,
    this.difficulty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || articleId != null) {
      map['article_id'] = Variable<String>(articleId);
    }
    map['stem'] = Variable<String>(stem);
    map['option_a'] = Variable<String>(optionA);
    map['option_b'] = Variable<String>(optionB);
    map['option_c'] = Variable<String>(optionC);
    map['option_d'] = Variable<String>(optionD);
    map['correct_option'] = Variable<String>(correctOption);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    return map;
  }

  QuizQuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuizQuestionsCompanion(
      id: Value(id),
      articleId: articleId == null && nullToAbsent
          ? const Value.absent()
          : Value(articleId),
      stem: Value(stem),
      optionA: Value(optionA),
      optionB: Value(optionB),
      optionC: Value(optionC),
      optionD: Value(optionD),
      correctOption: Value(correctOption),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
    );
  }

  factory QuizQuestionLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizQuestionLocal(
      id: serializer.fromJson<int>(json['id']),
      articleId: serializer.fromJson<String?>(json['articleId']),
      stem: serializer.fromJson<String>(json['stem']),
      optionA: serializer.fromJson<String>(json['optionA']),
      optionB: serializer.fromJson<String>(json['optionB']),
      optionC: serializer.fromJson<String>(json['optionC']),
      optionD: serializer.fromJson<String>(json['optionD']),
      correctOption: serializer.fromJson<String>(json['correctOption']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      category: serializer.fromJson<String?>(json['category']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'articleId': serializer.toJson<String?>(articleId),
      'stem': serializer.toJson<String>(stem),
      'optionA': serializer.toJson<String>(optionA),
      'optionB': serializer.toJson<String>(optionB),
      'optionC': serializer.toJson<String>(optionC),
      'optionD': serializer.toJson<String>(optionD),
      'correctOption': serializer.toJson<String>(correctOption),
      'explanation': serializer.toJson<String?>(explanation),
      'category': serializer.toJson<String?>(category),
      'difficulty': serializer.toJson<String?>(difficulty),
    };
  }

  QuizQuestionLocal copyWith({
    int? id,
    Value<String?> articleId = const Value.absent(),
    String? stem,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctOption,
    Value<String?> explanation = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> difficulty = const Value.absent(),
  }) => QuizQuestionLocal(
    id: id ?? this.id,
    articleId: articleId.present ? articleId.value : this.articleId,
    stem: stem ?? this.stem,
    optionA: optionA ?? this.optionA,
    optionB: optionB ?? this.optionB,
    optionC: optionC ?? this.optionC,
    optionD: optionD ?? this.optionD,
    correctOption: correctOption ?? this.correctOption,
    explanation: explanation.present ? explanation.value : this.explanation,
    category: category.present ? category.value : this.category,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
  );
  QuizQuestionLocal copyWithCompanion(QuizQuestionsCompanion data) {
    return QuizQuestionLocal(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      stem: data.stem.present ? data.stem.value : this.stem,
      optionA: data.optionA.present ? data.optionA.value : this.optionA,
      optionB: data.optionB.present ? data.optionB.value : this.optionB,
      optionC: data.optionC.present ? data.optionC.value : this.optionC,
      optionD: data.optionD.present ? data.optionD.value : this.optionD,
      correctOption: data.correctOption.present
          ? data.correctOption.value
          : this.correctOption,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionLocal(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('stem: $stem, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctOption: $correctOption, ')
          ..write('explanation: $explanation, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    articleId,
    stem,
    optionA,
    optionB,
    optionC,
    optionD,
    correctOption,
    explanation,
    category,
    difficulty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizQuestionLocal &&
          other.id == this.id &&
          other.articleId == this.articleId &&
          other.stem == this.stem &&
          other.optionA == this.optionA &&
          other.optionB == this.optionB &&
          other.optionC == this.optionC &&
          other.optionD == this.optionD &&
          other.correctOption == this.correctOption &&
          other.explanation == this.explanation &&
          other.category == this.category &&
          other.difficulty == this.difficulty);
}

class QuizQuestionsCompanion extends UpdateCompanion<QuizQuestionLocal> {
  final Value<int> id;
  final Value<String?> articleId;
  final Value<String> stem;
  final Value<String> optionA;
  final Value<String> optionB;
  final Value<String> optionC;
  final Value<String> optionD;
  final Value<String> correctOption;
  final Value<String?> explanation;
  final Value<String?> category;
  final Value<String?> difficulty;
  const QuizQuestionsCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    this.stem = const Value.absent(),
    this.optionA = const Value.absent(),
    this.optionB = const Value.absent(),
    this.optionC = const Value.absent(),
    this.optionD = const Value.absent(),
    this.correctOption = const Value.absent(),
    this.explanation = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
  });
  QuizQuestionsCompanion.insert({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    required String stem,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctOption,
    this.explanation = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
  }) : stem = Value(stem),
       optionA = Value(optionA),
       optionB = Value(optionB),
       optionC = Value(optionC),
       optionD = Value(optionD),
       correctOption = Value(correctOption);
  static Insertable<QuizQuestionLocal> custom({
    Expression<int>? id,
    Expression<String>? articleId,
    Expression<String>? stem,
    Expression<String>? optionA,
    Expression<String>? optionB,
    Expression<String>? optionC,
    Expression<String>? optionD,
    Expression<String>? correctOption,
    Expression<String>? explanation,
    Expression<String>? category,
    Expression<String>? difficulty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
      if (stem != null) 'stem': stem,
      if (optionA != null) 'option_a': optionA,
      if (optionB != null) 'option_b': optionB,
      if (optionC != null) 'option_c': optionC,
      if (optionD != null) 'option_d': optionD,
      if (correctOption != null) 'correct_option': correctOption,
      if (explanation != null) 'explanation': explanation,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
    });
  }

  QuizQuestionsCompanion copyWith({
    Value<int>? id,
    Value<String?>? articleId,
    Value<String>? stem,
    Value<String>? optionA,
    Value<String>? optionB,
    Value<String>? optionC,
    Value<String>? optionD,
    Value<String>? correctOption,
    Value<String?>? explanation,
    Value<String?>? category,
    Value<String?>? difficulty,
  }) {
    return QuizQuestionsCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      stem: stem ?? this.stem,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctOption: correctOption ?? this.correctOption,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (stem.present) {
      map['stem'] = Variable<String>(stem.value);
    }
    if (optionA.present) {
      map['option_a'] = Variable<String>(optionA.value);
    }
    if (optionB.present) {
      map['option_b'] = Variable<String>(optionB.value);
    }
    if (optionC.present) {
      map['option_c'] = Variable<String>(optionC.value);
    }
    if (optionD.present) {
      map['option_d'] = Variable<String>(optionD.value);
    }
    if (correctOption.present) {
      map['correct_option'] = Variable<String>(correctOption.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('stem: $stem, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctOption: $correctOption, ')
          ..write('explanation: $explanation, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }
}

class $QuizTableTable extends QuizTable
    with TableInfo<$QuizTableTable, QuizQuestionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stemMeta = const VerificationMeta('stem');
  @override
  late final GeneratedColumn<String> stem = GeneratedColumn<String>(
    'stem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionAMeta = const VerificationMeta(
    'optionA',
  );
  @override
  late final GeneratedColumn<String> optionA = GeneratedColumn<String>(
    'option_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionBMeta = const VerificationMeta(
    'optionB',
  );
  @override
  late final GeneratedColumn<String> optionB = GeneratedColumn<String>(
    'option_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionCMeta = const VerificationMeta(
    'optionC',
  );
  @override
  late final GeneratedColumn<String> optionC = GeneratedColumn<String>(
    'option_c',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionDMeta = const VerificationMeta(
    'optionD',
  );
  @override
  late final GeneratedColumn<String> optionD = GeneratedColumn<String>(
    'option_d',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctOptionMeta = const VerificationMeta(
    'correctOption',
  );
  @override
  late final GeneratedColumn<String> correctOption = GeneratedColumn<String>(
    'correct_option',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _testedFieldMeta = const VerificationMeta(
    'testedField',
  );
  @override
  late final GeneratedColumn<String> testedField = GeneratedColumn<String>(
    'tested_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('clinicalFeatures'),
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptedAtMeta = const VerificationMeta(
    'lastAttemptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptedAt =
      GeneratedColumn<DateTime>(
        'last_attempted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _srIntervalMeta = const VerificationMeta(
    'srInterval',
  );
  @override
  late final GeneratedColumn<int> srInterval = GeneratedColumn<int>(
    'sr_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    articleId,
    stem,
    optionA,
    optionB,
    optionC,
    optionD,
    correctOption,
    explanation,
    category,
    difficulty,
    testedField,
    wrongCount,
    lastAttemptedAt,
    srInterval,
    repetitions,
    nextDueAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizQuestionEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('stem')) {
      context.handle(
        _stemMeta,
        stem.isAcceptableOrUnknown(data['stem']!, _stemMeta),
      );
    } else if (isInserting) {
      context.missing(_stemMeta);
    }
    if (data.containsKey('option_a')) {
      context.handle(
        _optionAMeta,
        optionA.isAcceptableOrUnknown(data['option_a']!, _optionAMeta),
      );
    } else if (isInserting) {
      context.missing(_optionAMeta);
    }
    if (data.containsKey('option_b')) {
      context.handle(
        _optionBMeta,
        optionB.isAcceptableOrUnknown(data['option_b']!, _optionBMeta),
      );
    } else if (isInserting) {
      context.missing(_optionBMeta);
    }
    if (data.containsKey('option_c')) {
      context.handle(
        _optionCMeta,
        optionC.isAcceptableOrUnknown(data['option_c']!, _optionCMeta),
      );
    } else if (isInserting) {
      context.missing(_optionCMeta);
    }
    if (data.containsKey('option_d')) {
      context.handle(
        _optionDMeta,
        optionD.isAcceptableOrUnknown(data['option_d']!, _optionDMeta),
      );
    } else if (isInserting) {
      context.missing(_optionDMeta);
    }
    if (data.containsKey('correct_option')) {
      context.handle(
        _correctOptionMeta,
        correctOption.isAcceptableOrUnknown(
          data['correct_option']!,
          _correctOptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctOptionMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('tested_field')) {
      context.handle(
        _testedFieldMeta,
        testedField.isAcceptableOrUnknown(
          data['tested_field']!,
          _testedFieldMeta,
        ),
      );
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    }
    if (data.containsKey('last_attempted_at')) {
      context.handle(
        _lastAttemptedAtMeta,
        lastAttemptedAt.isAcceptableOrUnknown(
          data['last_attempted_at']!,
          _lastAttemptedAtMeta,
        ),
      );
    }
    if (data.containsKey('sr_interval')) {
      context.handle(
        _srIntervalMeta,
        srInterval.isAcceptableOrUnknown(data['sr_interval']!, _srIntervalMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizQuestionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizQuestionEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      stem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stem'],
      )!,
      optionA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_a'],
      )!,
      optionB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_b'],
      )!,
      optionC: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_c'],
      )!,
      optionD: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_d'],
      )!,
      correctOption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_option'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      testedField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tested_field'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      lastAttemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempted_at'],
      ),
      srInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sr_interval'],
      ),
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      ),
    );
  }

  @override
  $QuizTableTable createAlias(String alias) {
    return $QuizTableTable(attachedDatabase, alias);
  }
}

class QuizQuestionEntity extends DataClass
    implements Insertable<QuizQuestionEntity> {
  final int id;
  final String remoteId;
  final String articleId;
  final String stem;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String explanation;
  final String category;
  final String difficulty;
  final String testedField;
  final int wrongCount;
  final DateTime? lastAttemptedAt;
  final int? srInterval;
  final int? repetitions;
  final DateTime? nextDueAt;
  const QuizQuestionEntity({
    required this.id,
    required this.remoteId,
    required this.articleId,
    required this.stem,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.testedField,
    required this.wrongCount,
    this.lastAttemptedAt,
    this.srInterval,
    this.repetitions,
    this.nextDueAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['remote_id'] = Variable<String>(remoteId);
    map['article_id'] = Variable<String>(articleId);
    map['stem'] = Variable<String>(stem);
    map['option_a'] = Variable<String>(optionA);
    map['option_b'] = Variable<String>(optionB);
    map['option_c'] = Variable<String>(optionC);
    map['option_d'] = Variable<String>(optionD);
    map['correct_option'] = Variable<String>(correctOption);
    map['explanation'] = Variable<String>(explanation);
    map['category'] = Variable<String>(category);
    map['difficulty'] = Variable<String>(difficulty);
    map['tested_field'] = Variable<String>(testedField);
    map['wrong_count'] = Variable<int>(wrongCount);
    if (!nullToAbsent || lastAttemptedAt != null) {
      map['last_attempted_at'] = Variable<DateTime>(lastAttemptedAt);
    }
    if (!nullToAbsent || srInterval != null) {
      map['sr_interval'] = Variable<int>(srInterval);
    }
    if (!nullToAbsent || repetitions != null) {
      map['repetitions'] = Variable<int>(repetitions);
    }
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt);
    }
    return map;
  }

  QuizTableCompanion toCompanion(bool nullToAbsent) {
    return QuizTableCompanion(
      id: Value(id),
      remoteId: Value(remoteId),
      articleId: Value(articleId),
      stem: Value(stem),
      optionA: Value(optionA),
      optionB: Value(optionB),
      optionC: Value(optionC),
      optionD: Value(optionD),
      correctOption: Value(correctOption),
      explanation: Value(explanation),
      category: Value(category),
      difficulty: Value(difficulty),
      testedField: Value(testedField),
      wrongCount: Value(wrongCount),
      lastAttemptedAt: lastAttemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptedAt),
      srInterval: srInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(srInterval),
      repetitions: repetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(repetitions),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
    );
  }

  factory QuizQuestionEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizQuestionEntity(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      stem: serializer.fromJson<String>(json['stem']),
      optionA: serializer.fromJson<String>(json['optionA']),
      optionB: serializer.fromJson<String>(json['optionB']),
      optionC: serializer.fromJson<String>(json['optionC']),
      optionD: serializer.fromJson<String>(json['optionD']),
      correctOption: serializer.fromJson<String>(json['correctOption']),
      explanation: serializer.fromJson<String>(json['explanation']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      testedField: serializer.fromJson<String>(json['testedField']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      lastAttemptedAt: serializer.fromJson<DateTime?>(json['lastAttemptedAt']),
      srInterval: serializer.fromJson<int?>(json['srInterval']),
      repetitions: serializer.fromJson<int?>(json['repetitions']),
      nextDueAt: serializer.fromJson<DateTime?>(json['nextDueAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String>(remoteId),
      'articleId': serializer.toJson<String>(articleId),
      'stem': serializer.toJson<String>(stem),
      'optionA': serializer.toJson<String>(optionA),
      'optionB': serializer.toJson<String>(optionB),
      'optionC': serializer.toJson<String>(optionC),
      'optionD': serializer.toJson<String>(optionD),
      'correctOption': serializer.toJson<String>(correctOption),
      'explanation': serializer.toJson<String>(explanation),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<String>(difficulty),
      'testedField': serializer.toJson<String>(testedField),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'lastAttemptedAt': serializer.toJson<DateTime?>(lastAttemptedAt),
      'srInterval': serializer.toJson<int?>(srInterval),
      'repetitions': serializer.toJson<int?>(repetitions),
      'nextDueAt': serializer.toJson<DateTime?>(nextDueAt),
    };
  }

  QuizQuestionEntity copyWith({
    int? id,
    String? remoteId,
    String? articleId,
    String? stem,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctOption,
    String? explanation,
    String? category,
    String? difficulty,
    String? testedField,
    int? wrongCount,
    Value<DateTime?> lastAttemptedAt = const Value.absent(),
    Value<int?> srInterval = const Value.absent(),
    Value<int?> repetitions = const Value.absent(),
    Value<DateTime?> nextDueAt = const Value.absent(),
  }) => QuizQuestionEntity(
    id: id ?? this.id,
    remoteId: remoteId ?? this.remoteId,
    articleId: articleId ?? this.articleId,
    stem: stem ?? this.stem,
    optionA: optionA ?? this.optionA,
    optionB: optionB ?? this.optionB,
    optionC: optionC ?? this.optionC,
    optionD: optionD ?? this.optionD,
    correctOption: correctOption ?? this.correctOption,
    explanation: explanation ?? this.explanation,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    testedField: testedField ?? this.testedField,
    wrongCount: wrongCount ?? this.wrongCount,
    lastAttemptedAt: lastAttemptedAt.present
        ? lastAttemptedAt.value
        : this.lastAttemptedAt,
    srInterval: srInterval.present ? srInterval.value : this.srInterval,
    repetitions: repetitions.present ? repetitions.value : this.repetitions,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
  );
  QuizQuestionEntity copyWithCompanion(QuizTableCompanion data) {
    return QuizQuestionEntity(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      stem: data.stem.present ? data.stem.value : this.stem,
      optionA: data.optionA.present ? data.optionA.value : this.optionA,
      optionB: data.optionB.present ? data.optionB.value : this.optionB,
      optionC: data.optionC.present ? data.optionC.value : this.optionC,
      optionD: data.optionD.present ? data.optionD.value : this.optionD,
      correctOption: data.correctOption.present
          ? data.correctOption.value
          : this.correctOption,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      testedField: data.testedField.present
          ? data.testedField.value
          : this.testedField,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      lastAttemptedAt: data.lastAttemptedAt.present
          ? data.lastAttemptedAt.value
          : this.lastAttemptedAt,
      srInterval: data.srInterval.present
          ? data.srInterval.value
          : this.srInterval,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionEntity(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('articleId: $articleId, ')
          ..write('stem: $stem, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctOption: $correctOption, ')
          ..write('explanation: $explanation, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('testedField: $testedField, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('srInterval: $srInterval, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextDueAt: $nextDueAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    articleId,
    stem,
    optionA,
    optionB,
    optionC,
    optionD,
    correctOption,
    explanation,
    category,
    difficulty,
    testedField,
    wrongCount,
    lastAttemptedAt,
    srInterval,
    repetitions,
    nextDueAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizQuestionEntity &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.articleId == this.articleId &&
          other.stem == this.stem &&
          other.optionA == this.optionA &&
          other.optionB == this.optionB &&
          other.optionC == this.optionC &&
          other.optionD == this.optionD &&
          other.correctOption == this.correctOption &&
          other.explanation == this.explanation &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.testedField == this.testedField &&
          other.wrongCount == this.wrongCount &&
          other.lastAttemptedAt == this.lastAttemptedAt &&
          other.srInterval == this.srInterval &&
          other.repetitions == this.repetitions &&
          other.nextDueAt == this.nextDueAt);
}

class QuizTableCompanion extends UpdateCompanion<QuizQuestionEntity> {
  final Value<int> id;
  final Value<String> remoteId;
  final Value<String> articleId;
  final Value<String> stem;
  final Value<String> optionA;
  final Value<String> optionB;
  final Value<String> optionC;
  final Value<String> optionD;
  final Value<String> correctOption;
  final Value<String> explanation;
  final Value<String> category;
  final Value<String> difficulty;
  final Value<String> testedField;
  final Value<int> wrongCount;
  final Value<DateTime?> lastAttemptedAt;
  final Value<int?> srInterval;
  final Value<int?> repetitions;
  final Value<DateTime?> nextDueAt;
  const QuizTableCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.stem = const Value.absent(),
    this.optionA = const Value.absent(),
    this.optionB = const Value.absent(),
    this.optionC = const Value.absent(),
    this.optionD = const Value.absent(),
    this.correctOption = const Value.absent(),
    this.explanation = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.testedField = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.lastAttemptedAt = const Value.absent(),
    this.srInterval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextDueAt = const Value.absent(),
  });
  QuizTableCompanion.insert({
    this.id = const Value.absent(),
    required String remoteId,
    required String articleId,
    required String stem,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctOption,
    required String explanation,
    required String category,
    this.difficulty = const Value.absent(),
    this.testedField = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.lastAttemptedAt = const Value.absent(),
    this.srInterval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextDueAt = const Value.absent(),
  }) : remoteId = Value(remoteId),
       articleId = Value(articleId),
       stem = Value(stem),
       optionA = Value(optionA),
       optionB = Value(optionB),
       optionC = Value(optionC),
       optionD = Value(optionD),
       correctOption = Value(correctOption),
       explanation = Value(explanation),
       category = Value(category);
  static Insertable<QuizQuestionEntity> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? articleId,
    Expression<String>? stem,
    Expression<String>? optionA,
    Expression<String>? optionB,
    Expression<String>? optionC,
    Expression<String>? optionD,
    Expression<String>? correctOption,
    Expression<String>? explanation,
    Expression<String>? category,
    Expression<String>? difficulty,
    Expression<String>? testedField,
    Expression<int>? wrongCount,
    Expression<DateTime>? lastAttemptedAt,
    Expression<int>? srInterval,
    Expression<int>? repetitions,
    Expression<DateTime>? nextDueAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (articleId != null) 'article_id': articleId,
      if (stem != null) 'stem': stem,
      if (optionA != null) 'option_a': optionA,
      if (optionB != null) 'option_b': optionB,
      if (optionC != null) 'option_c': optionC,
      if (optionD != null) 'option_d': optionD,
      if (correctOption != null) 'correct_option': correctOption,
      if (explanation != null) 'explanation': explanation,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (testedField != null) 'tested_field': testedField,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (lastAttemptedAt != null) 'last_attempted_at': lastAttemptedAt,
      if (srInterval != null) 'sr_interval': srInterval,
      if (repetitions != null) 'repetitions': repetitions,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
    });
  }

  QuizTableCompanion copyWith({
    Value<int>? id,
    Value<String>? remoteId,
    Value<String>? articleId,
    Value<String>? stem,
    Value<String>? optionA,
    Value<String>? optionB,
    Value<String>? optionC,
    Value<String>? optionD,
    Value<String>? correctOption,
    Value<String>? explanation,
    Value<String>? category,
    Value<String>? difficulty,
    Value<String>? testedField,
    Value<int>? wrongCount,
    Value<DateTime?>? lastAttemptedAt,
    Value<int?>? srInterval,
    Value<int?>? repetitions,
    Value<DateTime?>? nextDueAt,
  }) {
    return QuizTableCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      articleId: articleId ?? this.articleId,
      stem: stem ?? this.stem,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctOption: correctOption ?? this.correctOption,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      testedField: testedField ?? this.testedField,
      wrongCount: wrongCount ?? this.wrongCount,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      srInterval: srInterval ?? this.srInterval,
      repetitions: repetitions ?? this.repetitions,
      nextDueAt: nextDueAt ?? this.nextDueAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (stem.present) {
      map['stem'] = Variable<String>(stem.value);
    }
    if (optionA.present) {
      map['option_a'] = Variable<String>(optionA.value);
    }
    if (optionB.present) {
      map['option_b'] = Variable<String>(optionB.value);
    }
    if (optionC.present) {
      map['option_c'] = Variable<String>(optionC.value);
    }
    if (optionD.present) {
      map['option_d'] = Variable<String>(optionD.value);
    }
    if (correctOption.present) {
      map['correct_option'] = Variable<String>(correctOption.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (testedField.present) {
      map['tested_field'] = Variable<String>(testedField.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (lastAttemptedAt.present) {
      map['last_attempted_at'] = Variable<DateTime>(lastAttemptedAt.value);
    }
    if (srInterval.present) {
      map['sr_interval'] = Variable<int>(srInterval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizTableCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('articleId: $articleId, ')
          ..write('stem: $stem, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctOption: $correctOption, ')
          ..write('explanation: $explanation, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('testedField: $testedField, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('srInterval: $srInterval, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextDueAt: $nextDueAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $QuizQuestionsTable quizQuestions = $QuizQuestionsTable(this);
  late final $QuizTableTable quizTable = $QuizTableTable(this);
  late final Index idxQuizTableCategory = Index(
    'idx_quiz_table_category',
    'CREATE INDEX idx_quiz_table_category ON quiz_table (category)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    articles,
    bookmarks,
    studySessions,
    quizQuestions,
    quizTable,
    idxQuizTableCategory,
  ];
}

typedef $$ArticlesTableCreateCompanionBuilder =
    ArticlesCompanion Function({
      required String id,
      required String title,
      Value<String?> category,
      Value<String?> content,
      Value<String?> imageUrl,
      Value<String?> videoUrl,
      Value<String?> subcategory,
      Value<bool> isHighYield,
      Value<int> rowid,
    });
typedef $$ArticlesTableUpdateCompanionBuilder =
    ArticlesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> category,
      Value<String?> content,
      Value<String?> imageUrl,
      Value<String?> videoUrl,
      Value<String?> subcategory,
      Value<bool> isHighYield,
      Value<int> rowid,
    });

final class $$ArticlesTableReferences
    extends BaseReferences<_$AppDatabase, $ArticlesTable, ArticleLocal> {
  $$ArticlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: $_aliasNameGenerator(db.articles.id, db.bookmarks.articleId),
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHighYield => $composableBuilder(
    column: $table.isHighYield,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoUrl => $composableBuilder(
    column: $table.videoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHighYield => $composableBuilder(
    column: $table.isHighYield,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHighYield => $composableBuilder(
    column: $table.isHighYield,
    builder: (column) => column,
  );

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          ArticleLocal,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (ArticleLocal, $$ArticlesTableReferences),
          ArticleLocal,
          PrefetchHooks Function({bool bookmarksRefs})
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<bool> isHighYield = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                title: title,
                category: category,
                content: content,
                imageUrl: imageUrl,
                videoUrl: videoUrl,
                subcategory: subcategory,
                isHighYield: isHighYield,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> category = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> videoUrl = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<bool> isHighYield = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                title: title,
                category: category,
                content: content,
                imageUrl: imageUrl,
                videoUrl: videoUrl,
                subcategory: subcategory,
                isHighYield: isHighYield,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookmarksRefs) db.bookmarks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarksRefs)
                    await $_getPrefetchedData<
                      ArticleLocal,
                      $ArticlesTable,
                      Bookmark
                    >(
                      currentTable: table,
                      referencedTable: $$ArticlesTableReferences
                          ._bookmarksRefsTable(db),
                      managerFromTypedResult: (p0) => $$ArticlesTableReferences(
                        db,
                        table,
                        p0,
                      ).bookmarksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.articleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      ArticleLocal,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (ArticleLocal, $$ArticlesTableReferences),
      ArticleLocal,
      PrefetchHooks Function({bool bookmarksRefs})
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({Value<int> id, required String articleId});
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({Value<int> id, Value<String> articleId});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias(
        $_aliasNameGenerator(db.bookmarks.articleId, db.articles.id),
      );

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool articleId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> articleId = const Value.absent(),
              }) => BookmarksCompanion(id: id, articleId: articleId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String articleId,
              }) => BookmarksCompanion.insert(id: id, articleId: articleId),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable: $$BookmarksTableReferences
                                    ._articleIdTable(db),
                                referencedColumn: $$BookmarksTableReferences
                                    ._articleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      required DateTime date,
      Value<int> articlesViewedCount,
      Value<int> rowid,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<DateTime> date,
      Value<int> articlesViewedCount,
      Value<int> rowid,
    });

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get articlesViewedCount => $composableBuilder(
    column: $table.articlesViewedCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get articlesViewedCount => $composableBuilder(
    column: $table.articlesViewedCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get articlesViewedCount => $composableBuilder(
    column: $table.articlesViewedCount,
    builder: (column) => column,
  );
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (
            StudySession,
            BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
          ),
          StudySession,
          PrefetchHooks Function()
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<int> articlesViewedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion(
                date: date,
                articlesViewedCount: articlesViewedCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                Value<int> articlesViewedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                date: date,
                articlesViewedCount: articlesViewedCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (
        StudySession,
        BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
      ),
      StudySession,
      PrefetchHooks Function()
    >;
typedef $$QuizQuestionsTableCreateCompanionBuilder =
    QuizQuestionsCompanion Function({
      Value<int> id,
      Value<String?> articleId,
      required String stem,
      required String optionA,
      required String optionB,
      required String optionC,
      required String optionD,
      required String correctOption,
      Value<String?> explanation,
      Value<String?> category,
      Value<String?> difficulty,
    });
typedef $$QuizQuestionsTableUpdateCompanionBuilder =
    QuizQuestionsCompanion Function({
      Value<int> id,
      Value<String?> articleId,
      Value<String> stem,
      Value<String> optionA,
      Value<String> optionB,
      Value<String> optionC,
      Value<String> optionD,
      Value<String> correctOption,
      Value<String?> explanation,
      Value<String?> category,
      Value<String?> difficulty,
    });

class $$QuizQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuizQuestionsTable> {
  $$QuizQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionA => $composableBuilder(
    column: $table.optionA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionB => $composableBuilder(
    column: $table.optionB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionC => $composableBuilder(
    column: $table.optionC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionD => $composableBuilder(
    column: $table.optionD,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctOption => $composableBuilder(
    column: $table.correctOption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuizQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizQuestionsTable> {
  $$QuizQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionA => $composableBuilder(
    column: $table.optionA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionB => $composableBuilder(
    column: $table.optionB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionC => $composableBuilder(
    column: $table.optionC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionD => $composableBuilder(
    column: $table.optionD,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctOption => $composableBuilder(
    column: $table.correctOption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizQuestionsTable> {
  $$QuizQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get stem =>
      $composableBuilder(column: $table.stem, builder: (column) => column);

  GeneratedColumn<String> get optionA =>
      $composableBuilder(column: $table.optionA, builder: (column) => column);

  GeneratedColumn<String> get optionB =>
      $composableBuilder(column: $table.optionB, builder: (column) => column);

  GeneratedColumn<String> get optionC =>
      $composableBuilder(column: $table.optionC, builder: (column) => column);

  GeneratedColumn<String> get optionD =>
      $composableBuilder(column: $table.optionD, builder: (column) => column);

  GeneratedColumn<String> get correctOption => $composableBuilder(
    column: $table.correctOption,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );
}

class $$QuizQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizQuestionsTable,
          QuizQuestionLocal,
          $$QuizQuestionsTableFilterComposer,
          $$QuizQuestionsTableOrderingComposer,
          $$QuizQuestionsTableAnnotationComposer,
          $$QuizQuestionsTableCreateCompanionBuilder,
          $$QuizQuestionsTableUpdateCompanionBuilder,
          (
            QuizQuestionLocal,
            BaseReferences<
              _$AppDatabase,
              $QuizQuestionsTable,
              QuizQuestionLocal
            >,
          ),
          QuizQuestionLocal,
          PrefetchHooks Function()
        > {
  $$QuizQuestionsTableTableManager(_$AppDatabase db, $QuizQuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> articleId = const Value.absent(),
                Value<String> stem = const Value.absent(),
                Value<String> optionA = const Value.absent(),
                Value<String> optionB = const Value.absent(),
                Value<String> optionC = const Value.absent(),
                Value<String> optionD = const Value.absent(),
                Value<String> correctOption = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
              }) => QuizQuestionsCompanion(
                id: id,
                articleId: articleId,
                stem: stem,
                optionA: optionA,
                optionB: optionB,
                optionC: optionC,
                optionD: optionD,
                correctOption: correctOption,
                explanation: explanation,
                category: category,
                difficulty: difficulty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> articleId = const Value.absent(),
                required String stem,
                required String optionA,
                required String optionB,
                required String optionC,
                required String optionD,
                required String correctOption,
                Value<String?> explanation = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
              }) => QuizQuestionsCompanion.insert(
                id: id,
                articleId: articleId,
                stem: stem,
                optionA: optionA,
                optionB: optionB,
                optionC: optionC,
                optionD: optionD,
                correctOption: correctOption,
                explanation: explanation,
                category: category,
                difficulty: difficulty,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuizQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizQuestionsTable,
      QuizQuestionLocal,
      $$QuizQuestionsTableFilterComposer,
      $$QuizQuestionsTableOrderingComposer,
      $$QuizQuestionsTableAnnotationComposer,
      $$QuizQuestionsTableCreateCompanionBuilder,
      $$QuizQuestionsTableUpdateCompanionBuilder,
      (
        QuizQuestionLocal,
        BaseReferences<_$AppDatabase, $QuizQuestionsTable, QuizQuestionLocal>,
      ),
      QuizQuestionLocal,
      PrefetchHooks Function()
    >;
typedef $$QuizTableTableCreateCompanionBuilder =
    QuizTableCompanion Function({
      Value<int> id,
      required String remoteId,
      required String articleId,
      required String stem,
      required String optionA,
      required String optionB,
      required String optionC,
      required String optionD,
      required String correctOption,
      required String explanation,
      required String category,
      Value<String> difficulty,
      Value<String> testedField,
      Value<int> wrongCount,
      Value<DateTime?> lastAttemptedAt,
      Value<int?> srInterval,
      Value<int?> repetitions,
      Value<DateTime?> nextDueAt,
    });
typedef $$QuizTableTableUpdateCompanionBuilder =
    QuizTableCompanion Function({
      Value<int> id,
      Value<String> remoteId,
      Value<String> articleId,
      Value<String> stem,
      Value<String> optionA,
      Value<String> optionB,
      Value<String> optionC,
      Value<String> optionD,
      Value<String> correctOption,
      Value<String> explanation,
      Value<String> category,
      Value<String> difficulty,
      Value<String> testedField,
      Value<int> wrongCount,
      Value<DateTime?> lastAttemptedAt,
      Value<int?> srInterval,
      Value<int?> repetitions,
      Value<DateTime?> nextDueAt,
    });

class $$QuizTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuizTableTable> {
  $$QuizTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionA => $composableBuilder(
    column: $table.optionA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionB => $composableBuilder(
    column: $table.optionB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionC => $composableBuilder(
    column: $table.optionC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionD => $composableBuilder(
    column: $table.optionD,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctOption => $composableBuilder(
    column: $table.correctOption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testedField => $composableBuilder(
    column: $table.testedField,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptedAt => $composableBuilder(
    column: $table.lastAttemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get srInterval => $composableBuilder(
    column: $table.srInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuizTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizTableTable> {
  $$QuizTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionA => $composableBuilder(
    column: $table.optionA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionB => $composableBuilder(
    column: $table.optionB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionC => $composableBuilder(
    column: $table.optionC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionD => $composableBuilder(
    column: $table.optionD,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctOption => $composableBuilder(
    column: $table.correctOption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testedField => $composableBuilder(
    column: $table.testedField,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptedAt => $composableBuilder(
    column: $table.lastAttemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get srInterval => $composableBuilder(
    column: $table.srInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizTableTable> {
  $$QuizTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get stem =>
      $composableBuilder(column: $table.stem, builder: (column) => column);

  GeneratedColumn<String> get optionA =>
      $composableBuilder(column: $table.optionA, builder: (column) => column);

  GeneratedColumn<String> get optionB =>
      $composableBuilder(column: $table.optionB, builder: (column) => column);

  GeneratedColumn<String> get optionC =>
      $composableBuilder(column: $table.optionC, builder: (column) => column);

  GeneratedColumn<String> get optionD =>
      $composableBuilder(column: $table.optionD, builder: (column) => column);

  GeneratedColumn<String> get correctOption => $composableBuilder(
    column: $table.correctOption,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get testedField => $composableBuilder(
    column: $table.testedField,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptedAt => $composableBuilder(
    column: $table.lastAttemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get srInterval => $composableBuilder(
    column: $table.srInterval,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);
}

class $$QuizTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizTableTable,
          QuizQuestionEntity,
          $$QuizTableTableFilterComposer,
          $$QuizTableTableOrderingComposer,
          $$QuizTableTableAnnotationComposer,
          $$QuizTableTableCreateCompanionBuilder,
          $$QuizTableTableUpdateCompanionBuilder,
          (
            QuizQuestionEntity,
            BaseReferences<_$AppDatabase, $QuizTableTable, QuizQuestionEntity>,
          ),
          QuizQuestionEntity,
          PrefetchHooks Function()
        > {
  $$QuizTableTableTableManager(_$AppDatabase db, $QuizTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> remoteId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> stem = const Value.absent(),
                Value<String> optionA = const Value.absent(),
                Value<String> optionB = const Value.absent(),
                Value<String> optionC = const Value.absent(),
                Value<String> optionD = const Value.absent(),
                Value<String> correctOption = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<String> testedField = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<DateTime?> lastAttemptedAt = const Value.absent(),
                Value<int?> srInterval = const Value.absent(),
                Value<int?> repetitions = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
              }) => QuizTableCompanion(
                id: id,
                remoteId: remoteId,
                articleId: articleId,
                stem: stem,
                optionA: optionA,
                optionB: optionB,
                optionC: optionC,
                optionD: optionD,
                correctOption: correctOption,
                explanation: explanation,
                category: category,
                difficulty: difficulty,
                testedField: testedField,
                wrongCount: wrongCount,
                lastAttemptedAt: lastAttemptedAt,
                srInterval: srInterval,
                repetitions: repetitions,
                nextDueAt: nextDueAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String remoteId,
                required String articleId,
                required String stem,
                required String optionA,
                required String optionB,
                required String optionC,
                required String optionD,
                required String correctOption,
                required String explanation,
                required String category,
                Value<String> difficulty = const Value.absent(),
                Value<String> testedField = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<DateTime?> lastAttemptedAt = const Value.absent(),
                Value<int?> srInterval = const Value.absent(),
                Value<int?> repetitions = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
              }) => QuizTableCompanion.insert(
                id: id,
                remoteId: remoteId,
                articleId: articleId,
                stem: stem,
                optionA: optionA,
                optionB: optionB,
                optionC: optionC,
                optionD: optionD,
                correctOption: correctOption,
                explanation: explanation,
                category: category,
                difficulty: difficulty,
                testedField: testedField,
                wrongCount: wrongCount,
                lastAttemptedAt: lastAttemptedAt,
                srInterval: srInterval,
                repetitions: repetitions,
                nextDueAt: nextDueAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuizTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizTableTable,
      QuizQuestionEntity,
      $$QuizTableTableFilterComposer,
      $$QuizTableTableOrderingComposer,
      $$QuizTableTableAnnotationComposer,
      $$QuizTableTableCreateCompanionBuilder,
      $$QuizTableTableUpdateCompanionBuilder,
      (
        QuizQuestionEntity,
        BaseReferences<_$AppDatabase, $QuizTableTable, QuizQuestionEntity>,
      ),
      QuizQuestionEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$QuizQuestionsTableTableManager get quizQuestions =>
      $$QuizQuestionsTableTableManager(_db, _db.quizQuestions);
  $$QuizTableTableTableManager get quizTable =>
      $$QuizTableTableTableManager(_db, _db.quizTable);
}
