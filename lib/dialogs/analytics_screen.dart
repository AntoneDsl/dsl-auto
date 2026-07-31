// lib/dialogs/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const AnalyticsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Подсчитываем расходы по категориям
    double refuelTotal = 0;
    double washTotal = 0;
    double repairTotal = 0;
    double fineTotal = 0;

    for (var log in logs) {
      final price = double.tryParse(log['price'].toString()) ?? 0;
      final type = log['type'] ?? '';

      if (type == 'refuel' || log['title'].contains('Заправка')) {
        refuelTotal += price;
      } else if (type == 'wash' || log['title'].contains('Мойка')) {
        washTotal += price;
      } else if (type == 'repair' || log['title'].contains('Ремонт')) {
        repairTotal += price;
      } else {
        fineTotal += price;
      }
    }

    double totalExpense = refuelTotal + washTotal + repairTotal + fineTotal;

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E22),
        title: const Text('Аналитика расходов',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: totalExpense == 0
          ? const Center(
              child: Text('Записей о расходах пока нет',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Блок с общей суммой
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('Всего потрачено',
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          '${totalExpense.toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // КРУГОВАЯ ДИАГРАММА (PIE CHART)
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 50,
                        sections: [
                          if (refuelTotal > 0)
                            PieChartSectionData(
                              color: const Color(0xFFE53935),
                              value: refuelTotal,
                              title:
                                  '${((refuelTotal / totalExpense) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (washTotal > 0)
                            PieChartSectionData(
                              color: Colors.blueAccent,
                              value: washTotal,
                              title:
                                  '${((washTotal / totalExpense) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (repairTotal > 0)
                            PieChartSectionData(
                              color: Colors.purpleAccent,
                              value: repairTotal,
                              title:
                                  '${((repairTotal / totalExpense) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (fineTotal > 0)
                            PieChartSectionData(
                              color: Colors.amber,
                              value: fineTotal,
                              title:
                                  '${((fineTotal / totalExpense) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // РАСШИФРОВКА ПО КАТЕГОРИЯМ
                  _buildCategoryRow('Заправка', refuelTotal,
                      const Color(0xFFE53935), Icons.local_gas_station),
                  _buildCategoryRow('Мойка', washTotal, Colors.blueAccent,
                      Icons.local_car_wash),
                  _buildCategoryRow('Ремонт / ТО', repairTotal,
                      Colors.purpleAccent, Icons.build),
                  _buildCategoryRow(
                      'Штрафы / Прочее', fineTotal, Colors.amber, Icons.gavel),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryRow(
      String title, double amount, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const Spacer(),
          Text(
            '${amount.toStringAsFixed(0)} ₽',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
