import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/settings_model.dart';

class EmailService {
  String buildFormattedBody({
    required String title,
    required String rawBody,
    required AppSettings settings,
    required int photoCount,
  }) {
    final buffer = StringBuffer();

    if (settings.includeHeader) {
      buffer.writeln('📋 RELATÓRIO DE CAMPO: ${title.toUpperCase()}');
      buffer.writeln('=' * 40);
    }

    if (settings.includeDateTime) {
      final nowFormatted = DateFormat("dd/MM/yyyy 'às' HH:mm").format(DateTime.now());
      buffer.writeln('📅 Data e Hora: $nowFormatted');
    }

    if (settings.includeTechnicianName && settings.technicianName.isNotEmpty) {
      buffer.writeln('👤 Responsável: ${settings.technicianName}');
    }

    if (settings.includeHeader || settings.includeDateTime || settings.includeTechnicianName) {
      buffer.writeln('-' * 40);
    }

    buffer.writeln('\n📝 DESCRIÇÃO / OCORRÊNCIA:');
    buffer.writeln(rawBody.trim().isEmpty ? '(Nenhuma observação informada)' : rawBody.trim());
    buffer.writeln('');

    if (photoCount > 0) {
      buffer.writeln('-' * 40);
      buffer.writeln('📸 Anexos: $photoCount foto(s) anexada(s) a este e-mail.');
    }

    buffer.writeln('\n--');
    buffer.writeln('Enviado pelo aplicativo Relatório Rápido');

    return buffer.toString();
  }

  Future<bool> sendReportEmail({
    required String title,
    required List<String> recipients,
    required String bodyText,
    required List<String> photoPaths,
    required AppSettings settings,
  }) async {
    final emailSubject = title.trim().isNotEmpty
        ? '[$title] Relatório de Campo'
        : 'Relatório de Campo';

    final formattedBody = buildFormattedBody(
      title: title,
      rawBody: bodyText,
      settings: settings,
      photoCount: photoPaths.length,
    );

    try {
      final Email email = Email(
        body: formattedBody,
        subject: emailSubject,
        recipients: recipients,
        attachmentPaths: photoPaths,
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      return true;
    } catch (e) {
      debugPrint('Tentando fallback via SharePlus devido a: $e');
      try {
        final List<XFile> xFiles = photoPaths.map((path) => XFile(path)).toList();
        if (xFiles.isNotEmpty) {
          await Share.shareXFiles(
            xFiles,
            text: formattedBody,
            subject: emailSubject,
          );
        } else {
          await Share.share(
            formattedBody,
            subject: emailSubject,
          );
        }
        return true;
      } catch (fallbackError) {
        debugPrint('Erro no fallback de compartilhamento: $fallbackError');
        return false;
      }
    }
  }
}
