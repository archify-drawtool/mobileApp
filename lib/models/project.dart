class Project {
  final int id;
  final String title;

  const Project({required this.id, required this.title});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(id: json['id'] as int, title: json['title'] as String);
  }
}
