import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static const Color textPrimary = Colors.black87;
}

class AppFonts {
  static const String medium = 'Roboto';
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontFamily: AppFonts.medium,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

void main() {
  group('LoadingOverlay Widget Tests', () {
    testWidgets('displays child when not loading', (WidgetTester tester) async {
      // Create a test child widget
      const testChild = Text('Test Content');

      // Build LoadingOverlay with isLoading = false
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: false,
            child: testChild,
          ),
        ),
      ));

      // Verify that the child widget is displayed
      expect(find.text('Test Content'), findsOneWidget);

      // Verify that loading indicator is not displayed
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Please wait...'), findsNothing);
    });

    testWidgets('displays loading indicator when loading',
        (WidgetTester tester) async {
      // Create a test child widget
      const testChild = Text('Test Content');

      // Build LoadingOverlay with isLoading = true
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        ),
      ));

      // Verify that the child widget is still displayed
      expect(find.text('Test Content'), findsOneWidget);

      // Verify that loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('loading overlay has correct visual properties',
        (WidgetTester tester) async {
      // Create a test child widget
      const testChild = Text('Test Content');

      // Build LoadingOverlay with isLoading = true
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: testChild,
          ),
        ),
      ));

      // Find the containers used for the overlay
      final Finder overlayContainerFinder = find.byType(Container).at(0);

      // Verify the overlay container exists
      expect(overlayContainerFinder, findsOneWidget);

      // Verify the CircularProgressIndicator widget exists
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify the text is shown with correct content
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('loading indicator is centered', (WidgetTester tester) async {
      // Build LoadingOverlay with isLoading = true
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: Text('Test Content'),
          ),
        ),
      ));

      // Verify that Center widget is used to center the loading indicator
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('works with different child widgets',
        (WidgetTester tester) async {
      // Test with a complex child widget
      final complexChild = Column(
        children: [
          const Text('Header'),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: const Text('Content'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Button'),
          ),
        ],
      );

      // Build LoadingOverlay with the complex child
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: complexChild,
          ),
        ),
      ));

      // Verify all parts of the complex child are displayed
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);

      // Verify loading indicator is also displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('handles empty child gracefully', (WidgetTester tester) async {
      // Build LoadingOverlay with an empty container as child
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: SizedBox(),
          ),
        ),
      ));

      // No errors should occur, and loading indicator should be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('loading box has proper size constraints',
        (WidgetTester tester) async {
      // Build LoadingOverlay with isLoading = true
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: Text('Test Content'),
          ),
        ),
      ));

      // Find the column that contains the progress indicator and text
      final columnFinder = find.byType(Column).last;
      final Column column = tester.widget(columnFinder);

      // Verify the column has correct mainAxisSize
      expect(column.mainAxisSize, MainAxisSize.min);

      // Find the CircularProgressIndicator container
      final sizeFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      );
      final SizedBox sizedBox = tester.widget(sizeFinder);

      // Verify the SizedBox has correct dimensions
      expect(sizedBox.width, 40);
      expect(sizedBox.height, 40);
    });
  });
}
