import 'package:flutter_riverpod/flutter_riverpod.dart';

// 0: Library, 1: Search, 2: Saved, 3: Settings
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);