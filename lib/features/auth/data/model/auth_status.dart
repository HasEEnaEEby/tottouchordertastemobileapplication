import 'package:hive/hive.dart';


@HiveType(typeId: 3)
enum AuthStatus {
  @HiveField(0)
  initial,

  @HiveField(1)
  authenticated,

  @HiveField(2)
  unauthenticated,

  @HiveField(3)
  verificationPending,

  @HiveField(4)
  blocked;

  bool get isAuthenticated => this == AuthStatus.authenticated;

  bool get isUnauthenticated => this == AuthStatus.unauthenticated;

  bool get isPendingVerification => this == AuthStatus.verificationPending;

  bool get isBlocked => this == AuthStatus.blocked;

  bool get isInitial => this == AuthStatus.initial;

  static AuthStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'authenticated':
        return AuthStatus.authenticated;
      case 'unauthenticated':
        return AuthStatus.unauthenticated;
      case 'verificationpending':
      case 'verification_pending':
        return AuthStatus.verificationPending;
      case 'blocked':
        return AuthStatus.blocked;
      default:
        return AuthStatus.initial;
    }
  }

  @override
  String toString() {
    switch (this) {
      case AuthStatus.authenticated:
        return 'authenticated';
      case AuthStatus.unauthenticated:
        return 'unauthenticated';
      case AuthStatus.verificationPending:
        return 'verification_pending';
      case AuthStatus.blocked:
        return 'blocked';
      case AuthStatus.initial:
        return 'initial';
    }
  }
}
