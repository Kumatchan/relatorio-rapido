import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preset_model.dart';
import '../models/report_model.dart';
import '../models/settings_model.dart';

class StorageService {
  static const String _titlesKey = 'preset_titles';
  static const String _emailsKey = 'preset_emails';
  static const String _settingsKey = 'app_settings';
  static const String _historyKey = 'report_history';
  static const String _draftKey = 'current_draft';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDefaultsIfNeeded();
  }

  Future<void> _initDefaultsIfNeeded() async {
    // Títulos padrão iniciais se a lista estiver vazia
    if (!_prefs.containsKey(_titlesKey)) {
      final defaultTitles = [
        TitlePreset(id: '1', title: 'Vistoria de Campo'),
        TitlePreset(id: '2', title: 'Registro de Ocorrência'),
        TitlePreset(id: '3', title: 'Manutenção Concluída'),
        TitlePreset(id: '4', title: 'Entrega Realizada'),
        TitlePreset(id: '5', title: 'Avaria Identificada'),
      ];
      await saveTitles(defaultTitles);
    }

    // E-mails padrão iniciais se a lista estiver vazia
    if (!_prefs.containsKey(_emailsKey)) {
      final defaultEmails = [
        EmailRecipientPreset(id: '1', name: 'Coordenação / Supervisor', email: 'supervisor@empresa.com'),
        EmailRecipientPreset(id: '2', name: 'Central de Operações', email: 'operacoes@empresa.com'),
        EmailRecipientPreset(id: '3', name: 'Suporte Técnico', email: 'suporte@empresa.com'),
      ];
      await saveEmails(defaultEmails);
    }
  }

  // --- Títulos ---
  List<TitlePreset> getTitles() {
    final list = _prefs.getStringList(_titlesKey) ?? [];
    return list.map((item) => TitlePreset.fromJson(item)).toList();
  }

  Future<void> saveTitles(List<TitlePreset> titles) async {
    final list = titles.map((t) => t.toJson()).toList();
    await _prefs.setStringList(_titlesKey, list);
  }

  Future<void> addTitle(String title) async {
    final titles = getTitles();
    titles.add(TitlePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    ));
    await saveTitles(titles);
  }

  Future<void> deleteTitle(String id) async {
    final titles = getTitles();
    titles.removeWhere((t) => t.id == id);
    await saveTitles(titles);
  }

  // --- E-mails ---
  List<EmailRecipientPreset> getEmails() {
    final list = _prefs.getStringList(_emailsKey) ?? [];
    return list.map((item) => EmailRecipientPreset.fromJson(item)).toList();
  }

  Future<void> saveEmails(List<EmailRecipientPreset> emails) async {
    final list = emails.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_emailsKey, list);
  }

  Future<void> addEmail(String name, String email) async {
    final emails = getEmails();
    emails.add(EmailRecipientPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? email.trim() : name.trim(),
      email: email.trim(),
    ));
    await saveEmails(emails);
  }

  Future<void> deleteEmail(String id) async {
    final emails = getEmails();
    emails.removeWhere((e) => e.id == id);
    await saveEmails(emails);
  }

  // --- Configurações ---
  AppSettings getSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return AppSettings();
    try {
      return AppSettings.fromJson(raw);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, settings.toJson());
  }

  // --- Histórico ---
  List<ReportModel> getHistory() {
    final list = _prefs.getStringList(_historyKey) ?? [];
    return list.map((item) => ReportModel.fromJson(item)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addReportToHistory(ReportModel report) async {
    final history = getHistory();
    history.insert(0, report);
    // Limita o histórico local aos últimos 100 relatórios para economizar espaço
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    final list = history.map((r) => r.toJson()).toList();
    await _prefs.setStringList(_historyKey, list);
  }

  Future<void> deleteHistoryItem(String id) async {
    final history = getHistory();
    history.removeWhere((r) => r.id == id);
    final list = history.map((r) => r.toJson()).toList();
    await _prefs.setStringList(_historyKey, list);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  // --- Rascunho Atual ---
  ReportModel? getDraft() {
    final raw = _prefs.getString(_draftKey);
    if (raw == null) return null;
    try {
      return ReportModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(ReportModel draft) async {
    await _prefs.setString(_draftKey, draft.toJson());
  }

  Future<void> clearDraft() async {
    await _prefs.remove(_draftKey);
  }
}
