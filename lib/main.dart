import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/email_service.dart';
import 'services/image_service.dart';
import 'services/speech_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final emailService = EmailService();
  final imageService = ImageService();
  final speechService = SpeechService();

  runApp(RelatorioRapidoApp(
    storageService: storageService,
    emailService: emailService,
    imageService: imageService,
    speechService: speechService,
  ));
}

class RelatorioRapidoApp extends StatelessWidget {
  final StorageService storageService;
  final EmailService emailService;
  final ImageService imageService;
  final SpeechService speechService;

  const RelatorioRapidoApp({
    super.key,
    required this.storageService,
    required this.emailService,
    required this.imageService,
    required this.speechService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relatório Rápido',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Colors.blueAccent,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: MainNavigationScaffold(
        storageService: storageService,
        emailService: emailService,
        imageService: imageService,
        speechService: speechService,
      ),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final StorageService storageService;
  final EmailService emailService;
  final ImageService imageService;
  final SpeechService speechService;

  const MainNavigationScaffold({
    super.key,
    required this.storageService,
    required this.emailService,
    required this.imageService,
    required this.speechService,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        storageService: widget.storageService,
        emailService: widget.emailService,
        imageService: widget.imageService,
        speechService: widget.speechService,
      ),
      HistoryScreen(
        storageService: widget.storageService,
        emailService: widget.emailService,
      ),
      SettingsScreen(
        storageService: widget.storageService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flash_on),
            selectedIcon: Icon(Icons.flash_on, color: Colors.blueAccent),
            label: 'Envio Rápido',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history, color: Colors.blueAccent),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings, color: Colors.blueAccent),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
