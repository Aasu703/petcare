// lib/features/home/presentation/providers/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/bottomnavigation/presentation/state/home_state.dart';
import '../view_model/home_view_model.dart';

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
