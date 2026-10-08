import 'dart:convert';

enum ImageQualityPreset { baixa, media, alta, original }

class AppSettings {
  final ImageQualityPreset imageQuality;
  final bool includeHeader;
  final bool includeDateTime;
  final bool includeTechnicianName;
  final String technicianName;
  final bool autoClearAfterSend;

  AppSettings({
    this.imageQuality = ImageQualityPreset.media,
    this.includeHeader = true,
    this.includeDateTime = true,
    this.includeTechnicianName = true,
    this.technicianName = 'Operador de Campo',
    this.autoClearAfterSend = true,
  });

  AppSettings copyWith({
    ImageQualityPreset? imageQuality,
    bool? includeHeader,
    bool? includeDateTime,
    bool? includeTechnicianName,
    String? technicianName,
    bool? autoClearAfterSend,
  }) {
    return AppSettings(
      imageQuality: imageQuality ?? this.imageQuality,
      includeHeader: includeHeader ?? this.includeHeader,
      includeDateTime: includeDateTime ?? this.includeDateTime,
      includeTechnicianName: includeTechnicianName ?? this.includeTechnicianName,
      technicianName: technicianName ?? this.technicianName,
      autoClearAfterSend: autoClearAfterSend ?? this.autoClearAfterSend,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageQuality': imageQuality.name,
      'includeHeader': includeHeader,
      'includeDateTime': includeDateTime,
      'includeTechnicianName': includeTechnicianName,
      'technicianName': technicianName,
      'autoClearAfterSend': autoClearAfterSend,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    ImageQualityPreset quality;
    try {
      quality = ImageQualityPreset.values.byName(map['imageQuality'] ?? 'media');
    } catch (_) {
      quality = ImageQualityPreset.media;
    }

    return AppSettings(
      imageQuality: quality,
      includeHeader: map['includeHeader'] ?? true,
      includeDateTime: map['includeDateTime'] ?? true,
      includeTechnicianName: map['includeTechnicianName'] ?? true,
      technicianName: map['technicianName'] ?? 'Operador de Campo',
      autoClearAfterSend: map['autoClearAfterSend'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(json.decode(source));
}
