// lib/dialogs/document_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Локальные пути к фото для каждого документа
  String? _driverLicensePath;
  String? _techPassportPath;
  String? _insurancePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedDocuments(); // Загружаем фото из памяти при открытии
  }

  // Загрузка путей к картинкам из памяти устройства
  Future<void> _loadSavedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _driverLicensePath = prefs.getString('doc_driver_license');
      _techPassportPath = prefs.getString('doc_tech_passport');
      _insurancePath = prefs.getString('doc_insurance');
    });
  }

  // Выбор фото из галереи и его сохранение в память
  Future<void> _pickImage(String docType) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (docType == 'license') {
          _driverLicensePath = image.path;
          prefs.setString('doc_driver_license', image.path);
        } else if (docType == 'tech') {
          _techPassportPath = image.path;
          prefs.setString('doc_tech_passport', image.path);
        } else if (docType == 'insurance') {
          _insurancePath = image.path;
          prefs.setString('doc_insurance', image.path);
        }
      });
    }
  }

  // Удаление фото документа из памяти
  Future<void> _removeImage(String docType) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (docType == 'license') {
        _driverLicensePath = null;
        prefs.remove('doc_driver_license');
      } else if (docType == 'tech') {
        _techPassportPath = null;
        prefs.remove('doc_tech_passport');
      } else if (docType == 'insurance') {
        _insurancePath = null;
        prefs.remove('doc_insurance');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E22),
        title: const Text('Документы авто',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDocCard(
            title: 'Водительское удостоверение',
            subtitle: 'Права',
            icon: Icons.badge,
            color: Colors.blueAccent,
            imagePath: _driverLicensePath,
            onTap: () => _pickImage('license'),
            onRemove: () => _removeImage('license'),
          ),
          const SizedBox(height: 16),
          _buildDocCard(
            title: 'Технический паспорт',
            subtitle: 'Свидетельство о регистрации',
            icon: Icons.directions_car,
            color: Colors.amber,
            imagePath: _techPassportPath,
            onTap: () => _pickImage('tech'),
            onRemove: () => _removeImage('tech'),
          ),
          const SizedBox(height: 16),
          _buildDocCard(
            title: 'Страховой полис',
            subtitle: 'ОСАГО / КАСКО',
            icon: Icons.security,
            color: Colors.greenAccent,
            imagePath: _insurancePath,
            onTap: () => _pickImage('insurance'),
            onRemove: () => _removeImage('insurance'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String? imagePath,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            title: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: onRemove,
                  ),
                IconButton(
                  icon: Icon(imagePath == null ? Icons.add_a_photo : Icons.edit,
                      color: Colors.white70),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
          if (imagePath != null && File(imagePath).existsSync())
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
