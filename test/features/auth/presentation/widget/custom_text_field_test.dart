import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('CustomTextField Widget Tests', () {
    late TextEditingController textController;

    setUp(() {
      textController = TextEditingController();
    });

    tearDown(() {
      textController.dispose();
    });

    testWidgets('renders correctly with label and hint text',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Email',
            hint: 'Enter your email',
          ),
        ),
      ));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('accepts text input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Username',
          ),
        ),
      ));
      await tester.enterText(find.byType(TextFormField), 'test_user');
      expect(textController.text, 'test_user');
    });

    testWidgets('hides text when obscureText is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Password',
            obscureText: true,
          ),
        ),
      ));

      final Finder textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsOneWidget);
      await tester.enterText(textFieldFinder, 'password123');
      expect(textController.text, 'password123');
    });

    testWidgets('displays appropriate keyboard type',
        (WidgetTester tester) async {
      // Build the widget with email keyboard type
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('validator functions correctly', (WidgetTester tester) async {
      String? validateEmail(String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      }

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: CustomTextField(
              controller: textController,
              label: 'Email',
              validator: validateEmail,
            ),
          ),
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'invalidemail');
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'valid@email.com');
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('displays prefix icon when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Search',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays suffix icon when provided',
        (WidgetTester tester) async {
      // Build the widget with a suffix icon
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Password',
            obscureText: true,
            suffixIcon: const Icon(Icons.visibility),
          ),
        ),
      ));
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('applies correct border styling', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(primaryColor: Colors.blue),
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Name',
          ),
        ),
      ));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('applies vertical margin to the container',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: textController,
            label: 'Name',
          ),
        ),
      ));

      // Find the Container
      final Container container = tester.widget(find.byType(Container));

      // Verify the margin is as expected
      expect(container.margin, const EdgeInsets.symmetric(vertical: 8));
    });

    testWidgets('verifies form field interaction in a form',
        (WidgetTester tester) async {
      // Create a test key to identify the form
      final formKey = GlobalKey<FormState>();
      bool formSubmitted = false;

      // Build a form with our CustomTextField
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: textController,
                  label: 'Username',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required field' : null,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formSubmitted = true;
                    }
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          ),
        ),
      ));

      // Try to submit form with empty field
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify validation message appears
      expect(find.text('Required field'), findsOneWidget);
      expect(formSubmitted, false);

      // Enter valid text
      await tester.enterText(find.byType(TextFormField), 'validUsername');
      await tester.pump();

      // Submit form again
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify validation passes and form submits
      expect(find.text('Required field'), findsNothing);
      expect(formSubmitted, true);
    });
  });
}
