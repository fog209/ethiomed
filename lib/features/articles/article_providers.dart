import 'package:flutter_riverpod/flutter_riverpod.dart';

final highYieldModeProvider = StateProvider<bool>((ref) => false);

final subcategoryFilterProvider = StateProvider<String?>((ref) => null);
