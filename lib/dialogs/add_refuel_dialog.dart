import 'package:flutter/material.dart';

class AddRefuelDialog extends StatefulWidget {
  final double currentMileage;
  final Function(Map<String, dynamic> refuelData) onSave;

  const AddRefuelDialog({
    super.key,
    required this.currentMileage,
    required this.onSave,
  });

  @override
  State<AddRefuelDialog> createState() => _AddRefuelDialogState();
}

class _AddRefuelDialogState extends State<AddRefuelDialog> {
  late TextEditingController litersController;
  late TextEditingController priceController;
  late TextEditingController mileageController;

  @override
  void initState() {
    super.initState();
    litersController = TextEditingController();
    priceController = TextEditingController();
    mileageController = TextEditingController(
      text: widget.currentMileage.toInt().toString(),
    );
  }

  @override
  void dispose() {
    litersController.dispose();
    priceController.dispose();
    mileageController.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добавить заправку топлива',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: litersController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Литры (л)',
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
          const SizedBox(height: 10),
          TextField(
            controller: mileageController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Пробег при заправке (км)',
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final liters =
                  double.tryParse(litersController.text.trim()) ?? 0.0;
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              final mileage = double.tryParse(mileageController.text.trim()) ??
                  widget.currentMileage;

              if (liters > 0 && price > 0) {
                final refuelData = {
                  'liters': liters,
                  'price': price,
                  'mileage': mileage,
                  'date': DateTime.now().toString(),
                };
                widget.onSave(refuelData);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
