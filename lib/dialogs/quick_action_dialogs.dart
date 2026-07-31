// lib/dialogs/quick_action_dialogs.dart
import 'package:flutter/material.dart';

// Диалог добавления Мойки
void showAddWashDialog(
    BuildContext context, Function(Map<String, dynamic>) onSave) {
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E22),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Добавить мойку',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Стоимость (грн)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C30),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Тип мойки (Комплекс, Экспресс)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C30),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                double? price = double.tryParse(priceController.text);
                if (price != null) {
                  onSave({
                    'title': notesController.text.isNotEmpty
                        ? 'Мойка: ${notesController.text}'
                        : 'Мойка авто',
                    'subtitle': 'Только что',
                    'price': '${price.toInt()} грн',
                    'category': 'Мойка',
                    'icon': Icons.local_car_wash,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить мойку',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

// Диалог добавления Штрафа
void showAddFineDialog(
    BuildContext context, Function(Map<String, dynamic>) onSave) {
  final priceController = TextEditingController();
  final reasonController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E22),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Добавить штраф',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Сумма штрафа (грн)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C30),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Причина (Превышение скорости)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C30),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                double? price = double.tryParse(priceController.text);
                if (price != null) {
                  onSave({
                    'title': reasonController.text.isNotEmpty
                        ? 'Штраф: ${reasonController.text}'
                        : 'Штраф ПДД',
                    'subtitle': 'Только что',
                    'price': '${price.toInt()} грн',
                    'category': 'Штрафы',
                    'icon': Icons.gavel,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить штраф',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

// Диалог Ремонта / Расходников
void showAddServiceDialog(BuildContext context,
    {required bool isRepair, required Function(Map<String, dynamic>) onSave}) {
  final titleController = TextEditingController();
  final priceController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E22),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRepair ? 'Добавить Ремонт' : 'Замена Расходников',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: isRepair
                  ? 'Наименование ремонта'
                  : 'Что заменено (Масло, фильтр)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C30),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Стоимость (грн)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C30),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRepair ? Colors.purpleAccent : Colors.greenAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                double? price = double.tryParse(priceController.text);
                if (price != null && titleController.text.isNotEmpty) {
                  onSave({
                    'title': titleController.text,
                    'subtitle': 'Только что',
                    'price': '${price.toInt()} грн',
                    'category': isRepair ? 'Ремонт' : 'Расходники',
                    'icon': isRepair ? Icons.build : Icons.oil_barrel,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Сохранить',
                  style: TextStyle(
                      color: isRepair ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}
