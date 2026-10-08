import 'dart:io';
import 'package:flutter/material.dart';
import '../models/preset_model.dart';
import '../models/report_model.dart';
import '../models/settings_model.dart';
import '../services/email_service.dart';
import '../services/image_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final EmailService emailService;
  final ImageService imageService;
  final SpeechService speechService;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.emailService,
    required this.imageService,
    required this.speechService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  List<String> _selectedPhotos = [];
  final Set<String> _selectedEmails = {};
  String? _selectedTitlePreset;

  bool _isListening = false;
  bool _isProcessing = false;
  late AppSettings _settings;
  List<TitlePreset> _titlePresets = [];
  List<EmailRecipientPreset> _emailPresets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _settings = widget.storageService.getSettings();
      _titlePresets = widget.storageService.getTitles();
      _emailPresets = widget.storageService.getEmails();

      // Pré-seleciona o primeiro e-mail se nada estiver selecionado
      if (_selectedEmails.isEmpty && _emailPresets.isNotEmpty) {
        _selectedEmails.add(_emailPresets.first.email);
      }

      // Pré-seleciona o primeiro título se o campo estiver vazio
      if (_selectedTitlePreset == null && _titlePresets.isNotEmpty && _titleController.text.isEmpty) {
        _selectedTitlePreset = _titlePresets.first.title;
        _titleController.text = _titlePresets.first.title;
      }
    });

    _restoreDraftIfNeeded();
  }

  void _restoreDraftIfNeeded() {
    final draft = widget.storageService.getDraft();
    if (draft != null) {
      setState(() {
        _titleController.text = draft.title;
        _textController.text = draft.bodyText;
        _selectedPhotos = List.from(draft.photoPaths);
        _selectedEmails.clear();
        _selectedEmails.addAll(draft.recipients);
      });
    }
  }

  void _saveCurrentDraft() {
    final draft = ReportModel(
      id: 'draft',
      title: _titleController.text,
      recipients: _selectedEmails.toList(),
      bodyText: _textController.text,
      photoPaths: _selectedPhotos,
      createdAt: DateTime.now(),
    );
    widget.storageService.saveDraft(draft);
  }

  Future<void> _takePhoto() async {
    final photoPath = await widget.imageService.takePhoto();
    if (photoPath != null) {
      setState(() {
        _selectedPhotos.add(photoPath);
      });
      _saveCurrentDraft();
    }
  }

  Future<void> _pickGallery() async {
    final photos = await widget.imageService.pickGalleryImages();
    if (photos.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(photos);
      });
      _saveCurrentDraft();
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
    _saveCurrentDraft();
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isListening) {
      await widget.speechService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      final initialText = _textController.text;
      final available = await widget.speechService.initSpeech();

      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microfone ou reconhecimento de voz indisponível.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      setState(() {
        _isListening = true;
      });

      await widget.speechService.startListening(
        onResult: (words) {
          setState(() {
            final separator = initialText.isEmpty || initialText.endsWith(' ') || initialText.endsWith('\n')
                ? ''
                : ' ';
            _textController.text = '$initialText$separator$words';
          });
          _saveCurrentDraft();
        },
        onDone: () {
          setState(() {
            _isListening = false;
          });
        },
      );
    }
  }

  Future<void> _sendReport() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ou digite um título para o relatório.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um destinatário para o e-mail.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Processa e comprime imagens conforme a qualidade configurada (baixa, média, alta, original)
      final processedPhotos = await widget.imageService.processImages(
        _selectedPhotos,
        _settings.imageQuality,
      );

      // 2. Salva no histórico local
      final report = ReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        recipients: _selectedEmails.toList(),
        bodyText: _textController.text.trim(),
        photoPaths: processedPhotos,
        createdAt: DateTime.now(),
        isSent: true,
      );
      await widget.storageService.addReportToHistory(report);

      // 3. Dispara abertura do e-mail com anexos
      final success = await widget.emailService.sendReportEmail(
        title: _titleController.text.trim(),
        recipients: _selectedEmails.toList(),
        bodyText: _textController.text.trim(),
        photoPaths: processedPhotos,
        settings: _settings,
      );

      if (success) {
        if (_settings.autoClearAfterSend) {
          await widget.storageService.clearDraft();
          setState(() {
            _selectedPhotos.clear();
            _textController.clear();
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relatório preparado e enviado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar relatório: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Relatório Rápido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar campos',
            onPressed: () {
              setState(() {
                _selectedPhotos.clear();
                _textController.clear();
              });
              widget.storageService.clearDraft();
            },
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Otimizando fotos e preparando e-mail...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- SEÇÃO 1: FOTOS ---
                  _buildPhotoSection(theme),
                  const SizedBox(height: 16),

                  // --- SEÇÃO 2: TÍTULO PRÉ-DEFINIDO ---
                  _buildTitleSection(theme),
                  const SizedBox(height: 16),

                  // --- SEÇÃO 3: DESTINATÁRIOS PRÉ-DEFINIDOS ---
                  _buildRecipientsSection(theme),
                  const SizedBox(height: 16),

                  // --- SEÇÃO 4: TRANSCRIÇÃO DE VOZ E DESCRIÇÃO ---
                  _buildDescriptionSection(theme),
                  const SizedBox(height: 16),

                  // --- SEÇÃO 5: CONFIGURAÇÕES RÁPIDAS DE CABEÇALHO ---
                  _buildQuickToggles(theme),
                  const SizedBox(height: 24),

                  // --- BOTÃO DE ENVIO RÁPIDO ---
                  _buildSubmitButton(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPhotoSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_camera_back, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Fotos da Ocorrência (${_selectedPhotos.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  'Qualidade: ${_settings.imageQuality.name.toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 105,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Botão Câmera
                  _buildActionPhotoCard(
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    onTap: _takePhoto,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 8),
                  // Botão Galeria
                  _buildActionPhotoCard(
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onTap: _pickGallery,
                    isPrimary: false,
                  ),
                  const SizedBox(width: 8),
                  // Lista de Miniaturas
                  ..._selectedPhotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final path = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPhotoCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 85,
        decoration: BoxDecoration(
          color: isPrimary ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey.shade700),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Título do Relatório',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Chips de títulos rápidos
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _titlePresets.map((preset) {
                final isSelected = _selectedTitlePreset == preset.title;
                return ChoiceChip(
                  label: Text(preset.title),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTitlePreset = preset.title;
                        _titleController.text = preset.title;
                      } else {
                        _selectedTitlePreset = null;
                      }
                    });
                    _saveCurrentDraft();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Ou digite um título personalizado...',
                isDense: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit, size: 18),
              ),
              onChanged: (_) => _saveCurrentDraft(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientsSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Enviar Para (${_selectedEmails.length} selecionado(s))',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _emailPresets.map((preset) {
                final isSelected = _selectedEmails.contains(preset.email);
                return FilterChip(
                  avatar: Icon(
                    isSelected ? Icons.check_circle : Icons.person_outline,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  label: Text(preset.name),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEmails.add(preset.email);
                      } else {
                        _selectedEmails.remove(preset.email);
                      }
                    });
                    _saveCurrentDraft();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic, color: _isListening ? Colors.red : theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      _isListening ? 'Gravando e Transcrevendo...' : 'Descrição e Observações',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isListening ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Botão de Microfone de Destaque
                ElevatedButton.icon(
                  onPressed: _toggleVoiceRecording,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic, size: 18),
                  label: Text(_isListening ? 'Parar' : 'Falar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : theme.colorScheme.primaryContainer,
                    foregroundColor: _isListening ? Colors.white : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Toque em "Falar" para ditar por voz ou digite o relatório aqui...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: _isListening ? Colors.red.withOpacity(0.05) : null,
              ),
              onChanged: (_) => _saveCurrentDraft(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToggles(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.tune),
        title: const Text('Opções Rápidas do Cabeçalho'),
        children: [
          SwitchListTile(
            title: const Text('Incluir Cabeçalho Formatado'),
            value: _settings.includeHeader,
            onChanged: (val) {
              setState(() {
                _settings = _settings.copyWith(includeHeader: val);
              });
              widget.storageService.saveSettings(_settings);
            },
          ),
          SwitchListTile(
            title: const Text('Incluir Data e Hora'),
            value: _settings.includeDateTime,
            onChanged: (val) {
              setState(() {
                _settings = _settings.copyWith(includeDateTime: val);
              });
              widget.storageService.saveSettings(_settings);
            },
          ),
          SwitchListTile(
            title: const Text('Incluir Nome do Responsável'),
            subtitle: Text(_settings.technicianName),
            value: _settings.includeTechnicianName,
            onChanged: (val) {
              setState(() {
                _settings = _settings.copyWith(includeTechnicianName: val);
              });
              widget.storageService.saveSettings(_settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _sendReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        icon: const Icon(Icons.send, size: 24),
        label: Text(
          'ENVIAR RELATÓRIO (${_selectedPhotos.length} foto(s) • ${_selectedEmails.length} e-mail(s))',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
