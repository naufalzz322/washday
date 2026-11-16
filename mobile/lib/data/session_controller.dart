import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'seed.dart';

enum SignInFailure {
  missingEmail,
  missingPassword,
  unknownEmail,
  wrongPassword,
}

class SignInResult {
  const SignInResult.success(this.account) : failure = null;
  const SignInResult.failure(this.failure) : account = null;

  final WashdayAccount? account;
  final SignInFailure? failure;

  bool get ok => account != null;

  String? get message => switch (failure) {
    SignInFailure.missingEmail => 'Enter your email address.',
    SignInFailure.missingPassword => 'Enter your password.',
    SignInFailure.unknownEmail =>
      'We couldn’t find an account with that email.',
    SignInFailure.wrongPassword => 'Check your password and try again.',
    null => null,
  };
}

class SessionController extends Notifier<WashdayAccount?> {
  @override
  WashdayAccount? build() => null;

  SignInResult signIn(String email, String password) {
    if (email.trim().isEmpty) {
      return const SignInResult.failure(SignInFailure.missingEmail);
    }
    if (password.isEmpty) {
      return const SignInResult.failure(SignInFailure.missingPassword);
    }
    final account = accountByEmail(email);
    if (account == null) {
      return const SignInResult.failure(SignInFailure.unknownEmail);
    }
    if (account.password != password) {
      return const SignInResult.failure(SignInFailure.wrongPassword);
    }
    state = account;
    return SignInResult.success(account);
  }

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionController, WashdayAccount?>(
  SessionController.new,
);

/// The signed-in account, or Customer A when a route is opened directly.
final currentAccountProvider = Provider<WashdayAccount>((ref) {
  return ref.watch(sessionProvider) ?? washdayAccounts.first;
});
