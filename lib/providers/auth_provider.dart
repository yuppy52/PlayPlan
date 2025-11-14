import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final authService = ref.watch(authServiceProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return authService.getUser(user.uid);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
