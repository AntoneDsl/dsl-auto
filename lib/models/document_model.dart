// lib/models/document_model.dart
class AutoDocument {
  final String id;
  final String title; // Права, Техпаспорт, Страховка
  final String? docNumber; // Номер документа
  final String? imagePath; // Путь к фото документа
  final DateTime? expiryDate; // Дата окончания (особенно для страховки)

  AutoDocument({
    required this.id,
    required this.title,
    this.docNumber,
    this.imagePath,
    this.expiryDate,
  });
}
