import 'dart:convert';

class ReportModel {
  final String id;
  final String title;
  final List<String> recipients;
  final String bodyText;
  final List<String> photoPaths;
  final DateTime createdAt;
  final bool isSent;

  ReportModel({
    required this.id,
    required this.title,
    required this.recipients,
    required this.bodyText,
    required this.photoPaths,
    required this.createdAt,
    this.isSent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recipients': recipients,
      'bodyText': bodyText,
      'photoPaths': photoPaths,
      'createdAt': createdAt.toIso8601String(),
      'isSent': isSent,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      recipients: List<String>.from(map['recipients'] ?? []),
      bodyText: map['bodyText'] ?? '',
      photoPaths: List<String>.from(map['photoPaths'] ?? []),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      isSent: map['isSent'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportModel.fromJson(String source) =>
      ReportModel.fromMap(json.decode(source));
}
