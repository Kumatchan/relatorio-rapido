# 🚀 Relatório Rápido — Aplicativo Android de Campo

Aplicativo desenvolvido sob medida para profissionais que trabalham na rua (vistorias, obras, entregas, fiscalizações e suporte técnico) e precisam registrar fotos, ditar observações por voz e enviar relatórios completos por e-mail com a máxima agilidade e praticidade.

---

## 📱 Principais Funcionalidades

1. **Captura Rápida de Fotos:**
   - Suporte a múltiplas fotos por relatório.
   - Captura instantânea direto pela Câmera ou seleção de fotos da Galeria.
   - Miniaturas visuais com opção de remover foto com 1 toque.

2. **Compressão Configurável de Fotos (Otimizada para 4G):**
   - **Baixa:** (~1080px, ~1MB por foto) — Ideal para áreas com sinal 3G/4G fraco.
   - **Média:** (~1600px, ~2MB por foto) — Balanceada (boa nitidez e envio ágil).
   - **Alta:** (~2048px, ~3-4MB por foto) — Alta definição para detalhes minuciosos.
   - **Original:** Mantém o tamanho bruto da câmera.
   - *Evita o limite de 25MB de anexos do Gmail e garante envio ultra rápido.*

3. **E-mails e Títulos Pré-definidos com Seleção em 1 Toque:**
   - **Chips/Pílulas Visuais:** Toque nos contatos desejados para incluir (suporta múltiplos destinatários).
   - **Títulos Rápidos:** Escolha títulos comuns com 1 toque ou digite um título avulso.
   - **Tela de Gerenciamento:** Adicione, edite ou exclua contatos e títulos a qualquer momento na aba de configurações.

4. **Transcrição por Voz em Tempo Real (Speech-to-Text):**
   - Botão de microfone dedicado.
   - Fale e o texto é preenchido instantaneamente no campo de descrição em Português (pt-BR).
   - Pode pausar, falar novamente para acrescentar texto e corrigir ou complementar pelo teclado.

5. **Envio Direto pelo App de E-mail Padrão (Gmail / Outlook):**
   - Abre o aplicativo de e-mail já com **destinatários**, **título**, **corpo estruturado** e **todas as fotos anexadas**.
   - O operador apenas confere em 1 segundo e toca em "Enviar".
   - Não requer senhas de e-mail ou servidores SMTP dentro do aplicativo.

6. **Opções Rápidas de Cabeçalho e Metadados:**
   - Interruptores rápidos para ativar/desativar:
     - Cabeçalho padronizado (`📋 RELATÓRIO DE CAMPO`)
     - Data e Hora automática
     - Nome do Responsável / Técnico
   - Limpeza automática da tela após o envio para o próximo trabalho começar limpo.

7. **Histórico Local e Rascunho Automático:**
   - Salva rascunho em tempo real: se o app for fechado na rua, nada é perdido.
   - Histórico completo de relatórios enviados com visualização das fotos, texto e opção de reenvio.

---

## 📂 Estrutura do Projeto

```
relatorio_rapido/
├── android/                   # Configurações do Android nativo e permissões
│   └── app/src/main/
│       └── AndroidManifest.xml # Permissões de câmera, microfone e e-mail
├── lib/
│   ├── main.dart              # Inicialização e navegação por abas
│   ├── models/
│   │   ├── preset_model.dart  # Modelos de Títulos e E-mails salvos
│   │   ├── report_model.dart  # Modelo de dados do Relatório
│   │   └── settings_model.dart# Configurações de qualidade e cabeçalho
│   ├── services/
│   │   ├── email_service.dart # Formatação e disparo do e-mail com anexos
│   │   ├── image_service.dart # Câmera, galeria e compressão de imagens
│   │   ├── speech_service.dart# Transcrição por voz (Speech-to-Text)
│   │   └── storage_service.dart# Persistência local (SharedPreferences/cache)
│   └── screens/
│       ├── home_screen.dart   # Tela de envio rápido de campo
│       ├── history_screen.dart# Consulta e reenvio de relatórios
│       └── settings_screen.dart# Gerenciador de e-mails, títulos e opções
└── pubspec.yaml               # Dependências do Flutter
```

---

## 🛠️ Como Compilar e Gerar o APK para o Celular

Consulte o arquivo [INSTRUCOES_COMPILACAO.md](INSTRUCOES_COMPILACAO.md) para o passo a passo completo de como instalar o Flutter SDK, compilar o arquivo `.apk` e instalar no seu smartphone Android.
