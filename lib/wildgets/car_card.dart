import 'dart:io';
import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const CarCard({
    Key? key,
    required this.car,
    required this.isActive,
    required this.onTap,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = car['name'] ?? 'Мой автомобиль';
    final String details = car['details'] ?? '';
    final String plate = car['plate'] ?? '';
    final String? imagePath = car['imagePath'];
    final mileage = car['mileage'] ?? 0;
    final String seasonTyre = car['seasonTyre'] ?? 'Летняя';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E22), // Тёмный стиль твоего приложения
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFFE53935) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото машины с плашками поверх
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imagePath != null && imagePath.isNotEmpty
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFF2C2C31),
                            child: const Icon(
                              Icons.directions_car_filled,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                    // Градиент для читаемости текста на фото
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black45, Colors.transparent],
                          stops: [0.0, 0.5],
                        ),
                      ),
                    ),
                    // Статус активности / Госномер сверху
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (plate.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                plate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE53935),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Активна',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Информация о машине
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (details.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            details,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.speed,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '$mileage км',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.ac_unit,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              seasonTyre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: onEdit,
                      tooltip: 'Редактировать',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
