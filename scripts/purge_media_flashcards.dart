import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:sqlite3/sqlite3.dart';

final srcDir = r"C:\wr_work\wardready\apkg";
final outJson = File(r"C:\Users\TestUser\ethiomed\scripts\apkg_flashcards_purged.json");

final mediaPatterns = [
  '<img',
  'src=',
  'data:image',
  '[sound:',
  '<audio',
  '<video',
];

bool hasMedia(String text) {
  final lower = text.toLowerCase();
  return mediaPatterns.any((p) => lower.contains(p.toLowerCase()));
}

Future<List<Map<String, dynamic>>> parseApkg(String path) async {
  final cards = <Map<String, dynamic>>[];
  final file = File(path);
  final bytes = await file.readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  ArchiveFile? uncompressedFile;
  ArchiveFile? zstdFile;

  for (final archiveFile in archive.files) {
    if (archiveFile.name.startsWith('collection.anki') && !archiveFile.isSymbolicLink) {
      if (archiveFile.name.endsWith('b')) {
        zstdFile = archiveFile;
      } else {
        uncompressedFile = archiveFile;
      }
    }
  }

  // Prefer uncompressed file, fall back to zstd if needed
  ArchiveFile? dbFile;
  bool isZstd = false;

  if (uncompressedFile != null) {
    dbFile = uncompressedFile;
  } else if (zstdFile != null) {
    dbFile = zstdFile;
    isZstd = true;
  }

  if (dbFile == null) return cards;

  List<int> dbBytes = dbFile.content;

  if (isZstd) {
    final inputFile = File('${Directory.systemTemp.path}/input_zstd_${DateTime.now().millisecondsSinceEpoch}.bin');
    final outputFile = File('${Directory.systemTemp.path}/output_zstd_${DateTime.now().millisecondsSinceEpoch}.anki2');
    await inputFile.writeAsBytes(dbBytes);

    final result = await Process.run(
      'python',
      ['-c', '''
import sys
import zstandard as zstd
with open(sys.argv[1], "rb") as f:
    data = f.read()
dctx = zstd.ZstdDecompressor()
stream_reader = dctx.stream_reader(data)
result = stream_reader.read()
with open(sys.argv[2], "wb") as f:
    f.write(result)
''', inputFile.path, outputFile.path],
    );

    await inputFile.delete();
    if (result.exitCode != 0) {
      print('Zstd decompression failed for $path');
      return cards;
    }
    dbBytes = await outputFile.readAsBytes();
    await outputFile.delete();
  }

  final tempFile = File('${Directory.systemTemp.path}/collection_${DateTime.now().millisecondsSinceEpoch}.anki2');
  await tempFile.writeAsBytes(dbBytes);

  final db = sqlite3.open(tempFile.path);
  try {
    final colResult = db.select("SELECT decks, models FROM col");
    if (colResult.isEmpty) return cards;

    final colRow = colResult[0];
    final decks = jsonDecode(colRow[0] as String) as Map<String, dynamic>;
    final models = jsonDecode(colRow[1] as String) as Map<String, dynamic>;

    final modelMap = <String, Map<String, dynamic>>{};
    for (final entry in models.entries) {
      final mval = entry.value as Map<String, dynamic>;
      final flds = mval['flds'] as List<dynamic>;
      final fieldNames = flds.map((f) => (f as Map<String, dynamic>)['name'] as String).toList();
      modelMap[entry.key] = {
        'name': mval['name'] ?? '',
        'isCloze': mval['type'] == 1,
        'fieldNames': fieldNames,
      };
    }

    final deckNames = <String, String>{};
    for (final entry in decks.entries) {
      final dval = entry.value as Map<String, dynamic>;
      deckNames[entry.key] = dval['name'] ?? 'Unknown';
    }

    final rows = db.select("SELECT n.id, n.mid, n.flds, c.did FROM notes n JOIN cards c ON c.nid = n.id");

    for (final row in rows) {
      final mid = row[1] as int;
      final flds = row[2] as String;
      final did = row[3] as int;

      final m = modelMap[mid.toString()];
      if (m == null) continue;

      final deckName = deckNames[did.toString()] ?? 'Unknown';
      final fields = flds.split('\x1f');

      if (m['isCloze'] as bool) {
        final text = fields.isNotEmpty ? fields[0] : '';
        final extra = fields.length > 1 ? fields[1] : '';
        final clozeCards = extractClozeCards(text, extra, deckName);
        cards.addAll(clozeCards);
      } else {
        final front = fields.length > 0 ? fields[0] : '';
        final back = fields.length > 1 ? fields[1] : '';
        cards.add({'deck': deckName, 'front': front, 'back': back});
      }
    }
  } finally {
    db.dispose();
    await tempFile.delete();
  }

  return cards;
}

List<Map<String, dynamic>> extractClozeCards(String textField, String extraField, String deckName) {
  final cards = <Map<String, dynamic>>[];
  final regex = RegExp(r'\{\{c(\d+)::(.*?)(?:::([^}]*?))?\}\}', dotAll: true);
  final found = regex.allMatches(textField).toList();

  final numbers = found.map((m) => int.parse(m.group(1)!)).toSet().toList()..sort();

  for (final num in numbers) {
    final front = _replaceClozePrompt(textField, num, regex);
    var back = _replaceClozeBack(textField, num, regex);

    if (extraField.isNotEmpty) {
      back = back + '\n\n' + extraField;
    }

    cards.add({'deck': deckName, 'front': front, 'back': back});
  }

  return cards;
}

String _replaceClozePrompt(String text, int num, RegExp regex) {
  return text.replaceAllMapped(regex, (m) {
    final n = int.parse(m.group(1)!);
    final hint = m.group(3);
    if (n == num) {
      return hint != null ? '[$hint]' : '[...]';
    }
    return '[...]';
  });
}

String _replaceClozeBack(String text, int num, RegExp regex) {
  return text.replaceAllMapped(regex, (m) {
    final n = int.parse(m.group(1)!);
    final ans = m.group(2)!.trim();
    return n == num ? ans : '[...]';
  });
}

void main() async {
  final totalCards = <Map<String, dynamic>>[];
  int totalFound = 0;
  int purged = 0;
  int survived = 0;

  final apkgDir = Directory(srcDir);
  if (!apkgDir.existsSync()) {
    print('ERROR: Source directory does not exist: $srcDir');
    exit(1);
  }

  final apkgFiles = apkgDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.apkg'))
      .toList();

  for (final apkgFile in apkgFiles) {
    print('Processing: ${apkgFile.path}');
    final cards = await parseApkg(apkgFile.path);

    for (final card in cards) {
      totalFound++;
      final front = card['front'] as String;
      final back = card['back'] as String;

      if (hasMedia(front) || hasMedia(back)) {
        purged++;
      } else {
        survived++;
        totalCards.add(card);
      }
    }
  }

  final jsonString = const JsonEncoder().convert(totalCards);
  await outJson.writeAsString(jsonString);

  print('');
  print('=== FINAL COUNTS ===');
  print('Total Cards Found: $totalFound');
  print('Cards Purged: $purged');
  print('Cards Surviving: $survived');
  print('');
  print('Surviving cards saved to: ${outJson.path}');
}