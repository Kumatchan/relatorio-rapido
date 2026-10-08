# 📦 Guia Passo a Passo: Como Compilar e Instalar o App no Celular Android

Este guia ensina como transformar o código-fonte deste projeto em um aplicativo instalável (**arquivo `.apk`**) para você colocar no seu celular Android.

---

## 1. Pré-requisitos no seu Computador (Windows)

Para compilar aplicativos Flutter para Android, você precisa ter duas ferramentas no Windows:

1. **Flutter SDK:**
   - Acesse o site oficial: [https://flutter.dev](https://flutter.dev) e baixe a versão para Windows.
   - Extraia a pasta `flutter` em `C:\src\flutter` (evite pastas com espaços ou permissões restritas).
   - Adicione o caminho `C:\src\flutter\bin` às suas **Variáveis de Ambiente** do Windows (`Path`).

2. **Android Studio (para o SDK do Android):**
   - Baixe e instale o [Android Studio](https://developer.android.com/studio).
   - Durante a instalação, certifique-se de marcar:
     - **Android SDK**
     - **Android SDK Command-line Tools**
     - **Android SDK Build-Tools**

3. **Verificar a Instalação:**
   - Abra o terminal (PowerShell ou Prompt de Comando) e digite:
     ```bash
     flutter doctor
     ```
   - O comando indicará se falta aceitar licenças do Android. Se pedir, execute:
     ```bash
     flutter doctor --android-licenses
     ```
     *(Pressione `y` para aceitar todas)*.

---

## 2. Como Abrir o Projeto

1. Abra o **VS Code** ou o **Android Studio**.
2. Clique em **File > Open Folder** (Abrir Pasta) e selecione:
   ```
   C:\Users\takay\.gemini\antigravity\scratch\relatorio_rapido
   ```
3. Abra o terminal integrado dentro da pasta do projeto e baixe as dependências executando:
   ```bash
   flutter pub get
   ```

---

## 3. Como Gerar o Arquivo Instalador (.APK)

Para gerar o arquivo que você pode instalar diretamente no seu celular:

1. No terminal da pasta do projeto, execute:
   ```bash
   flutter build apk --release
   ```
2. O Flutter compilará o aplicativo e criará o arquivo `.apk` final na seguinte pasta:
   ```
   build\app\outputs\flutter-apk\app-release.apk
   ```

---

## 4. Como Instalar no Celular Android

Existem duas formas fáceis:

### Método A: Enviar o arquivo APK para o celular (Mais prático)
1. Pegue o arquivo `app-release.apk` gerado e envie para você mesmo pelo **WhatsApp**, **Telegram** ou salve no **Google Drive**.
2. No celular Android, abra o arquivo baixado.
3. O Android perguntará se deseja permitir a instalação de fontes desconhecidas para aquele aplicativo. Toque em **Permitir / Continuar**.
4. Toque em **Instalar**.
5. Pronto! O ícone **Relatório Rápido** estará na tela inicial do seu celular.

### Método B: Conectar o celular no PC via USB
1. No seu celular Android, ative a **Depuração USB** (em *Configurações > Opções do Desenvolvedor > Depuração USB*).
2. Conecte o cabo USB no computador.
3. No terminal do projeto, execute:
   ```bash
   flutter run
   ```
   O app será instalado e abrirá diretamente no seu smartphone.

---

## 5. Dicas de Uso em Campo (Na Rua)

- **Permissões na primeira abertura:** Ao abrir pela primeira vez, o aplicativo solicitará permissão para usar a **Câmera**, o **Microfone** (para a voz) e o **Armazenamento**. Toque em "Permitir durante o uso do app".
- **Sem internet no momento:** Se você estiver em uma área sem sinal de internet ou 4G, pode tirar as fotos e ditar as notas normalmente. O relatório fica salvo no **Histórico Local** e você pode reenviá-lo assim que o sinal voltar.
- **Economia de Dados:** Mantenha a qualidade das fotos em **Baixa** ou **Média** na aba de Configurações para garantir envios instantâneos mesmo no 3G/4G da rua.
