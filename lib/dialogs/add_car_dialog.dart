import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddCarDialog extends StatefulWidget {
  final Map<String, dynamic>? carToEdit;
  final int? editIndex;
  final Function(Map<String, dynamic> carData) onSave;

  const AddCarDialog({
    super.key,
    this.carToEdit,
    this.editIndex,
    required this.onSave,
  });

  @override
  State<AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  late TextEditingController brandController;
  late TextEditingController yearController;
  late TextEditingController engineController;
  late TextEditingController plateController;
  late TextEditingController mileageController;

  late String tempSeasonTyre;
  String? tempImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final carToEdit = widget.carToEdit;

    brandController = TextEditingController(text: carToEdit?['name'] ?? '');
    yearController = TextEditingController(
      text: carToEdit != null && carToEdit['details'].toString().contains(' • ')
          ? carToEdit['details'].toString().split(' • ')[0]
          : '',
    );
    engineController = TextEditingController(
      text: carToEdit != null && carToEdit['details'].toString().contains(' • ')
          ? carToEdit['details']
              .toString()
              .substring(carToEdit['details'].toString().indexOf(' • ') + 3)
          : '',
    );
    plateController = TextEditingController(text: carToEdit?['plate'] ?? '');
    mileageController = TextEditingController(
      text: carToEdit?['mileage']?.toInt().toString() ?? '',
    );
    tempSeasonTyre = carToEdit?['seasonTyre'] ?? 'Летняя резина';
    tempImagePath = carToEdit?['imagePath'];
  }

  @override
  void dispose() {
    brandController.dispose();
    yearController.dispose();
    engineController.dispose();
    plateController.dispose();
    mileageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        tempImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.carToEdit != null ? 'Редактировать авто' : 'Добавить авто',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Выбор фото машины
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                    image: tempImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(tempImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: tempImagePath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: Colors.white54, size: 32),
                            SizedBox(height: 6),
                            Text(
                              'Нажмите, чтобы добавить фото',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: brandController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Марка и модель (напр. BMW X5)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Год выпуска',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: engineController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Двигатель (напр. 3.0 D)',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: plateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Гос. номер',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Пробег (км)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),

            // Выбор типа резины
            const Text(
              'Тип резины:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Летняя резина', 'Зимняя резина', 'Всесезонная']
                  .map((season) {
                final isSelected = tempSeasonTyre == season;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => tempSeasonTyre = season),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.redAccent.withOpacity(0.2)
                            : const Color(0xFF2A2A2E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.redAccent
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        season.split(' ')[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.redAccent : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newCar = {
                  'name': brandController.text.trim(),
                  'details':
                      '${yearController.text.trim()} • ${engineController.text.trim()}',
                  'plate': plateController.text.trim(),
                  'mileage':
                      double.tryParse(mileageController.text.trim()) ?? 0.0,
                  'seasonTyre': tempSeasonTyre,
                  'imagePath': tempImagePath,
                };
                widget.onSave(newCar);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.carToEdit != null ? 'Сохранить изменения' : 'Добавить',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
