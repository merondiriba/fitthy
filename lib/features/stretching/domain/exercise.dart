class Exercise {
  final String id;
  final String name;
  final String assetPath; // e.g. assets/stretch/pose1.png
  final bool included;

  const Exercise({
    required this.id,
    required this.name,
    required this.assetPath,
    this.included = true,
  });

  Exercise copyWith({String? name, String? assetPath, bool? included}) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      included: included ?? this.included,
    );
  }
}