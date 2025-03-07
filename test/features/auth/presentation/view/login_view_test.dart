import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tottouchordertastemobileapplication/app/shared_prefs/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/biometric_auth_service.dart';
// Import the actual login view and related classes
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_state.dart';

// Generate mocks
@GenerateMocks([LoginBloc, BiometricAuthService, SharedPreferencesService])
import 'login_view_test.mocks.dart';

void main() {
  late MockLoginBloc mockLoginBloc;
  late MockBiometricAuthService mockBiometricService;
  late MockSharedPreferencesService mockSharedPrefs;
  final getIt = GetIt.instance;

  setUp(() {
    // Reset and register mock services
    mockLoginBloc = MockLoginBloc();
    mockBiometricService = MockBiometricAuthService();
    mockSharedPrefs = MockSharedPreferencesService();

    // Clear previous registrations
    if (getIt.isRegistered<BiometricAuthService>()) {
      getIt.unregister<BiometricAuthService>();
    }
    if (getIt.isRegistered<SharedPreferencesService>()) {
      getIt.unregister<SharedPreferencesService>();
    }

    // Register mock services
    getIt.registerSingleton<BiometricAuthService>(mockBiometricService);
    getIt.registerSingleton<SharedPreferencesService>(mockSharedPrefs);

    // Setup default mock behaviors
    final stateController = BehaviorSubject<LoginState>.seeded(LoginInitial());
    when(mockLoginBloc.state).thenReturn(LoginInitial());
    when(mockLoginBloc.stream).thenAnswer((_) => stateController.stream);

    when(mockBiometricService.isDeviceSupportedBiometrics())
        .thenAnswer((_) async => false);
    when(mockSharedPrefs.getBool(any)).thenReturn(false);
    when(mockSharedPrefs.getString(any)).thenReturn(null);
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return BlocProvider<LoginBloc>.value(
            value: mockLoginBloc,
            child: child,
          );
        },
      ),
    );
  }

  testWidgets('Successful login with valid credentials',
      (WidgetTester tester) async {
    when(mockBiometricService.isDeviceSupportedBiometrics())
        .thenAnswer((_) async => false);

    await tester.pumpWidget(createTestWidget(const LoginView()));

    await tester.enterText(
        find.widgetWithText(TextField, 'Enter your email'), 'law@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Enter your password'), 'Haseenakc123');

    await tester.tap(find.text('Log In'));
    await tester.pump();

    verify(mockLoginBloc.add(argThat(isA<LoginSubmitted>()
            .having((event) => event.email, 'email', equals('law@gmail.com')))))
        .called(1);
  });


  testWidgets('Form validation prevents login with empty fields',
      (WidgetTester tester) async {

    await tester.pumpWidget(createTestWidget(const LoginView()));
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    verifyNever(mockLoginBloc.add(any));
  });

  testWidgets('Password visibility can be toggled',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const LoginView()));
    final passwordField = find.widgetWithText(TextField, 'Enter your password');
    TextField textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isFalse);
  });
}
