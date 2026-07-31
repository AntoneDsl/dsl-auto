import 'package:flutter/material.dart';

/// Модель детали / расходника
class CarPart {
  String title;
  int remainingKm;
  int maxKm;
  String subtitle;
  IconData icon;
  Color color;

  CarPart({
    required this.title,
    required this.remainingKm,
    required this.maxKm,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// Модель автомобиля
class Car {
  String name;
  String details;
  String plate;
  double mileage;
  String? imagePath;
  String seasonTyre;

  Car({
    required this.name,
    required this.details,
    required this.plate,
    required this.mileage,
    this.imagePath,
    required this.seasonTyre,
  });
}
