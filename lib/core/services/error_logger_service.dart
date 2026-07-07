import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ErrorLoggerService {
  static const String _fileName = 'crash_log.txt';
  static const int _maxChars = 100000; // Cap at ~100KB of text

  static Future<void> logError(String error, StackTrace? stack) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] ERROR: $error\nSTACK: $stack\n---\n';

      // Append the new error to the top (simple prepend replacement)
      String currentContent = '';
      if (await file.exists()) {
        currentContent = await file.readAsString();
      }

      // Keep it within size limits
      String newContent = logEntry + currentContent;
      if (newContent.length > _maxChars) {
        newContent = newContent.substring(0, _maxChars);
      }

      await file.writeAsString(newContent);
      debugPrint('Error logged locally.');
    } catch (e) {
      // Fail silently - never crash the app while trying to log a crash
    }
  }

  static Future<String> getLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'No logs found.';
    } catch (e) {
      return 'Could not read logs.';
    }
  }

  static Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      if (await file.exists()) await file.delete();
    } catch (e) {
      // Fail silently - never crash the app while trying to clear logs
    }
  }
}
