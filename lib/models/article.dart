class Article {
  const Article({
    required this.title,
    required this.category,
    required this.subcategory,
    required this.theEssence,
    required this.theLogic,
    required this.thePortrait,
    required this.clinicalLink,
    required this.theEthiopianBedside,
    required this.survivalPearl,
    required this.curiosityCorner,
    required this.thePlan,
    required this.relatedTopics,
    required this.mnemonics,
  });

  final String title;
  final String category;
  final String subcategory;
  final String theEssence;
  final String theLogic;
  final String thePortrait;
  final String clinicalLink;
  final String theEthiopianBedside;
  final String survivalPearl;
  final String curiosityCorner;
  final String thePlan;
  final List<String> relatedTopics;
  final String mnemonics;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String? ?? '',
      theEssence: json['theEssence'] as String? ?? '',
      theLogic: json['theLogic'] as String? ?? '',
      thePortrait: json['thePortrait'] as String? ?? '',
      clinicalLink: json['clinicalLink'] as String? ?? '',
      theEthiopianBedside: json['theEthiopianBedside'] as String? ?? '',
      survivalPearl: json['survivalPearl'] as String? ?? '',
      curiosityCorner: json['curiosityCorner'] as String? ?? '',
      thePlan: json['thePlan'] as String? ?? '',
      relatedTopics: (json['relatedTopics'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      mnemonics: json['mnemonics'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'category': category,
      'subcategory': subcategory,
      'theEssence': theEssence,
      'theLogic': theLogic,
      'thePortrait': thePortrait,
      'clinicalLink': clinicalLink,
      'theEthiopianBedside': theEthiopianBedside,
      'survivalPearl': survivalPearl,
      'curiosityCorner': curiosityCorner,
      'thePlan': thePlan,
      'relatedTopics': relatedTopics,
      'mnemonics': mnemonics,
    };
  }

  bool get matchesWardReadySchema {
    final json = toJson();
    return wardReadyArticleKeys.every(json.containsKey);
  }

  static const List<String> wardReadyArticleKeys = <String>[
    'title',
    'category',
    'subcategory',
    'theEssence',
    'theLogic',
    'thePortrait',
    'clinicalLink',
    'theEthiopianBedside',
    'survivalPearl',
    'curiosityCorner',
    'thePlan',
    'relatedTopics',
    'mnemonics',
  ];
}

class ArticleSection {
  const ArticleSection({required this.label, required this.body});

  final String label;
  final String body;
}

extension ArticleSections on Article {
  List<ArticleSection> get textSections {
    return <ArticleSection>[
      ArticleSection(label: 'The Essence', body: theEssence),
      ArticleSection(label: 'The Logic', body: theLogic),
      ArticleSection(label: 'The Portrait', body: thePortrait),
      ArticleSection(label: 'Clinical Link', body: clinicalLink),
      ArticleSection(label: 'The Ethiopian Bedside', body: theEthiopianBedside),
      ArticleSection(label: 'Survival Pearl', body: survivalPearl),
      ArticleSection(label: 'Curiosity Corner', body: curiosityCorner),
      ArticleSection(label: 'The Plan', body: thePlan),
      ArticleSection(label: 'Mnemonics', body: mnemonics),
    ];
  }
}
