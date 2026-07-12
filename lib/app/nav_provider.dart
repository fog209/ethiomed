import 'package:flutter_riverpod/flutter_riverpod.dart';

// 0: Home, 1: Library, 2: Search, 3: Saved, 4: Quiz, 5: Settings
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);