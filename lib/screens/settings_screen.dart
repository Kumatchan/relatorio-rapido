import 'package:flutter/material.dart';
import '../models/preset_model.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;

  const SettingsScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;
  List<EmailRecipientPreset> _emails = [];
  List<TitlePreset> _titles = [];

  final TextEditingController _technicianController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    setState(() {
      _settings = widget.storageService.getSettings();
      _technicianController.text = _settings.technicianName;
      _emails = widget.storageService.getEmails();
      _titles = widget.storageService.getTitles();
    });
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });
    await widget.storageService.saveSettings(newSettings);
  }

  void _showAddEmailDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo E-mail Pré-definido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Identificação (ex: Chefe, Equipe)',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail do Destinatário',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isNotEmpty) {
                await widget.storageService.addEmail(nameCtrl.text, emailCtrl.text);
                _loadAll();
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddTitleDialog() {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Título Pré-definido'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Título da Ocorrência / Relatório',
            hintText: 'Ex: Vistoria Elétrica',
            prefixIcon: Icon(Icons.label),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                await widget.storageService.addTitle(titleCtrl.text);
                _loadAll();
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações e Cadastros'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= SEÇÃO: QUALIDADE DAS FOTOS =================
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Qualidade e Compressão de Fotos',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fotos menores enviam mais rápido no 4G e não excedem o limite de e-mail.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<ImageQualityPreset>(
                    title: const Text('Baixa (Mais rápida)'),
                    subtitle: const Text('Até 1080px (~1MB cada). Ideal para sinal fraco.'),
                    value: ImageQualityPreset.baixa,
                    groupValue: _settings.imageQuality,
                    onChanged: (val) {
                      if (val != null) _updateSettings(_settings.copyWith(imageQuality: val));
                    },
                  ),
                  RadioListTile<ImageQualityPreset>(
                    title: const Text('Média (Recomendada)'),
                    subtitle: const Text('Até 1600px (~2MB cada). Boa nitidez e envio ágil.'),
                    value: ImageQualityPreset.media,
                    groupValue: _settings.imageQuality,
                    onChanged: (val) {
                      if (val != null) _updateSettings(_settings.copyWith(imageQuality: val));
                    },
                  ),
                  RadioListTile<ImageQualityPreset>(
                    title: const Text('Alta (Alta definição)'),
                    subtitle: const Text('Até 2048px (~3 a 4MB cada). Para detalhes minuciosos.'),
                    value: ImageQualityPreset.alta,
                    groupValue: _settings.imageQuality,
                    onChanged: (val) {
                      if (val != null) _updateSettings(_settings.copyWith(imageQuality: val));
                    },
                  ),
                  RadioListTile<ImageQualityPreset>(
                    title: const Text('Original (Sem compressão)'),
                    subtitle: const Text('Tamanho bruto direto da câmera (10MB+ cada).'),
                    value: ImageQualityPreset.original,
                    groupValue: _settings.imageQuality,
                    onChanged: (val) {
                      if (val != null) _updateSettings(_settings.copyWith(imageQuality: val));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ================= SEÇÃO: OPÇÕES DO CORPO DO E-MAIL =================
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_align_left, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Formatação Automática do E-mail',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Incluir Cabeçalho Formatado'),
                    subtitle: const Text('Adiciona título padronizado no topo da mensagem'),
                    value: _settings.includeHeader,
                    onChanged: (val) => _updateSettings(_settings.copyWith(includeHeader: val)),
                  ),
                  SwitchListTile(
                    title: const Text('Incluir Data e Hora'),
                    subtitle: const Text('Registra o momento em que o relatório foi montado'),
                    value: _settings.includeDateTime,
                    onChanged: (val) => _updateSettings(_settings.copyWith(includeDateTime: val)),
                  ),
                  SwitchListTile(
                    title: const Text('Incluir Nome do Responsável'),
                    value: _settings.includeTechnicianName,
                    onChanged: (val) => _updateSettings(_settings.copyWith(includeTechnicianName: val)),
                  ),
                  if (_settings.includeTechnicianName)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _technicianController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Técnico / Operador',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          _updateSettings(_settings.copyWith(technicianName: val));
                        },
                      ),
                    ),
                  SwitchListTile(
                    title: const Text('Limpar campos após envio'),
                    subtitle: const Text('Deixa o app pronto para o próximo relatório da rua'),
                    value: _settings.autoClearAfterSend,
                    onChanged: (val) => _updateSettings(_settings.copyWith(autoClearAfterSend: val)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ================= SEÇÃO: E-MAILS PRÉ-DEFINIDOS =================
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.contact_mail, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'E-mails Cadastrados',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        tooltip: 'Adicionar E-mail',
                        onPressed: _showAddEmailDialog,
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_emails.isEmpty)
                    const Text('Nenhum e-mail cadastrado.', style: TextStyle(color: Colors.grey)),
                  ..._emails.map((e) => ListTile(
                        dense: true,
                        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(e.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () async {
                            await widget.storageService.deleteEmail(e.id);
                            _loadAll();
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ================= SEÇÃO: TÍTULOS PRÉ-DEFINIDOS =================
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.label, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Títulos Cadastrados',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        tooltip: 'Adicionar Título',
                        onPressed: _showAddTitleDialog,
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_titles.isEmpty)
                    const Text('Nenhum título cadastrado.', style: TextStyle(color: Colors.grey)),
                  ..._titles.map((t) => ListTile(
                        dense: true,
                        title: Text(t.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () async {
                            await widget.storageService.deleteTitle(t.id);
                            _loadAll();
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
