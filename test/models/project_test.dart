import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/models/project.dart';

void main() {
  group('Project', () {
    test('should create from JSON', () {
      final project = Project.fromJson({'id': 1, 'title': 'Test Project'});

      expect(project.id, 1);
      expect(project.title, 'Test Project');
    });

    test('should handle extra JSON fields without crashing', () {
      final project = Project.fromJson({
        'id': 2,
        'title': 'Another Project',
        'created_by': 5,
        'creator': {'id': 5, 'name': 'Freek', 'email': 'freek@test.com'},
      });

      expect(project.id, 2);
      expect(project.title, 'Another Project');
    });
  });
}
