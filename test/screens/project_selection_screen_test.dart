import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/models/project.dart';
import 'package:archify_app/screens/project_selection_screen.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/theme/app_theme.dart';

class _FakeApiService extends ApiService {
  _FakeApiService(this._projects);

  final List<Project> _projects;

  @override
  Future<Map<String, dynamic>> getProjects() async {
    return {'success': true, 'projects': _projects};
  }
}

void main() {
  group('ProjectSelectionScreen', () {
    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: const ProjectSelectionScreen(previewId: 1),
      );
    }

    testWidgets('should display destination text', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Waar wil je deze schets opslaan?'), findsWidgets);
    });

    testWidgets('should have PROJECT badge', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('PROJECT'), findsOneWidget);
    });

    testWidgets('should upload to my sketches initially', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.text('Uploaden naar Mijn Schetsen'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have back button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(IconButton), findsOneWidget);
    });
  });

  group('ProjectSelectionScreen search (AR-190)', () {
    Widget createScreen(ApiService api) {
      return MaterialApp(
        theme: AppTheme.theme,
        home: ProjectSelectionScreen(previewId: 1, apiService: api),
      );
    }

    final projects = [
      const Project(id: 1, title: 'Login flow'),
      const Project(id: 2, title: 'Onboarding'),
      const Project(id: 3, title: 'Betaal flow'),
    ];

    testWidgets('shows a search field and all projects once loaded', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen(_FakeApiService(projects)));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Login flow'), findsOneWidget);
      expect(find.text('Onboarding'), findsOneWidget);
      expect(find.text('Betaal flow'), findsOneWidget);
    });

    testWidgets('filters the list on a case-insensitive substring', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen(_FakeApiService(projects)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'FLOW');
      await tester.pumpAndSettle();

      expect(find.text('Login flow'), findsOneWidget);
      expect(find.text('Betaal flow'), findsOneWidget);
      expect(find.text('Onboarding'), findsNothing);
      expect(find.text('Mijn Schetsen'), findsOneWidget);
    });

    testWidgets('shows an empty state when nothing matches', (tester) async {
      await tester.pumpWidget(createScreen(_FakeApiService(projects)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Geen projecten gevonden'), findsOneWidget);
      expect(find.text('Login flow'), findsNothing);
      expect(find.text('Onboarding'), findsNothing);
      expect(find.text('Mijn Schetsen'), findsOneWidget);
    });

    testWidgets('clearing the query restores the full list', (tester) async {
      await tester.pumpWidget(createScreen(_FakeApiService(projects)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Onboarding');
      await tester.pumpAndSettle();
      expect(find.text('Login flow'), findsNothing);

      await tester.tap(find.byTooltip('Zoekopdracht wissen'));
      await tester.pumpAndSettle();

      expect(find.text('Login flow'), findsOneWidget);
      expect(find.text('Onboarding'), findsOneWidget);
      expect(find.text('Betaal flow'), findsOneWidget);
    });
  });
}
