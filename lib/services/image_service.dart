import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import '../models/settings_model.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      return photo?.path;
    } catch (e) {
      debugPrint('Erro ao capturar foto da câmera: $e');
      return null;
    }
  }

  Future<List<String>> pickGalleryImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      return images.map((img) => img.path).toList();
    } catch (e) {
      debugPrint('Erro ao selecionar fotos da galeria: $e');
      return [];
    }
  }

  Future<List<String>> processImages(
    List<String> rawPaths,
    ImageQualityPreset qualityPreset,
  ) async {
    if (qualityPreset == ImageQualityPreset.original) {
      return rawPaths;
    }

    final int targetWidth;
    final int jpegQuality;

    switch (qualityPreset) {
      case ImageQualityPreset.baixa:
        targetWidth = 1080;
        jpegQuality = 65;
        break;
      case ImageQualityPreset.media:
        targetWidth = 1600;
        jpegQuality = 75;
        break;
      case ImageQualityPreset.alta:
        targetWidth = 2048;
        jpegQuality = 85;
        break;
      case ImageQualityPreset.original:
        return rawPaths;
    }

    final cacheDir = await getTemporaryDirectory();
    final List<String> processedPaths = [];

    for (int i = 0; i < rawPaths.length; i++) {
      final path = rawPaths[i];
      final file = File(path);
      if (!await file.exists()) continue;

      try {
        final bytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        if (decodedImage == null) {
          processedPaths.add(path);
          continue;
        }

        // Redimensiona proporcionalmente apenas se a imagem for maior que o alvo
        img.Image resizedImage = decodedImage;
        if (decodedImage.width > targetWidth || decodedImage.height > targetWidth) {
          if (decodedImage.width >= decodedImage.height) {
            resizedImage = img.copyResize(decodedImage, width: targetWidth);
          } else {
            resizedImage = img.copyResize(decodedImage, height: targetWidth);
          }
        }

        // Comprime para JPG
        final compressedBytes = img.encodeJpg(resizedImage, quality: jpegQuality);
        final fileName = 'relatorio_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final targetPath = p.join(cacheDir.path, fileName);
        final targetFile = File(targetPath);
        await targetFile.writeAsBytes(compressedBytes);

        processedPaths.add(targetPath);
      } catch (e) {
        debugPrint('Erro ao processar imagem $path: $e');
        processedPaths.add(path); // Fallback para imagem original
      }
    }

    return processedPaths;
  }
}
