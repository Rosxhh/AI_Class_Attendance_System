import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges;
});
