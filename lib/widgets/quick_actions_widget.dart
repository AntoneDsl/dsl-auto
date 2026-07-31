import 'package:flutter/material.dart';
import '../dialogs/quick_action_dialogs.dart';
import '../dialogs/document_screen.dart';
import '../dialogs/analytics_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final Function(Map<String, dynamic>) onAddLog;
  final VoidCallback onOpenRefuel;

  const QuickActionsWidget({
    super.key,
    required this.logs,
    required this.onAddLog,
    required this.onOpenRefuel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // БЛОК 1: Быстрые операции
        const Text(
          'Быстрые операции',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionCard(
                title: 'Заправка',
                icon: Icons.local_gas_station,
                color: const Color(0xFFE53935),
                onTap: onOpenRefuel,
              ),
              const SizedBox(width: 10),
              _buildActionCard(
                title: 'Мойка',
                icon: Icons.local_car_wash,
                color: Colors.blueAccent,
                onTap: () => showAddWashDialog(context, onAddLog),
              ),
              const SizedBox(width: 10),
              _buildActionCard(
                title: 'Штрафы',
                icon: Icons.gavel,
                color: Colors.amber,
                onTap: () => showAddFineDialog(context, onAddLog),
              ),
              const SizedBox(width: 10),
              _buildActionCard(
                title: 'Документы',
                icon: Icons.folder_special,
                color: Colors.cyanAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              // 📊 Новая кнопка "Аналитика"
              _buildActionCard(
                title: 'Аналитика',
                icon: Icons.pie_chart,
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalyticsScreen(logs: logs),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // БЛОК 2: Обслуживание
        const Text(
          'Обслуживание',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildActionCard(
              title: 'Ремонт',
              icon: Icons.build,
              color: Colors.purpleAccent,
              onTap: () => showAddServiceDialog(context,
                  isRepair: true, onSave: onAddLog),
            ),
            const SizedBox(width: 10),
            _buildActionCard(
              title: 'Расходники',
              icon: Icons.oil_barrel,
              color: Colors.greenAccent,
              onTap: () => showAddServiceDialog(context,
                  isRepair: false, onSave: onAddLog),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
