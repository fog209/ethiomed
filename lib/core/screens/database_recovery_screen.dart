import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseRecoveryApp extends StatelessWidget {
  const DatabaseRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DatabaseRecoveryScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFB300),
        ),
      ),
    );
  }
}

class DatabaseRecoveryScreen extends StatefulWidget {
  const DatabaseRecoveryScreen({super.key});

  @override
  State<DatabaseRecoveryScreen> createState() => _DatabaseRecoveryScreenState();
}

class _DatabaseRecoveryScreenState extends State<DatabaseRecoveryScreen> {
  bool _isResetting = false;

  Future<void> _resetAndResync() async {
    setState(() {
      _isResetting = true;
    });

    final documentsPath = await getApplicationDocumentsDirectory();
    final paths = <String>[
      p.join(documentsPath.path, 'wardready.db'),
      p.join(documentsPath.path, 'wardready.db-shm'),
      p.join(documentsPath.path, 'wardready.db-wal'),
      p.join(documentsPath.path, 'ethiomed.sqlite'),
      p.join(documentsPath.path, 'ethiomed.sqlite-shm'),
      p.join(documentsPath.path, 'ethiomed.sqlite-wal'),
    ];

    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    if (!mounted) {
      return;
    }

    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage, color: Colors.amber, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'App data could not be loaded',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your downloaded content needs to be refreshed.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isResetting ? null : _resetAndResync,
                    child: Text(
                      _isResetting ? 'Resetting...' : 'Reset & Re-sync',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your account and subscription are not affected',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}