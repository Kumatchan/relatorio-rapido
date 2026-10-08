import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_model.dart';
import '../services/email_service.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  final StorageService storageService;
  final EmailService emailService;

  const HistoryScreen({
    super.key,
    required this.storageService,
    required this.emailService,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ReportModel> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _history = widget.storageService.getHistory();
    });
  }

  void _deleteReport(String id) async {
    await widget.storageService.deleteHistoryItem(id);
    _loadHistory();
  }

  void _showReportDetails(ReportModel report) {
    final dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    report.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enviado em: ${dateFormat.format(report.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Divider(height: 24),
                  const Text('Destinatários:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: report.recipients
                        .map((email) => Chip(
                              label: Text(email, style: const TextStyle(fontSize: 12)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.bodyText.isEmpty ? '(Sem descrição)' : report.bodyText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (report.photoPaths.isNotEmpty) ...[
                    Text(
                      'Fotos Anexadas (${report.photoPaths.length}):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.photoPaths.length,
                        itemBuilder: (context, idx) {
                          final file = File(report.photoPaths[idx]);
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: file.existsSync()
                                  ? Image.file(file, fit: BoxFit.cover)
                                  : const Center(child: Icon(Icons.broken_image)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      final settings = widget.storageService.getSettings();
                      widget.emailService.sendReportEmail(
                        title: report.title,
                        recipients: report.recipients,
                        bodyText: report.bodyText,
                        photoPaths: report.photoPaths,
                        settings: settings,
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Reenviar Este Relatório'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Relatórios'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Limpar Histórico',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Limpar Histórico'),
                    content: const Text('Deseja realmente apagar todos os registros do histórico?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Limpar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await widget.storageService.clearHistory();
                  _loadHistory();
                }
              },
            ),
        ],
      ),
      body: _history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum relatório enviado ainda.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Os relatórios enviados na rua aparecerão aqui.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final report = _history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.assignment, color: Colors.blue.shade800),
                    ),
                    title: Text(
                      report.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${dateFormat.format(report.createdAt)} • ${report.photoPaths.length} foto(s)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        if (report.bodyText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              report.bodyText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'details') {
                          _showReportDetails(report);
                        } else if (val == 'delete') {
                          _deleteReport(report.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 18),
                              SizedBox(width: 8),
                              Text('Ver detalhes'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showReportDetails(report),
                  ),
                );
              },
            ),
    );
  }
}
