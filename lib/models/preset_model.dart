import 'dart:convert';

class EmailRecipientPreset {
  final String id;
  final String name;
  final String email;

  EmailRecipientPreset({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory EmailRecipientPreset.fromMap(Map<String, dynamic> map) {
    return EmailRecipientPreset(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EmailRecipientPreset.fromJson(String source) =>
      EmailRecipientPreset.fromMap(json.decode(source));
}

class TitlePreset {
  final String id;
  final String title;

  TitlePreset({
    required this.id,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory TitlePreset.fromMap(Map<String, dynamic> map) {
    return TitlePreset(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TitlePreset.fromJson(String source) =>
      TitlePreset.fromMap(json.decode(source));
}
