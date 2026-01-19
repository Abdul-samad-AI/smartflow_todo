import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mood_model.dart';

final moodProvider = StateProvider<UserMood>(
  (ref) => UserMood.normal,
);
