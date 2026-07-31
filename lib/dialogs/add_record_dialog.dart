import 'package:flutter/material.dart';

class AddRecordDialog extends StatefulWidget {
  final Function(Map<String, dynamic> recordData) onSave;

  const AddRecordDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  String selectedCategory = 'ТО и ремонт';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добавить запись о сервисе',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Название работы / детали',
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Стоимость (грн)',
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (title.isNotEmpty) {
                final recordData = {
                  'title': title,
                  'price': price,
                  'category': selectedCategory,
                  'date': DateTime.now().toString(),
                };
                widget.onSave(recordData);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
