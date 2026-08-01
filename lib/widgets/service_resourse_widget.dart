import 'package:flutter/material.dart';

class ServiceResourceWidget extends StatefulWidget {
  final int currentMileage;

  const ServiceResourceWidget({
    super.key,
    required this.currentMileage,
  });

  @override
  State<ServiceResourceWidget> createState() => _ServiceResourceWidgetState();
}

class _ServiceResourceWidgetState extends State<ServiceResourceWidget> {
  // Интервалы (через сколько км менять)
  int oilInterval = 10000;
  int brakeInterval = 30000;
  int serviceInterval = 15000;

  // Пробег, на котором ПОСЛЕДНИЙ РАЗ меняли деталь
  int lastOilChangeKm = 0;
  int lastBrakeChangeKm = 0;
  int lastServiceChangeKm = 0;

  void _resetResource(String title, Function onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E22),
        title:
            Text('Замена: $title', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Сбросить отсчет для "$title" на текущий пробег (${widget.currentMileage} км)?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() {
                onConfirm();
              });
              Navigator.pop(context);
            },
            child: const Text('Да, заменил',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final oilController = TextEditingController(text: oilInterval.toString());
    final brakeController =
        TextEditingController(text: brakeInterval.toString());
    final serviceController =
        TextEditingController(text: serviceInterval.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E22),
        title: const Text('Интервалы замены (км)',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField('Моторное масло', oilController),
              const SizedBox(height: 10),
              _buildInputField('Тормозные колодки', brakeController),
              const SizedBox(height: 10),
              _buildInputField('Плановое ТО', serviceController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              setState(() {
                oilInterval = int.tryParse(oilController.text) ?? oilInterval;
                brakeInterval =
                    int.tryParse(brakeController.text) ?? brakeInterval;
                serviceInterval =
                    int.tryParse(serviceController.text) ?? serviceInterval;
              });
              Navigator.pop(context);
            },
            child:
                const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Сколько проехали с момента ПОСЛЕДНЕЙ замены
    int oilPassed = widget.currentMileage - lastOilChangeKm;
    int brakePassed = widget.currentMileage - lastBrakeChangeKm;
    int servicePassed = widget.currentMileage - lastServiceChangeKm;

    if (oilPassed < 0) oilPassed = 0;
    if (brakePassed < 0) brakePassed = 0;
    if (servicePassed < 0) servicePassed = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ресурс расходников',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey, size: 20),
                onPressed: _showSettingsDialog,
                tooltip: 'Настроить интервалы',
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildResourceProgress(
            title: 'Моторное масло',
            passedKm: oilPassed,
            totalKm: oilInterval,
            icon: Icons.oil_barrel,
            color: Colors.amber,
            onReset: () => _resetResource('Моторное масло',
                () => lastOilChangeKm = widget.currentMileage),
          ),
          const SizedBox(height: 14),
          _buildResourceProgress(
            title: 'Тормозные колодки',
            passedKm: brakePassed,
            totalKm: brakeInterval,
            icon: Icons.minor_crash,
            color: Colors.redAccent,
            onReset: () => _resetResource('Тормозные колодки',
                () => lastBrakeChangeKm = widget.currentMileage),
          ),
          const SizedBox(height: 14),
          _buildResourceProgress(
            title: 'Плановое ТО',
            passedKm: servicePassed,
            totalKm: serviceInterval,
            icon: Icons.handyman,
            color: Colors.greenAccent,
            onReset: () => _resetResource('Плановое ТО',
                () => lastServiceChangeKm = widget.currentMileage),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceProgress({
    required String title,
    required int passedKm,
    required int totalKm,
    required IconData icon,
    required Color color,
    required VoidCallback onReset,
  }) {
    int remainingKm = totalKm - passedKm;
    if (remainingKm < 0) remainingKm = 0;

    double progress = (remainingKm / totalKm).clamp(0.0, 1.0);
    bool isCritical = progress < 0.1;

    Color activeColor = isCritical ? Colors.red : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: activeColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      isCritical
                          ? 'Замена! ($remainingKm км)'
                          : '$remainingKm км',
                      style: TextStyle(
                        color: isCritical ? Colors.redAccent : Colors.grey,
                        fontSize: 12,
                        fontWeight:
                            isCritical ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.refresh,
                        size: 14, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF2C2C30),
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      ],
    );
  }
}
