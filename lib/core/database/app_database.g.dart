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
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _lastQualityMeta = const VerificationMeta(
    'lastQuality',
  );
  @override
  late final GeneratedColumn<int> lastQuality = GeneratedColumn<int>(
    'last_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    easeFactor,
    lastQuality,
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
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('last_quality')) {
      context.handle(
        _lastQualityMeta,
        lastQuality.isAcceptableOrUnknown(
          data['last_quality']!,
          _lastQualityMeta,
        ),
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
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      lastQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_quality'],
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
  final double easeFactor;
  final int? lastQuality;
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
    required this.easeFactor,
    this.lastQuality,
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
    map['ease_factor'] = Variable<double>(easeFactor);
    if (!nullToAbsent || lastQuality != null) {
      map['last_quality'] = Variable<int>(lastQuality);
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
      easeFactor: Value(easeFactor),
      lastQuality: lastQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(lastQuality),
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
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      lastQuality: serializer.fromJson<int?>(json['lastQuality']),
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
      'easeFactor': serializer.toJson<double>(easeFactor),
      'lastQuality': serializer.toJson<int?>(lastQuality),
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
    double? easeFactor,
    Value<int?> lastQuality = const Value.absent(),
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
    easeFactor: easeFactor ?? this.easeFactor,
    lastQuality: lastQuality.present ? lastQuality.value : this.lastQuality,
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
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      lastQuality: data.lastQuality.present
          ? data.lastQuality.value
          : this.lastQuality,
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
          ..write('nextDueAt: $nextDueAt, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('lastQuality: $lastQuality')
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
    easeFactor,
    lastQuality,
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
          other.nextDueAt == this.nextDueAt &&
          other.easeFactor == this.easeFactor &&
          other.lastQuality == this.lastQuality);
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
  final Value<double> easeFactor;
  final Value<int?> lastQuality;
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
    this.easeFactor = const Value.absent(),
    this.lastQuality = const Value.absent(),
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
    this.easeFactor = const Value.absent(),
    this.lastQuality = const Value.absent(),
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
    Expression<double>? easeFactor,
    Expression<int>? lastQuality,
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
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (lastQuality != null) 'last_quality': lastQuality,
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
    Value<double>? easeFactor,
    Value<int?>? lastQuality,
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
      easeFactor: easeFactor ?? this.easeFactor,
      lastQuality: lastQuality ?? this.lastQuality,
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
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (lastQuality.present) {
      map['last_quality'] = Variable<int>(lastQuality.value);
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
          ..write('nextDueAt: $nextDueAt, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('lastQuality: $lastQuality')
          ..write(')'))
        .toString();
  }
}

class $ClinicalCasesTable extends ClinicalCases
    with TableInfo<$ClinicalCasesTable, ClinicalCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalCasesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
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
  static const VerificationMeta _estimatedTimeMinutesMeta =
      const VerificationMeta('estimatedTimeMinutes');
  @override
  late final GeneratedColumn<int> estimatedTimeMinutes = GeneratedColumn<int>(
    'estimated_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _learningObjectivesMeta =
      const VerificationMeta('learningObjectives');
  @override
  late final GeneratedColumn<String> learningObjectives =
      GeneratedColumn<String>(
        'learning_objectives',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    specialty,
    difficulty,
    estimatedTimeMinutes,
    learningObjectives,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClinicalCase> instance, {
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
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    } else if (isInserting) {
      context.missing(_specialtyMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('estimated_time_minutes')) {
      context.handle(
        _estimatedTimeMinutesMeta,
        estimatedTimeMinutes.isAcceptableOrUnknown(
          data['estimated_time_minutes']!,
          _estimatedTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('learning_objectives')) {
      context.handle(
        _learningObjectivesMeta,
        learningObjectives.isAcceptableOrUnknown(
          data['learning_objectives']!,
          _learningObjectivesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalCase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      )!,
      estimatedTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_time_minutes'],
      )!,
      learningObjectives: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_objectives'],
      ),
    );
  }

  @override
  $ClinicalCasesTable createAlias(String alias) {
    return $ClinicalCasesTable(attachedDatabase, alias);
  }
}

class ClinicalCase extends DataClass implements Insertable<ClinicalCase> {
  final String id;
  final String title;
  final String specialty;
  final String difficulty;
  final int estimatedTimeMinutes;
  final String? learningObjectives;
  const ClinicalCase({
    required this.id,
    required this.title,
    required this.specialty,
    required this.difficulty,
    required this.estimatedTimeMinutes,
    this.learningObjectives,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['specialty'] = Variable<String>(specialty);
    map['difficulty'] = Variable<String>(difficulty);
    map['estimated_time_minutes'] = Variable<int>(estimatedTimeMinutes);
    if (!nullToAbsent || learningObjectives != null) {
      map['learning_objectives'] = Variable<String>(learningObjectives);
    }
    return map;
  }

  ClinicalCasesCompanion toCompanion(bool nullToAbsent) {
    return ClinicalCasesCompanion(
      id: Value(id),
      title: Value(title),
      specialty: Value(specialty),
      difficulty: Value(difficulty),
      estimatedTimeMinutes: Value(estimatedTimeMinutes),
      learningObjectives: learningObjectives == null && nullToAbsent
          ? const Value.absent()
          : Value(learningObjectives),
    );
  }

  factory ClinicalCase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalCase(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      specialty: serializer.fromJson<String>(json['specialty']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      estimatedTimeMinutes: serializer.fromJson<int>(
        json['estimatedTimeMinutes'],
      ),
      learningObjectives: serializer.fromJson<String?>(
        json['learningObjectives'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'specialty': serializer.toJson<String>(specialty),
      'difficulty': serializer.toJson<String>(difficulty),
      'estimatedTimeMinutes': serializer.toJson<int>(estimatedTimeMinutes),
      'learningObjectives': serializer.toJson<String?>(learningObjectives),
    };
  }

  ClinicalCase copyWith({
    String? id,
    String? title,
    String? specialty,
    String? difficulty,
    int? estimatedTimeMinutes,
    Value<String?> learningObjectives = const Value.absent(),
  }) => ClinicalCase(
    id: id ?? this.id,
    title: title ?? this.title,
    specialty: specialty ?? this.specialty,
    difficulty: difficulty ?? this.difficulty,
    estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
    learningObjectives: learningObjectives.present
        ? learningObjectives.value
        : this.learningObjectives,
  );
  ClinicalCase copyWithCompanion(ClinicalCasesCompanion data) {
    return ClinicalCase(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      estimatedTimeMinutes: data.estimatedTimeMinutes.present
          ? data.estimatedTimeMinutes.value
          : this.estimatedTimeMinutes,
      learningObjectives: data.learningObjectives.present
          ? data.learningObjectives.value
          : this.learningObjectives,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalCase(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('specialty: $specialty, ')
          ..write('difficulty: $difficulty, ')
          ..write('estimatedTimeMinutes: $estimatedTimeMinutes, ')
          ..write('learningObjectives: $learningObjectives')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    specialty,
    difficulty,
    estimatedTimeMinutes,
    learningObjectives,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalCase &&
          other.id == this.id &&
          other.title == this.title &&
          other.specialty == this.specialty &&
          other.difficulty == this.difficulty &&
          other.estimatedTimeMinutes == this.estimatedTimeMinutes &&
          other.learningObjectives == this.learningObjectives);
}

class ClinicalCasesCompanion extends UpdateCompanion<ClinicalCase> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> specialty;
  final Value<String> difficulty;
  final Value<int> estimatedTimeMinutes;
  final Value<String?> learningObjectives;
  final Value<int> rowid;
  const ClinicalCasesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.specialty = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.estimatedTimeMinutes = const Value.absent(),
    this.learningObjectives = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalCasesCompanion.insert({
    required String id,
    required String title,
    required String specialty,
    this.difficulty = const Value.absent(),
    this.estimatedTimeMinutes = const Value.absent(),
    this.learningObjectives = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       specialty = Value(specialty);
  static Insertable<ClinicalCase> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? specialty,
    Expression<String>? difficulty,
    Expression<int>? estimatedTimeMinutes,
    Expression<String>? learningObjectives,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (specialty != null) 'specialty': specialty,
      if (difficulty != null) 'difficulty': difficulty,
      if (estimatedTimeMinutes != null)
        'estimated_time_minutes': estimatedTimeMinutes,
      if (learningObjectives != null) 'learning_objectives': learningObjectives,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalCasesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? specialty,
    Value<String>? difficulty,
    Value<int>? estimatedTimeMinutes,
    Value<String?>? learningObjectives,
    Value<int>? rowid,
  }) {
    return ClinicalCasesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      difficulty: difficulty ?? this.difficulty,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
      learningObjectives: learningObjectives ?? this.learningObjectives,
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
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (estimatedTimeMinutes.present) {
      map['estimated_time_minutes'] = Variable<int>(estimatedTimeMinutes.value);
    }
    if (learningObjectives.present) {
      map['learning_objectives'] = Variable<String>(learningObjectives.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalCasesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('specialty: $specialty, ')
          ..write('difficulty: $difficulty, ')
          ..write('estimatedTimeMinutes: $estimatedTimeMinutes, ')
          ..write('learningObjectives: $learningObjectives, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseStagesTable extends CaseStages
    with TableInfo<$CaseStagesTable, CaseStage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseStagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clinical_cases (id)',
    ),
  );
  static const VerificationMeta _stageNumberMeta = const VerificationMeta(
    'stageNumber',
  );
  @override
  late final GeneratedColumn<int> stageNumber = GeneratedColumn<int>(
    'stage_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageTypeMeta = const VerificationMeta(
    'stageType',
  );
  @override
  late final GeneratedColumn<String> stageType = GeneratedColumn<String>(
    'stage_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('presentation'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    caseId,
    stageNumber,
    stageType,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_stages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaseStage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('stage_number')) {
      context.handle(
        _stageNumberMeta,
        stageNumber.isAcceptableOrUnknown(
          data['stage_number']!,
          _stageNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stageNumberMeta);
    }
    if (data.containsKey('stage_type')) {
      context.handle(
        _stageTypeMeta,
        stageType.isAcceptableOrUnknown(data['stage_type']!, _stageTypeMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseStage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseStage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      stageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage_number'],
      )!,
      stageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $CaseStagesTable createAlias(String alias) {
    return $CaseStagesTable(attachedDatabase, alias);
  }
}

class CaseStage extends DataClass implements Insertable<CaseStage> {
  final int id;
  final String caseId;
  final int stageNumber;
  final String stageType;
  final String content;
  const CaseStage({
    required this.id,
    required this.caseId,
    required this.stageNumber,
    required this.stageType,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['case_id'] = Variable<String>(caseId);
    map['stage_number'] = Variable<int>(stageNumber);
    map['stage_type'] = Variable<String>(stageType);
    map['content'] = Variable<String>(content);
    return map;
  }

  CaseStagesCompanion toCompanion(bool nullToAbsent) {
    return CaseStagesCompanion(
      id: Value(id),
      caseId: Value(caseId),
      stageNumber: Value(stageNumber),
      stageType: Value(stageType),
      content: Value(content),
    );
  }

  factory CaseStage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseStage(
      id: serializer.fromJson<int>(json['id']),
      caseId: serializer.fromJson<String>(json['caseId']),
      stageNumber: serializer.fromJson<int>(json['stageNumber']),
      stageType: serializer.fromJson<String>(json['stageType']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'caseId': serializer.toJson<String>(caseId),
      'stageNumber': serializer.toJson<int>(stageNumber),
      'stageType': serializer.toJson<String>(stageType),
      'content': serializer.toJson<String>(content),
    };
  }

  CaseStage copyWith({
    int? id,
    String? caseId,
    int? stageNumber,
    String? stageType,
    String? content,
  }) => CaseStage(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    stageNumber: stageNumber ?? this.stageNumber,
    stageType: stageType ?? this.stageType,
    content: content ?? this.content,
  );
  CaseStage copyWithCompanion(CaseStagesCompanion data) {
    return CaseStage(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      stageNumber: data.stageNumber.present
          ? data.stageNumber.value
          : this.stageNumber,
      stageType: data.stageType.present ? data.stageType.value : this.stageType,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseStage(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('stageNumber: $stageNumber, ')
          ..write('stageType: $stageType, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, caseId, stageNumber, stageType, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseStage &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.stageNumber == this.stageNumber &&
          other.stageType == this.stageType &&
          other.content == this.content);
}

class CaseStagesCompanion extends UpdateCompanion<CaseStage> {
  final Value<int> id;
  final Value<String> caseId;
  final Value<int> stageNumber;
  final Value<String> stageType;
  final Value<String> content;
  const CaseStagesCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.stageNumber = const Value.absent(),
    this.stageType = const Value.absent(),
    this.content = const Value.absent(),
  });
  CaseStagesCompanion.insert({
    this.id = const Value.absent(),
    required String caseId,
    required int stageNumber,
    this.stageType = const Value.absent(),
    required String content,
  }) : caseId = Value(caseId),
       stageNumber = Value(stageNumber),
       content = Value(content);
  static Insertable<CaseStage> custom({
    Expression<int>? id,
    Expression<String>? caseId,
    Expression<int>? stageNumber,
    Expression<String>? stageType,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (stageNumber != null) 'stage_number': stageNumber,
      if (stageType != null) 'stage_type': stageType,
      if (content != null) 'content': content,
    });
  }

  CaseStagesCompanion copyWith({
    Value<int>? id,
    Value<String>? caseId,
    Value<int>? stageNumber,
    Value<String>? stageType,
    Value<String>? content,
  }) {
    return CaseStagesCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      stageNumber: stageNumber ?? this.stageNumber,
      stageType: stageType ?? this.stageType,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (stageNumber.present) {
      map['stage_number'] = Variable<int>(stageNumber.value);
    }
    if (stageType.present) {
      map['stage_type'] = Variable<String>(stageType.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseStagesCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('stageNumber: $stageNumber, ')
          ..write('stageType: $stageType, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

class $CaseOptionsTable extends CaseOptions
    with TableInfo<$CaseOptionsTable, CaseOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseOptionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<int> stageId = GeneratedColumn<int>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES case_stages (id)',
    ),
  );
  static const VerificationMeta _optionTextMeta = const VerificationMeta(
    'optionText',
  );
  @override
  late final GeneratedColumn<String> optionText = GeneratedColumn<String>(
    'option_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stageId,
    optionText,
    isCorrect,
    feedback,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaseOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('option_text')) {
      context.handle(
        _optionTextMeta,
        optionText.isAcceptableOrUnknown(data['option_text']!, _optionTextMeta),
      );
    } else if (isInserting) {
      context.missing(_optionTextMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    } else if (isInserting) {
      context.missing(_feedbackMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage_id'],
      )!,
      optionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_text'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      )!,
    );
  }

  @override
  $CaseOptionsTable createAlias(String alias) {
    return $CaseOptionsTable(attachedDatabase, alias);
  }
}

class CaseOption extends DataClass implements Insertable<CaseOption> {
  final int id;
  final int stageId;
  final String optionText;
  final bool isCorrect;
  final String feedback;
  const CaseOption({
    required this.id,
    required this.stageId,
    required this.optionText,
    required this.isCorrect,
    required this.feedback,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stage_id'] = Variable<int>(stageId);
    map['option_text'] = Variable<String>(optionText);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['feedback'] = Variable<String>(feedback);
    return map;
  }

  CaseOptionsCompanion toCompanion(bool nullToAbsent) {
    return CaseOptionsCompanion(
      id: Value(id),
      stageId: Value(stageId),
      optionText: Value(optionText),
      isCorrect: Value(isCorrect),
      feedback: Value(feedback),
    );
  }

  factory CaseOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseOption(
      id: serializer.fromJson<int>(json['id']),
      stageId: serializer.fromJson<int>(json['stageId']),
      optionText: serializer.fromJson<String>(json['optionText']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      feedback: serializer.fromJson<String>(json['feedback']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stageId': serializer.toJson<int>(stageId),
      'optionText': serializer.toJson<String>(optionText),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'feedback': serializer.toJson<String>(feedback),
    };
  }

  CaseOption copyWith({
    int? id,
    int? stageId,
    String? optionText,
    bool? isCorrect,
    String? feedback,
  }) => CaseOption(
    id: id ?? this.id,
    stageId: stageId ?? this.stageId,
    optionText: optionText ?? this.optionText,
    isCorrect: isCorrect ?? this.isCorrect,
    feedback: feedback ?? this.feedback,
  );
  CaseOption copyWithCompanion(CaseOptionsCompanion data) {
    return CaseOption(
      id: data.id.present ? data.id.value : this.id,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      optionText: data.optionText.present
          ? data.optionText.value
          : this.optionText,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseOption(')
          ..write('id: $id, ')
          ..write('stageId: $stageId, ')
          ..write('optionText: $optionText, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('feedback: $feedback')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, stageId, optionText, isCorrect, feedback);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseOption &&
          other.id == this.id &&
          other.stageId == this.stageId &&
          other.optionText == this.optionText &&
          other.isCorrect == this.isCorrect &&
          other.feedback == this.feedback);
}

class CaseOptionsCompanion extends UpdateCompanion<CaseOption> {
  final Value<int> id;
  final Value<int> stageId;
  final Value<String> optionText;
  final Value<bool> isCorrect;
  final Value<String> feedback;
  const CaseOptionsCompanion({
    this.id = const Value.absent(),
    this.stageId = const Value.absent(),
    this.optionText = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.feedback = const Value.absent(),
  });
  CaseOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int stageId,
    required String optionText,
    this.isCorrect = const Value.absent(),
    required String feedback,
  }) : stageId = Value(stageId),
       optionText = Value(optionText),
       feedback = Value(feedback);
  static Insertable<CaseOption> custom({
    Expression<int>? id,
    Expression<int>? stageId,
    Expression<String>? optionText,
    Expression<bool>? isCorrect,
    Expression<String>? feedback,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stageId != null) 'stage_id': stageId,
      if (optionText != null) 'option_text': optionText,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (feedback != null) 'feedback': feedback,
    });
  }

  CaseOptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? stageId,
    Value<String>? optionText,
    Value<bool>? isCorrect,
    Value<String>? feedback,
  }) {
    return CaseOptionsCompanion(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      optionText: optionText ?? this.optionText,
      isCorrect: isCorrect ?? this.isCorrect,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<int>(stageId.value);
    }
    if (optionText.present) {
      map['option_text'] = Variable<String>(optionText.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseOptionsCompanion(')
          ..write('id: $id, ')
          ..write('stageId: $stageId, ')
          ..write('optionText: $optionText, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('feedback: $feedback')
          ..write(')'))
        .toString();
  }
}

class $CaseProgressTable extends CaseProgress
    with TableInfo<$CaseProgressTable, CaseProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentStageMeta = const VerificationMeta(
    'currentStage',
  );
  @override
  late final GeneratedColumn<int> currentStage = GeneratedColumn<int>(
    'current_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _correctDecisionsMeta = const VerificationMeta(
    'correctDecisions',
  );
  @override
  late final GeneratedColumn<int> correctDecisions = GeneratedColumn<int>(
    'correct_decisions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDecisionsMeta = const VerificationMeta(
    'totalDecisions',
  );
  @override
  late final GeneratedColumn<int> totalDecisions = GeneratedColumn<int>(
    'total_decisions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hintsUsedMeta = const VerificationMeta(
    'hintsUsed',
  );
  @override
  late final GeneratedColumn<int> hintsUsed = GeneratedColumn<int>(
    'hints_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _examModeMeta = const VerificationMeta(
    'examMode',
  );
  @override
  late final GeneratedColumn<bool> examMode = GeneratedColumn<bool>(
    'exam_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exam_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    caseId,
    startedAt,
    completedAt,
    currentStage,
    correctDecisions,
    totalDecisions,
    hintsUsed,
    examMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaseProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('current_stage')) {
      context.handle(
        _currentStageMeta,
        currentStage.isAcceptableOrUnknown(
          data['current_stage']!,
          _currentStageMeta,
        ),
      );
    }
    if (data.containsKey('correct_decisions')) {
      context.handle(
        _correctDecisionsMeta,
        correctDecisions.isAcceptableOrUnknown(
          data['correct_decisions']!,
          _correctDecisionsMeta,
        ),
      );
    }
    if (data.containsKey('total_decisions')) {
      context.handle(
        _totalDecisionsMeta,
        totalDecisions.isAcceptableOrUnknown(
          data['total_decisions']!,
          _totalDecisionsMeta,
        ),
      );
    }
    if (data.containsKey('hints_used')) {
      context.handle(
        _hintsUsedMeta,
        hintsUsed.isAcceptableOrUnknown(data['hints_used']!, _hintsUsedMeta),
      );
    }
    if (data.containsKey('exam_mode')) {
      context.handle(
        _examModeMeta,
        examMode.isAcceptableOrUnknown(data['exam_mode']!, _examModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}case_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      currentStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_stage'],
      )!,
      correctDecisions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_decisions'],
      )!,
      totalDecisions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_decisions'],
      )!,
      hintsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints_used'],
      )!,
      examMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exam_mode'],
      )!,
    );
  }

  @override
  $CaseProgressTable createAlias(String alias) {
    return $CaseProgressTable(attachedDatabase, alias);
  }
}

class CaseProgressData extends DataClass
    implements Insertable<CaseProgressData> {
  final int id;
  final String caseId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentStage;
  final int correctDecisions;
  final int totalDecisions;
  final int hintsUsed;
  final bool examMode;
  const CaseProgressData({
    required this.id,
    required this.caseId,
    required this.startedAt,
    this.completedAt,
    required this.currentStage,
    required this.correctDecisions,
    required this.totalDecisions,
    required this.hintsUsed,
    required this.examMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['case_id'] = Variable<String>(caseId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['current_stage'] = Variable<int>(currentStage);
    map['correct_decisions'] = Variable<int>(correctDecisions);
    map['total_decisions'] = Variable<int>(totalDecisions);
    map['hints_used'] = Variable<int>(hintsUsed);
    map['exam_mode'] = Variable<bool>(examMode);
    return map;
  }

  CaseProgressCompanion toCompanion(bool nullToAbsent) {
    return CaseProgressCompanion(
      id: Value(id),
      caseId: Value(caseId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      currentStage: Value(currentStage),
      correctDecisions: Value(correctDecisions),
      totalDecisions: Value(totalDecisions),
      hintsUsed: Value(hintsUsed),
      examMode: Value(examMode),
    );
  }

  factory CaseProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseProgressData(
      id: serializer.fromJson<int>(json['id']),
      caseId: serializer.fromJson<String>(json['caseId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      currentStage: serializer.fromJson<int>(json['currentStage']),
      correctDecisions: serializer.fromJson<int>(json['correctDecisions']),
      totalDecisions: serializer.fromJson<int>(json['totalDecisions']),
      hintsUsed: serializer.fromJson<int>(json['hintsUsed']),
      examMode: serializer.fromJson<bool>(json['examMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'caseId': serializer.toJson<String>(caseId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'currentStage': serializer.toJson<int>(currentStage),
      'correctDecisions': serializer.toJson<int>(correctDecisions),
      'totalDecisions': serializer.toJson<int>(totalDecisions),
      'hintsUsed': serializer.toJson<int>(hintsUsed),
      'examMode': serializer.toJson<bool>(examMode),
    };
  }

  CaseProgressData copyWith({
    int? id,
    String? caseId,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? currentStage,
    int? correctDecisions,
    int? totalDecisions,
    int? hintsUsed,
    bool? examMode,
  }) => CaseProgressData(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    currentStage: currentStage ?? this.currentStage,
    correctDecisions: correctDecisions ?? this.correctDecisions,
    totalDecisions: totalDecisions ?? this.totalDecisions,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    examMode: examMode ?? this.examMode,
  );
  CaseProgressData copyWithCompanion(CaseProgressCompanion data) {
    return CaseProgressData(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      currentStage: data.currentStage.present
          ? data.currentStage.value
          : this.currentStage,
      correctDecisions: data.correctDecisions.present
          ? data.correctDecisions.value
          : this.correctDecisions,
      totalDecisions: data.totalDecisions.present
          ? data.totalDecisions.value
          : this.totalDecisions,
      hintsUsed: data.hintsUsed.present ? data.hintsUsed.value : this.hintsUsed,
      examMode: data.examMode.present ? data.examMode.value : this.examMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseProgressData(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('currentStage: $currentStage, ')
          ..write('correctDecisions: $correctDecisions, ')
          ..write('totalDecisions: $totalDecisions, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('examMode: $examMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    caseId,
    startedAt,
    completedAt,
    currentStage,
    correctDecisions,
    totalDecisions,
    hintsUsed,
    examMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseProgressData &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.currentStage == this.currentStage &&
          other.correctDecisions == this.correctDecisions &&
          other.totalDecisions == this.totalDecisions &&
          other.hintsUsed == this.hintsUsed &&
          other.examMode == this.examMode);
}

class CaseProgressCompanion extends UpdateCompanion<CaseProgressData> {
  final Value<int> id;
  final Value<String> caseId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> currentStage;
  final Value<int> correctDecisions;
  final Value<int> totalDecisions;
  final Value<int> hintsUsed;
  final Value<bool> examMode;
  const CaseProgressCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.currentStage = const Value.absent(),
    this.correctDecisions = const Value.absent(),
    this.totalDecisions = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.examMode = const Value.absent(),
  });
  CaseProgressCompanion.insert({
    this.id = const Value.absent(),
    required String caseId,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.currentStage = const Value.absent(),
    this.correctDecisions = const Value.absent(),
    this.totalDecisions = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.examMode = const Value.absent(),
  }) : caseId = Value(caseId),
       startedAt = Value(startedAt);
  static Insertable<CaseProgressData> custom({
    Expression<int>? id,
    Expression<String>? caseId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? currentStage,
    Expression<int>? correctDecisions,
    Expression<int>? totalDecisions,
    Expression<int>? hintsUsed,
    Expression<bool>? examMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (currentStage != null) 'current_stage': currentStage,
      if (correctDecisions != null) 'correct_decisions': correctDecisions,
      if (totalDecisions != null) 'total_decisions': totalDecisions,
      if (hintsUsed != null) 'hints_used': hintsUsed,
      if (examMode != null) 'exam_mode': examMode,
    });
  }

  CaseProgressCompanion copyWith({
    Value<int>? id,
    Value<String>? caseId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? currentStage,
    Value<int>? correctDecisions,
    Value<int>? totalDecisions,
    Value<int>? hintsUsed,
    Value<bool>? examMode,
  }) {
    return CaseProgressCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentStage: currentStage ?? this.currentStage,
      correctDecisions: correctDecisions ?? this.correctDecisions,
      totalDecisions: totalDecisions ?? this.totalDecisions,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      examMode: examMode ?? this.examMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (currentStage.present) {
      map['current_stage'] = Variable<int>(currentStage.value);
    }
    if (correctDecisions.present) {
      map['correct_decisions'] = Variable<int>(correctDecisions.value);
    }
    if (totalDecisions.present) {
      map['total_decisions'] = Variable<int>(totalDecisions.value);
    }
    if (hintsUsed.present) {
      map['hints_used'] = Variable<int>(hintsUsed.value);
    }
    if (examMode.present) {
      map['exam_mode'] = Variable<bool>(examMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseProgressCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('currentStage: $currentStage, ')
          ..write('correctDecisions: $correctDecisions, ')
          ..write('totalDecisions: $totalDecisions, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('examMode: $examMode')
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
  late final $ClinicalCasesTable clinicalCases = $ClinicalCasesTable(this);
  late final $CaseStagesTable caseStages = $CaseStagesTable(this);
  late final $CaseOptionsTable caseOptions = $CaseOptionsTable(this);
  late final $CaseProgressTable caseProgress = $CaseProgressTable(this);
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
    clinicalCases,
    caseStages,
    caseOptions,
    caseProgress,
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
      Value<double> easeFactor,
      Value<int?> lastQuality,
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
      Value<double> easeFactor,
      Value<int?> lastQuality,
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

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastQuality => $composableBuilder(
    column: $table.lastQuality,
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

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastQuality => $composableBuilder(
    column: $table.lastQuality,
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

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastQuality => $composableBuilder(
    column: $table.lastQuality,
    builder: (column) => column,
  );
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
                Value<double> easeFactor = const Value.absent(),
                Value<int?> lastQuality = const Value.absent(),
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
                easeFactor: easeFactor,
                lastQuality: lastQuality,
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
                Value<double> easeFactor = const Value.absent(),
                Value<int?> lastQuality = const Value.absent(),
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
                easeFactor: easeFactor,
                lastQuality: lastQuality,
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
typedef $$ClinicalCasesTableCreateCompanionBuilder =
    ClinicalCasesCompanion Function({
      required String id,
      required String title,
      required String specialty,
      Value<String> difficulty,
      Value<int> estimatedTimeMinutes,
      Value<String?> learningObjectives,
      Value<int> rowid,
    });
typedef $$ClinicalCasesTableUpdateCompanionBuilder =
    ClinicalCasesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> specialty,
      Value<String> difficulty,
      Value<int> estimatedTimeMinutes,
      Value<String?> learningObjectives,
      Value<int> rowid,
    });

final class $$ClinicalCasesTableReferences
    extends BaseReferences<_$AppDatabase, $ClinicalCasesTable, ClinicalCase> {
  $$ClinicalCasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CaseStagesTable, List<CaseStage>>
  _caseStagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.caseStages,
    aliasName: $_aliasNameGenerator(db.clinicalCases.id, db.caseStages.caseId),
  );

  $$CaseStagesTableProcessedTableManager get caseStagesRefs {
    final manager = $$CaseStagesTableTableManager(
      $_db,
      $_db.caseStages,
    ).filter((f) => f.caseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_caseStagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClinicalCasesTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalCasesTable> {
  $$ClinicalCasesTableFilterComposer({
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

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedTimeMinutes => $composableBuilder(
    column: $table.estimatedTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningObjectives => $composableBuilder(
    column: $table.learningObjectives,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> caseStagesRefs(
    Expression<bool> Function($$CaseStagesTableFilterComposer f) f,
  ) {
    final $$CaseStagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.caseStages,
      getReferencedColumn: (t) => t.caseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseStagesTableFilterComposer(
            $db: $db,
            $table: $db.caseStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClinicalCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalCasesTable> {
  $$ClinicalCasesTableOrderingComposer({
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

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedTimeMinutes => $composableBuilder(
    column: $table.estimatedTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningObjectives => $composableBuilder(
    column: $table.learningObjectives,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClinicalCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalCasesTable> {
  $$ClinicalCasesTableAnnotationComposer({
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

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedTimeMinutes => $composableBuilder(
    column: $table.estimatedTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningObjectives => $composableBuilder(
    column: $table.learningObjectives,
    builder: (column) => column,
  );

  Expression<T> caseStagesRefs<T extends Object>(
    Expression<T> Function($$CaseStagesTableAnnotationComposer a) f,
  ) {
    final $$CaseStagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.caseStages,
      getReferencedColumn: (t) => t.caseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseStagesTableAnnotationComposer(
            $db: $db,
            $table: $db.caseStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClinicalCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClinicalCasesTable,
          ClinicalCase,
          $$ClinicalCasesTableFilterComposer,
          $$ClinicalCasesTableOrderingComposer,
          $$ClinicalCasesTableAnnotationComposer,
          $$ClinicalCasesTableCreateCompanionBuilder,
          $$ClinicalCasesTableUpdateCompanionBuilder,
          (ClinicalCase, $$ClinicalCasesTableReferences),
          ClinicalCase,
          PrefetchHooks Function({bool caseStagesRefs})
        > {
  $$ClinicalCasesTableTableManager(_$AppDatabase db, $ClinicalCasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalCasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> specialty = const Value.absent(),
                Value<String> difficulty = const Value.absent(),
                Value<int> estimatedTimeMinutes = const Value.absent(),
                Value<String?> learningObjectives = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalCasesCompanion(
                id: id,
                title: title,
                specialty: specialty,
                difficulty: difficulty,
                estimatedTimeMinutes: estimatedTimeMinutes,
                learningObjectives: learningObjectives,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String specialty,
                Value<String> difficulty = const Value.absent(),
                Value<int> estimatedTimeMinutes = const Value.absent(),
                Value<String?> learningObjectives = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClinicalCasesCompanion.insert(
                id: id,
                title: title,
                specialty: specialty,
                difficulty: difficulty,
                estimatedTimeMinutes: estimatedTimeMinutes,
                learningObjectives: learningObjectives,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClinicalCasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({caseStagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (caseStagesRefs) db.caseStages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (caseStagesRefs)
                    await $_getPrefetchedData<
                      ClinicalCase,
                      $ClinicalCasesTable,
                      CaseStage
                    >(
                      currentTable: table,
                      referencedTable: $$ClinicalCasesTableReferences
                          ._caseStagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClinicalCasesTableReferences(
                            db,
                            table,
                            p0,
                          ).caseStagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.caseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClinicalCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClinicalCasesTable,
      ClinicalCase,
      $$ClinicalCasesTableFilterComposer,
      $$ClinicalCasesTableOrderingComposer,
      $$ClinicalCasesTableAnnotationComposer,
      $$ClinicalCasesTableCreateCompanionBuilder,
      $$ClinicalCasesTableUpdateCompanionBuilder,
      (ClinicalCase, $$ClinicalCasesTableReferences),
      ClinicalCase,
      PrefetchHooks Function({bool caseStagesRefs})
    >;
typedef $$CaseStagesTableCreateCompanionBuilder =
    CaseStagesCompanion Function({
      Value<int> id,
      required String caseId,
      required int stageNumber,
      Value<String> stageType,
      required String content,
    });
typedef $$CaseStagesTableUpdateCompanionBuilder =
    CaseStagesCompanion Function({
      Value<int> id,
      Value<String> caseId,
      Value<int> stageNumber,
      Value<String> stageType,
      Value<String> content,
    });

final class $$CaseStagesTableReferences
    extends BaseReferences<_$AppDatabase, $CaseStagesTable, CaseStage> {
  $$CaseStagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClinicalCasesTable _caseIdTable(_$AppDatabase db) =>
      db.clinicalCases.createAlias(
        $_aliasNameGenerator(db.caseStages.caseId, db.clinicalCases.id),
      );

  $$ClinicalCasesTableProcessedTableManager get caseId {
    final $_column = $_itemColumn<String>('case_id')!;

    final manager = $$ClinicalCasesTableTableManager(
      $_db,
      $_db.clinicalCases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_caseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CaseOptionsTable, List<CaseOption>>
  _caseOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.caseOptions,
    aliasName: $_aliasNameGenerator(db.caseStages.id, db.caseOptions.stageId),
  );

  $$CaseOptionsTableProcessedTableManager get caseOptionsRefs {
    final manager = $$CaseOptionsTableTableManager(
      $_db,
      $_db.caseOptions,
    ).filter((f) => f.stageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_caseOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CaseStagesTableFilterComposer
    extends Composer<_$AppDatabase, $CaseStagesTable> {
  $$CaseStagesTableFilterComposer({
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

  ColumnFilters<int> get stageNumber => $composableBuilder(
    column: $table.stageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageType => $composableBuilder(
    column: $table.stageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  $$ClinicalCasesTableFilterComposer get caseId {
    final $$ClinicalCasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.caseId,
      referencedTable: $db.clinicalCases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalCasesTableFilterComposer(
            $db: $db,
            $table: $db.clinicalCases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> caseOptionsRefs(
    Expression<bool> Function($$CaseOptionsTableFilterComposer f) f,
  ) {
    final $$CaseOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.caseOptions,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseOptionsTableFilterComposer(
            $db: $db,
            $table: $db.caseOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CaseStagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseStagesTable> {
  $$CaseStagesTableOrderingComposer({
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

  ColumnOrderings<int> get stageNumber => $composableBuilder(
    column: $table.stageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageType => $composableBuilder(
    column: $table.stageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClinicalCasesTableOrderingComposer get caseId {
    final $$ClinicalCasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.caseId,
      referencedTable: $db.clinicalCases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalCasesTableOrderingComposer(
            $db: $db,
            $table: $db.clinicalCases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaseStagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseStagesTable> {
  $$CaseStagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stageNumber => $composableBuilder(
    column: $table.stageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stageType =>
      $composableBuilder(column: $table.stageType, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  $$ClinicalCasesTableAnnotationComposer get caseId {
    final $$ClinicalCasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.caseId,
      referencedTable: $db.clinicalCases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClinicalCasesTableAnnotationComposer(
            $db: $db,
            $table: $db.clinicalCases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> caseOptionsRefs<T extends Object>(
    Expression<T> Function($$CaseOptionsTableAnnotationComposer a) f,
  ) {
    final $$CaseOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.caseOptions,
      getReferencedColumn: (t) => t.stageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.caseOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CaseStagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaseStagesTable,
          CaseStage,
          $$CaseStagesTableFilterComposer,
          $$CaseStagesTableOrderingComposer,
          $$CaseStagesTableAnnotationComposer,
          $$CaseStagesTableCreateCompanionBuilder,
          $$CaseStagesTableUpdateCompanionBuilder,
          (CaseStage, $$CaseStagesTableReferences),
          CaseStage,
          PrefetchHooks Function({bool caseId, bool caseOptionsRefs})
        > {
  $$CaseStagesTableTableManager(_$AppDatabase db, $CaseStagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseStagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseStagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseStagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<int> stageNumber = const Value.absent(),
                Value<String> stageType = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => CaseStagesCompanion(
                id: id,
                caseId: caseId,
                stageNumber: stageNumber,
                stageType: stageType,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String caseId,
                required int stageNumber,
                Value<String> stageType = const Value.absent(),
                required String content,
              }) => CaseStagesCompanion.insert(
                id: id,
                caseId: caseId,
                stageNumber: stageNumber,
                stageType: stageType,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CaseStagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({caseId = false, caseOptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (caseOptionsRefs) db.caseOptions],
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
                    if (caseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.caseId,
                                referencedTable: $$CaseStagesTableReferences
                                    ._caseIdTable(db),
                                referencedColumn: $$CaseStagesTableReferences
                                    ._caseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (caseOptionsRefs)
                    await $_getPrefetchedData<
                      CaseStage,
                      $CaseStagesTable,
                      CaseOption
                    >(
                      currentTable: table,
                      referencedTable: $$CaseStagesTableReferences
                          ._caseOptionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CaseStagesTableReferences(
                            db,
                            table,
                            p0,
                          ).caseOptionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CaseStagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaseStagesTable,
      CaseStage,
      $$CaseStagesTableFilterComposer,
      $$CaseStagesTableOrderingComposer,
      $$CaseStagesTableAnnotationComposer,
      $$CaseStagesTableCreateCompanionBuilder,
      $$CaseStagesTableUpdateCompanionBuilder,
      (CaseStage, $$CaseStagesTableReferences),
      CaseStage,
      PrefetchHooks Function({bool caseId, bool caseOptionsRefs})
    >;
typedef $$CaseOptionsTableCreateCompanionBuilder =
    CaseOptionsCompanion Function({
      Value<int> id,
      required int stageId,
      required String optionText,
      Value<bool> isCorrect,
      required String feedback,
    });
typedef $$CaseOptionsTableUpdateCompanionBuilder =
    CaseOptionsCompanion Function({
      Value<int> id,
      Value<int> stageId,
      Value<String> optionText,
      Value<bool> isCorrect,
      Value<String> feedback,
    });

final class $$CaseOptionsTableReferences
    extends BaseReferences<_$AppDatabase, $CaseOptionsTable, CaseOption> {
  $$CaseOptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CaseStagesTable _stageIdTable(_$AppDatabase db) =>
      db.caseStages.createAlias(
        $_aliasNameGenerator(db.caseOptions.stageId, db.caseStages.id),
      );

  $$CaseStagesTableProcessedTableManager get stageId {
    final $_column = $_itemColumn<int>('stage_id')!;

    final manager = $$CaseStagesTableTableManager(
      $_db,
      $_db.caseStages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CaseOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $CaseOptionsTable> {
  $$CaseOptionsTableFilterComposer({
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

  ColumnFilters<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  $$CaseStagesTableFilterComposer get stageId {
    final $$CaseStagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.caseStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseStagesTableFilterComposer(
            $db: $db,
            $table: $db.caseStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaseOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseOptionsTable> {
  $$CaseOptionsTableOrderingComposer({
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

  ColumnOrderings<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  $$CaseStagesTableOrderingComposer get stageId {
    final $$CaseStagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.caseStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseStagesTableOrderingComposer(
            $db: $db,
            $table: $db.caseStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaseOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseOptionsTable> {
  $$CaseOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  $$CaseStagesTableAnnotationComposer get stageId {
    final $$CaseStagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stageId,
      referencedTable: $db.caseStages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaseStagesTableAnnotationComposer(
            $db: $db,
            $table: $db.caseStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaseOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaseOptionsTable,
          CaseOption,
          $$CaseOptionsTableFilterComposer,
          $$CaseOptionsTableOrderingComposer,
          $$CaseOptionsTableAnnotationComposer,
          $$CaseOptionsTableCreateCompanionBuilder,
          $$CaseOptionsTableUpdateCompanionBuilder,
          (CaseOption, $$CaseOptionsTableReferences),
          CaseOption,
          PrefetchHooks Function({bool stageId})
        > {
  $$CaseOptionsTableTableManager(_$AppDatabase db, $CaseOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> stageId = const Value.absent(),
                Value<String> optionText = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<String> feedback = const Value.absent(),
              }) => CaseOptionsCompanion(
                id: id,
                stageId: stageId,
                optionText: optionText,
                isCorrect: isCorrect,
                feedback: feedback,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int stageId,
                required String optionText,
                Value<bool> isCorrect = const Value.absent(),
                required String feedback,
              }) => CaseOptionsCompanion.insert(
                id: id,
                stageId: stageId,
                optionText: optionText,
                isCorrect: isCorrect,
                feedback: feedback,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CaseOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stageId = false}) {
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
                    if (stageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stageId,
                                referencedTable: $$CaseOptionsTableReferences
                                    ._stageIdTable(db),
                                referencedColumn: $$CaseOptionsTableReferences
                                    ._stageIdTable(db)
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

typedef $$CaseOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaseOptionsTable,
      CaseOption,
      $$CaseOptionsTableFilterComposer,
      $$CaseOptionsTableOrderingComposer,
      $$CaseOptionsTableAnnotationComposer,
      $$CaseOptionsTableCreateCompanionBuilder,
      $$CaseOptionsTableUpdateCompanionBuilder,
      (CaseOption, $$CaseOptionsTableReferences),
      CaseOption,
      PrefetchHooks Function({bool stageId})
    >;
typedef $$CaseProgressTableCreateCompanionBuilder =
    CaseProgressCompanion Function({
      Value<int> id,
      required String caseId,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int> currentStage,
      Value<int> correctDecisions,
      Value<int> totalDecisions,
      Value<int> hintsUsed,
      Value<bool> examMode,
    });
typedef $$CaseProgressTableUpdateCompanionBuilder =
    CaseProgressCompanion Function({
      Value<int> id,
      Value<String> caseId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> currentStage,
      Value<int> correctDecisions,
      Value<int> totalDecisions,
      Value<int> hintsUsed,
      Value<bool> examMode,
    });

class $$CaseProgressTableFilterComposer
    extends Composer<_$AppDatabase, $CaseProgressTable> {
  $$CaseProgressTableFilterComposer({
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

  ColumnFilters<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctDecisions => $composableBuilder(
    column: $table.correctDecisions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDecisions => $composableBuilder(
    column: $table.totalDecisions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get examMode => $composableBuilder(
    column: $table.examMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CaseProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseProgressTable> {
  $$CaseProgressTableOrderingComposer({
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

  ColumnOrderings<String> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctDecisions => $composableBuilder(
    column: $table.correctDecisions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDecisions => $composableBuilder(
    column: $table.totalDecisions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get examMode => $composableBuilder(
    column: $table.examMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CaseProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseProgressTable> {
  $$CaseProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctDecisions => $composableBuilder(
    column: $table.correctDecisions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDecisions => $composableBuilder(
    column: $table.totalDecisions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintsUsed =>
      $composableBuilder(column: $table.hintsUsed, builder: (column) => column);

  GeneratedColumn<bool> get examMode =>
      $composableBuilder(column: $table.examMode, builder: (column) => column);
}

class $$CaseProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaseProgressTable,
          CaseProgressData,
          $$CaseProgressTableFilterComposer,
          $$CaseProgressTableOrderingComposer,
          $$CaseProgressTableAnnotationComposer,
          $$CaseProgressTableCreateCompanionBuilder,
          $$CaseProgressTableUpdateCompanionBuilder,
          (
            CaseProgressData,
            BaseReferences<_$AppDatabase, $CaseProgressTable, CaseProgressData>,
          ),
          CaseProgressData,
          PrefetchHooks Function()
        > {
  $$CaseProgressTableTableManager(_$AppDatabase db, $CaseProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> caseId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> currentStage = const Value.absent(),
                Value<int> correctDecisions = const Value.absent(),
                Value<int> totalDecisions = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<bool> examMode = const Value.absent(),
              }) => CaseProgressCompanion(
                id: id,
                caseId: caseId,
                startedAt: startedAt,
                completedAt: completedAt,
                currentStage: currentStage,
                correctDecisions: correctDecisions,
                totalDecisions: totalDecisions,
                hintsUsed: hintsUsed,
                examMode: examMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String caseId,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> currentStage = const Value.absent(),
                Value<int> correctDecisions = const Value.absent(),
                Value<int> totalDecisions = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<bool> examMode = const Value.absent(),
              }) => CaseProgressCompanion.insert(
                id: id,
                caseId: caseId,
                startedAt: startedAt,
                completedAt: completedAt,
                currentStage: currentStage,
                correctDecisions: correctDecisions,
                totalDecisions: totalDecisions,
                hintsUsed: hintsUsed,
                examMode: examMode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CaseProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaseProgressTable,
      CaseProgressData,
      $$CaseProgressTableFilterComposer,
      $$CaseProgressTableOrderingComposer,
      $$CaseProgressTableAnnotationComposer,
      $$CaseProgressTableCreateCompanionBuilder,
      $$CaseProgressTableUpdateCompanionBuilder,
      (
        CaseProgressData,
        BaseReferences<_$AppDatabase, $CaseProgressTable, CaseProgressData>,
      ),
      CaseProgressData,
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
  $$ClinicalCasesTableTableManager get clinicalCases =>
      $$ClinicalCasesTableTableManager(_db, _db.clinicalCases);
  $$CaseStagesTableTableManager get caseStages =>
      $$CaseStagesTableTableManager(_db, _db.caseStages);
  $$CaseOptionsTableTableManager get caseOptions =>
      $$CaseOptionsTableTableManager(_db, _db.caseOptions);
  $$CaseProgressTableTableManager get caseProgress =>
      $$CaseProgressTableTableManager(_db, _db.caseProgress);
}
