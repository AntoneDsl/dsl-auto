import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  String _userName = 'Александр';
  String _currentCarName = 'Audi A3';
  String _currentCarDetails = '2019 • 2.0 TDI • S tronic';
  String _currentCarPlate = 'KA 1234 AB';
  double _mileage = 145250;
  String? _currentCarImage;
  String _currentSeasonTyre = 'Летняя резина';

  List<Map<String, dynamic>> _cars = [
    {
      'name': 'Audi A3',
      'details': '2019 • 2.0 TDI • S tronic',
      'plate': 'KA 1234 AB',
      'mileage': 145250.0,
      'imagePath': null,
      'seasonTyre': 'Летняя резина',
    },
    {
      'name': 'Mazda CX-5',
      'details': '2021 • 2.5 SkyActiv-G • 6AT',
      'plate': 'KA 5678 CD',
      'mileage': 98500.0,
      'imagePath': null,
      'seasonTyre': 'Зимняя резина',
    },
  ];

  List<Map<String, dynamic>> _carParts = [
    {
      'title': 'Масло двигателя',
      'remainingKm': 500,
      'maxKm': 10000,
      'subtitle': 'требует замены',
      'icon': Icons.oil_barrel,
      'color': const Color(0xFFE53935),
      'history': [
        {'date': '15.06.2026', 'mileage': 142900, 'cost': '2 450 грн'}
      ]
    },
    {
      'title': 'Масло в АКПП',
      'remainingKm': 12000,
      'maxKm': 60000,
      'subtitle': 'норма',
      'icon': Icons.settings_applications,
      'color': Colors.green,
      'history': [],
    },
    {
      'title': 'Тормозная жидкость',
      'remainingKm': 15000,
      'maxKm': 40000,
      'subtitle': 'норма',
      'icon': Icons.opacity,
      'color': Colors.green,
      'history': [],
    },
    {
      'title': 'Свечи зажигания',
      'remainingKm': 18000,
      'maxKm': 30000,
      'subtitle': 'норма',
      'icon': Icons.flash_on,
      'color': Colors.green,
      'history': [],
    },
    {
      'title': 'Ремень / цепь ГРМ',
      'remainingKm': 35000,
      'maxKm': 90000,
      'subtitle': 'норма',
      'icon': Icons.all_inclusive,
      'color': Colors.green,
      'history': [],
    },
    {
      'title': 'Воздушный фильтр',
      'remainingKm': 8500,
      'maxKm': 15000,
      'subtitle': 'норма',
      'icon': Icons.air,
      'color': Colors.green,
      'history': [
        {'date': '10.01.2026', 'mileage': 130000, 'cost': '650 грн'}
      ]
    },
    {
      'title': 'Тормозные колодки',
      'remainingKm': 12000,
      'maxKm': 30000,
      'subtitle': 'износ 60%',
      'icon': Icons.settings_suggest,
      'color': Colors.orange,
      'history': [
        {'date': '20.09.2025', 'mileage': 120000, 'cost': '3 200 грн'}
      ]
    },
    {
      'title': 'Аккумулятор',
      'remainingKm': 40000,
      'maxKm': 50000,
      'subtitle': 'норма',
      'icon': Icons.battery_charging_full,
      'color': Colors.green,
      'history': [],
    },
  ];

  List<Map<String, dynamic>> _logs = [
    {
      'title': 'Замена масла и фильтра',
      'subtitle': '142 900 км • 15.06.2026',
      'price': '2 450 грн',
      'category': 'ТО и ремонт',
      'icon': Icons.build_circle
    },
    {
      'title': 'Заправка А95+',
      'subtitle': '143 500 км • 20.06.2026',
      'price': '1 850 грн',
      'category': 'Топливо',
      'icon': Icons.local_gas_station
    },
  ];

  List<Map<String, dynamic>> _refuels = [
    {
      'liters': 35.5,
      'price': 1850.0,
      'mileage': 143500.0,
      'date': '20.06.2026',
      'consumption': 8.2
    },
    {
      'liters': 40.0,
      'price': 2100.0,
      'mileage': 142800.0,
      'date': '10.06.2026',
      'consumption': 8.5
    },
  ];

  List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Замена масла двигателя',
      'deadline': 'Через 500 км',
      'isUrgent': true,
      'icon': Icons.oil_barrel,
      'progress': 0.95,
      'iconBgColor': const Color(0xFFE53935),
    },
    {
      'title': 'Сезонная замена шин',
      'deadline': 'Подготовка к зиме / лету',
      'isUrgent': false,
      'icon': Icons.tire_repair,
      'progress': null,
      'iconBgColor': Colors.orangeAccent,
    },
    {
      'title': 'Страховка ОСАГО',
      'deadline': '14.09.2026',
      'isUrgent': false,
      'icon': Icons.description,
      'progress': null,
      'iconBgColor': Colors.blueAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? _userName;
      _currentCarName = prefs.getString('current_car_name') ?? _currentCarName;
      _currentCarDetails =
          prefs.getString('current_car_details') ?? _currentCarDetails;
      _currentCarPlate =
          prefs.getString('current_car_plate') ?? _currentCarPlate;
      _mileage = prefs.getDouble('current_mileage') ?? _mileage;
      _currentCarImage = prefs.getString('current_car_image');
      _currentSeasonTyre =
          prefs.getString('current_season_tyre') ?? _currentSeasonTyre;

      String? carsString = prefs.getString('cars_list_data');
      if (carsString != null) {
        List decodedCars = jsonDecode(carsString);
        _cars = decodedCars.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      String? partsString = prefs.getString('car_parts_data');
      if (partsString != null) {
        List decodedParts = jsonDecode(partsString);
        _carParts = decodedParts.map((e) {
          var map = Map<String, dynamic>.from(e);
          map['icon'] = _getIconData(map['iconCode']);
          return map;
        }).toList();
      }

      String? logsString = prefs.getString('logs_data');
      if (logsString != null) {
        List decoded = jsonDecode(logsString);
        _logs = decoded.map((e) => Map<String, dynamic>.from(e)).map((log) {
          log['icon'] = _getIconData(log['iconCode']);
          return log;
        }).toList();
      }

      String? refuelsString = prefs.getString('refuels_data');
      if (refuelsString != null) {
        List decoded = jsonDecode(refuelsString);
        _refuels = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      String? remindersString = prefs.getString('reminders_data');
      if (remindersString != null) {
        List decoded = jsonDecode(remindersString);
        _reminders =
            decoded.map((e) => Map<String, dynamic>.from(e)).map((rem) {
          rem['icon'] = _getIconData(rem['iconCode']);
          return rem;
        }).toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('current_car_name', _currentCarName);
    await prefs.setString('current_car_details', _currentCarDetails);
    await prefs.setString('current_car_plate', _currentCarPlate);
    await prefs.setDouble('current_mileage', _mileage);
    await prefs.setString('current_season_tyre', _currentSeasonTyre);

    if (_currentCarImage != null) {
      await prefs.setString('current_car_image', _currentCarImage!);
    } else {
      await prefs.remove('current_car_image');
    }
    await prefs.setString('cars_list_data', jsonEncode(_cars));
    await prefs.setString('refuels_data', jsonEncode(_refuels));

    List serializedParts = _carParts.map((part) {
      var map = Map<String, dynamic>.from(part);
      map['iconCode'] = (part['icon'] as IconData).codePoint;
      map.remove('icon');
      return map;
    }).toList();
    await prefs.setString('car_parts_data', jsonEncode(serializedParts));

    List serializedLogs = _logs.map((log) {
      var map = Map<String, dynamic>.from(log);
      map['iconCode'] = (log['icon'] as IconData).codePoint;
      map.remove('icon');
      return map;
    }).toList();
    await prefs.setString('logs_data', jsonEncode(serializedLogs));

    List serializedReminders = _reminders.map((rem) {
      var map = Map<String, dynamic>.from(rem);
      map['iconCode'] = (rem['icon'] as IconData).codePoint;
      map.remove('icon');
      return map;
    }).toList();
    await prefs.setString('reminders_data', jsonEncode(serializedReminders));
  }

  IconData _getIconData(int? codePoint) {
    if (codePoint == null) return Icons.build;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  int get _totalExpenses {
    int total = 0;
    for (var log in _logs) {
      String cleanPrice =
          log['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      total += int.tryParse(cleanPrice) ?? 0;
    }
    return total;
  }

  void _applyMileageDelta(int mileageDiff) {
    if (mileageDiff <= 0) return;

    setState(() {
      for (var part in _carParts) {
        int rem = part['remainingKm'] - mileageDiff;
        if (rem < 0) rem = 0;
        part['remainingKm'] = rem;

        double max = (part['maxKm'] ?? 10000).toDouble();
        double ratio = rem / max;

        if (rem == 0) {
          part['subtitle'] = 'требует замены';
          part['color'] = const Color(0xFFE53935);
        } else if (ratio < 0.2) {
          part['subtitle'] = 'износ критический';
          part['color'] = const Color(0xFFE53935);
        } else if (ratio < 0.5) {
          part['subtitle'] = 'средний износ';
          part['color'] = Colors.orange;
        } else {
          part['subtitle'] = 'норма';
          part['color'] = Colors.green;
        }
      }
    });
  }

  void _toggleTyreSeason() {
    setState(() {
      _currentSeasonTyre = _currentSeasonTyre == 'Летняя резина'
          ? 'Зимняя резина'
          : 'Летняя резина';
      for (var car in _cars) {
        if (car['name'] == _currentCarName) {
          car['seasonTyre'] = _currentSeasonTyre;
        }
      }
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Установлена сезонность: $_currentSeasonTyre')));
  }

  // Центр уведомлений (модальное окно при нажатии на колокольчик)
  void _showNotificationsCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Центр уведомлений',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon:
                        const Icon(Icons.add_circle, color: Color(0xFFE53935)),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddReminderDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _reminders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('Нет активных уведомлений',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _reminders.length,
                        itemBuilder: (context, index) {
                          var rem = _reminders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C30),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: rem['isUrgent'] == true
                                    ? Colors.redAccent.withOpacity(0.6)
                                    : Colors.transparent,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (rem['iconBgColor'] ??
                                            const Color(0xFFE53935))
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                      rem['icon'] ?? Icons.notifications,
                                      color: rem['iconBgColor'] ??
                                          const Color(0xFFE53935),
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(rem['title'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(rem['deadline'],
                                          style: TextStyle(
                                              color: rem['isUrgent'] == true
                                                  ? Colors.redAccent
                                                  : Colors.grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.grey, size: 18),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showAddReminderDialog(
                                        reminderToEdit: rem, editIndex: index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline,
                                      color: Colors.green, size: 20),
                                  tooltip: 'Выполнено',
                                  onPressed: () {
                                    setState(() {
                                      _reminders.removeAt(index);
                                    });
                                    setModalState(() {});
                                    _saveData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Напоминание выполнено и удалено')));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
            const Text('Изменить имя профиля',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Ваше имя',
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
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      _userName = nameController.text;
                    });
                    _saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Имя профиля обновлено!')));
                  }
                },
                child: const Text('Сохранить',
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

  void _showTripCalculatorDialog() {
    final distanceController = TextEditingController();
    double avgConsumption =
        _refuels.isNotEmpty ? (_refuels.first['consumption'] ?? 8.5) : 8.5;
    final consumptionController =
        TextEditingController(text: avgConsumption.toString());

    double avgPricePerLiter = 52.0;
    if (_refuels.isNotEmpty) {
      double totalLiters = 0;
      double totalPrice = 0;
      for (var ref in _refuels) {
        totalLiters += (ref['liters'] ?? 0);
        totalPrice += (ref['price'] ?? 0);
      }
      if (totalLiters > 0) {
        avgPricePerLiter =
            double.parse((totalPrice / totalLiters).toStringAsFixed(1));
      }
    }
    final priceController =
        TextEditingController(text: avgPricePerLiter.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          double distance = double.tryParse(distanceController.text) ?? 0.0;
          double consumption =
              double.tryParse(consumptionController.text) ?? 8.5;
          double pricePerLiter = double.tryParse(priceController.text) ?? 52.0;

          double totalLitersNeeded = (distance * consumption) / 100;
          double totalCost = totalLitersNeeded * pricePerLiter;

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
                const Text('Калькулятор поездки',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: distanceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setModalState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Расстояние (км)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2C2C30),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: consumptionController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Расход (л/100км)',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2C2C30),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Цена за 1 л (грн)',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2C2C30),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Результат расчета поездки',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Топливо',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text('${totalLitersNeeded.toStringAsFixed(1)} л',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                              width: 1,
                              height: 25,
                              color: Colors.white.withOpacity(0.1)),
                          Column(
                            children: [
                              const Text('Стоимость',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text('${totalCost.toStringAsFixed(0)} грн',
                                  style: const TextStyle(
                                      color: Color(0xFFE53935),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Готово',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddReminderDialog(
      {Map<String, dynamic>? reminderToEdit, int? editIndex}) {
    final titleController =
        TextEditingController(text: reminderToEdit?['title'] ?? '');
    final deadlineController =
        TextEditingController(text: reminderToEdit?['deadline'] ?? '');
    bool isUrgent = reminderToEdit?['isUrgent'] ?? false;
    String reminderType =
        reminderToEdit != null && reminderToEdit['progress'] != null
            ? 'По пробегу'
            : 'По дате';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
              Text(
                  reminderToEdit == null
                      ? 'Новое напоминание / ТО'
                      : 'Редактировать напоминание',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Название (например, Замена масла, Страховка)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2C2C30),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: reminderType,
                dropdownColor: const Color(0xFF2C2C30),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Тип напоминания',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2C2C30),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: ['По пробегу', 'По дате']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setModalState(() => reminderType = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: reminderType == 'По пробегу'
                      ? 'Срок (например, Через 2000 км)'
                      : 'Дата (например, 14.09.2026)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2C2C30),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Срочно / Важно',
                    style: TextStyle(color: Colors.white)),
                value: isUrgent,
                activeColor: const Color(0xFFE53935),
                onChanged: (val) => setModalState(() => isUrgent = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (reminderToEdit != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          setState(() {
                            _reminders.removeAt(editIndex!);
                          });
                          _saveData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Напоминание удалено')));
                        },
                        child: const Text('Удалить',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (titleController.text.isNotEmpty &&
                            deadlineController.text.isNotEmpty) {
                          IconData icon = reminderType == 'По пробегу'
                              ? Icons.oil_barrel
                              : Icons.description;
                          Color iconBgColor = reminderType == 'По пробегу'
                              ? const Color(0xFFE53935)
                              : Colors.blueAccent;
                          double? progress =
                              reminderType == 'По пробегу' ? 0.75 : null;

                          setState(() {
                            if (reminderToEdit == null) {
                              _reminders.add({
                                'title': titleController.text,
                                'deadline': deadlineController.text,
                                'isUrgent': isUrgent,
                                'icon': icon,
                                'progress': progress,
                                'iconBgColor': iconBgColor,
                              });
                            } else {
                              _reminders[editIndex!] = {
                                'title': titleController.text,
                                'deadline': deadlineController.text,
                                'isUrgent': isUrgent,
                                'icon': icon,
                                'progress': progress,
                                'iconBgColor': iconBgColor,
                              };
                            }
                          });
                          _saveData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Напоминание сохранено!')));
                        }
                      },
                      child: const Text('Сохранить',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCarDialog({Map<String, dynamic>? carToEdit, int? editIndex}) {
    final brandController =
        TextEditingController(text: carToEdit?['name'] ?? '');
    final yearController = TextEditingController(
        text: carToEdit != null
            ? carToEdit['details'].toString().split(' • ')[0]
            : '');
    final engineController = TextEditingController(
        text: carToEdit != null &&
                carToEdit['details'].toString().contains(' • ')
            ? carToEdit['details']
                .toString()
                .substring(carToEdit['details'].toString().indexOf(' • ') + 3)
            : '');
    final plateController =
        TextEditingController(text: carToEdit?['plate'] ?? '');
    final mileageController = TextEditingController(
        text: carToEdit?['mileage']?.toInt().toString() ?? '');
    String tempSeasonTyre = carToEdit?['seasonTyre'] ?? 'Летняя резина';
    String? tempImagePath = carToEdit?['imagePath'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                    carToEdit == null
                        ? 'Добавить автомобиль'
                        : 'Редактировать авто',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setModalState(() {
                          tempImagePath = pickedFile.path;
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C30),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                        image: tempImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(tempImagePath!)),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: tempImagePath == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    color: Colors.grey, size: 30),
                                SizedBox(height: 4),
                                Text('Фото',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10)),
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
                  decoration: InputDecoration(
                    labelText: 'Марка и модель',
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
                  controller: yearController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Год выпуска',
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
                  controller: engineController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Двигатель / КПП',
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
                  controller: plateController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Гос. номер',
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
                  controller: mileageController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Текущий пробег (км)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2C2C30),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tempSeasonTyre,
                  dropdownColor: const Color(0xFF2C2C30),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Установленная резина',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2C2C30),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  items: ['Летняя резина', 'Зимняя резина']
                      .map((tyre) =>
                          DropdownMenuItem(value: tyre, child: Text(tyre)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => tempSeasonTyre = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (brandController.text.isNotEmpty &&
                          plateController.text.isNotEmpty) {
                        String carName = brandController.text;
                        String details =
                            '${yearController.text} • ${engineController.text}';
                        String plate = plateController.text.toUpperCase();
                        double mileage =
                            double.tryParse(mileageController.text) ?? 0.0;

                        setState(() {
                          if (carToEdit == null) {
                            _cars.add({
                              'name': carName,
                              'details': details,
                              'plate': plate,
                              'mileage': mileage,
                              'imagePath': tempImagePath,
                              'seasonTyre': tempSeasonTyre,
                            });
                            _currentCarName = carName;
                            _currentCarDetails = details;
                            _currentCarPlate = plate;
                            _mileage = mileage;
                            _currentCarImage = tempImagePath;
                            _currentSeasonTyre = tempSeasonTyre;
                          } else {
                            _cars[editIndex!] = {
                              'name': carName,
                              'details': details,
                              'plate': plate,
                              'mileage': mileage,
                              'imagePath': tempImagePath,
                              'seasonTyre': tempSeasonTyre,
                            };
                            if (_currentCarName == carToEdit['name']) {
                              _currentCarName = carName;
                              _currentCarDetails = details;
                              _currentCarPlate = plate;
                              _mileage = mileage;
                              _currentCarImage = tempImagePath;
                              _currentSeasonTyre = tempSeasonTyre;
                            }
                          }
                        });
                        _saveData();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(carToEdit == null
                                ? 'Автомобиль добавлен!'
                                : 'Изменения сохранены!')));
                      }
                    },
                    child: Text(
                        carToEdit == null ? 'Добавить в гараж' : 'Сохранить',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddRefuelDialog() {
    final litersController = TextEditingController();
    final priceController = TextEditingController();
    final mileageController =
        TextEditingController(text: _mileage.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
            const Text('Добавить заправку топлива',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: litersController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Количество литров (л)',
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
                labelText: 'Общая стоимость (грн)',
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
              controller: mileageController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Пробег при заправке (км)',
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
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  double? liters = double.tryParse(litersController.text);
                  double? price = double.tryParse(priceController.text);
                  double? newMileage = double.tryParse(mileageController.text);

                  if (liters != null && price != null && newMileage != null) {
                    int mileageDiff = (newMileage - _mileage).toInt();
                    if (mileageDiff > 0) {
                      _applyMileageDelta(mileageDiff);
                    }

                    double consumption = 8.5;
                    if (_refuels.isNotEmpty) {
                      double lastMileage = _refuels.first['mileage'];
                      double distance = newMileage - lastMileage;
                      if (distance > 0) {
                        consumption = double.parse(
                            ((liters * 100) / distance).toStringAsFixed(1));
                      }
                    }

                    setState(() {
                      _refuels.insert(0, {
                        'liters': liters,
                        'price': price,
                        'mileage': newMileage,
                        'date': 'Только что',
                        'consumption': consumption,
                      });
                      _logs.insert(0, {
                        'title': 'Заправка топливом ($liters л)',
                        'subtitle': '${newMileage.toInt()} км • Только что',
                        'price': '${price.toInt()} грн',
                        'category': 'Топливо',
                        'icon': Icons.local_gas_station,
                      });
                      _mileage = newMileage;
                    });
                    _saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Заправка добавлена! Расход: $consumption л/100км')));
                  }
                },
                child: const Text('Сохранить заправку',
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

  void _showAddRecordDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'ТО и ремонт';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
              const Text('Новая запись расходов',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Название работы или покупки',
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF2C2C30),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Категория',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2C2C30),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: ['ТО и ремонт', 'Топливо', 'Страховка', 'Мойка / Прочее']
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) =>
                    setModalState(() => selectedCategory = val!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        priceController.text.isNotEmpty) {
                      IconData catIcon = Icons.build_circle;
                      if (selectedCategory == 'Топливо')
                        catIcon = Icons.local_gas_station;
                      if (selectedCategory == 'Страховка')
                        catIcon = Icons.description;
                      if (selectedCategory == 'Мойка / Прочее')
                        catIcon = Icons.local_car_wash;

                      setState(() {
                        _logs.insert(0, {
                          'title': titleController.text,
                          'subtitle': '${_mileage.toInt()} км • Только что',
                          'price': '${priceController.text} грн',
                          'category': selectedCategory,
                          'icon': catIcon,
                        });
                      });
                      _saveData();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Запись добавлена!')));
                    }
                  },
                  child: const Text('Сохранить запись',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateMileageDialog() {
    final mileageController =
        TextEditingController(text: _mileage.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
            const Text('Обновить пробег автомобиля',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: mileageController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Текущий пробег (км)',
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
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  double? newMileage = double.tryParse(mileageController.text);
                  if (newMileage != null) {
                    int mileageDiff = (newMileage - _mileage).toInt();

                    setState(() {
                      _mileage = newMileage;
                      for (var car in _cars) {
                        if (car['name'] == _currentCarName) {
                          car['mileage'] = newMileage;
                        }
                      }
                    });

                    if (mileageDiff > 0) {
                      _applyMileageDelta(mileageDiff);
                    }

                    _saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Пробег обновлен: ${_mileage.toInt()} км (+$mileageDiff км)')));
                  }
                },
                child: const Text('Сохранить пробег',
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

  void _showPartDetailDialog(int index) {
    var part = _carParts[index];
    int remaining = part['remainingKm'];
    int maxKm = part['maxKm'] ?? 10000;
    double progress = 1.0 - (remaining / maxKm);
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    final costController = TextEditingController(text: '1500');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
              Row(
                children: [
                  Icon(part['icon'], color: part['color'], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(part['title'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Остаток ресурса:',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('$remaining км из $maxKm км',
                            style: TextStyle(
                                color: part['color'],
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black26,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(part['color']),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('История замен узла:',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: (part['history'] as List).isEmpty
                    ? const Center(
                        child: Text('Нет записей о замене',
                            style: TextStyle(color: Colors.grey, fontSize: 12)))
                    : ListView.builder(
                        itemCount: (part['history'] as List).length,
                        itemBuilder: (context, hIndex) {
                          var h = part['history'][hIndex];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFF2C2C30),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${h['mileage']} км • ${h['date']}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 11)),
                                Text(h['cost'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Стоимость новой замены (грн)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2C2C30),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    String costText = costController.text;
                    setState(() {
                      part['remainingKm'] = maxKm;
                      part['subtitle'] = 'норма';
                      part['color'] = Colors.green;
                      (part['history'] as List).insert(0, {
                        'date': 'Только что',
                        'mileage': _mileage.toInt(),
                        'cost': '$costText грн',
                      });

                      _logs.insert(0, {
                        'title': 'Замена: ${part['title']}',
                        'subtitle': '${_mileage.toInt()} км • Только что',
                        'price': '$costText грн',
                        'category': 'ТО и ремонт',
                        'icon': part['icon'],
                      });
                    });
                    _saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${part['title']} успешно заменен(а)!')));
                  },
                  child: const Text('Заменить сейчас (сбросить ресурс)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121214),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('DSL',
                    style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1)),
                SizedBox(width: 6),
                Text('AUTO',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1)),
              ],
            ),
            const Text('ТВОЙ АВТОМОБИЛЬ ПОД КОНТРОЛЕМ',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 8,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Color(0xFFE53935), shape: BoxShape.circle),
                    child: Text('${_reminders.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            onPressed: _showNotificationsCenter,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: _showAddRecordDialog,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1E22),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Главная', 0),
              _buildNavItem(Icons.directions_car, 'Гараж', 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.local_gas_station, 'Заправки', 2),
              _buildNavItem(Icons.bar_chart, 'Статистика', 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE53935),
        onPressed: _showAddRecordDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E22),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF121214)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE53935),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.edit, color: Colors.grey, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditProfileDialog();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Текущий авто: $_currentCarName',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text('Центр уведомлений',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showNotificationsCenter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.white),
            title:
                const Text('Мой гараж', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_gas_station, color: Colors.white),
            title: const Text('Учет заправок',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.white),
            title: const Text('Калькулятор поездки',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showTripCalculatorDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.white),
            title: const Text('Расходы и статистика',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
          ),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCarsTab();
      case 2:
        return _buildRefuelsTab();
      case 3:
        return _buildStatisticsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E22), Color(0xFF2C2C30)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_currentCarName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_currentCarDetails,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 11)),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text('Гараж',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: Colors.blue[800],
                                borderRadius: BorderRadius.circular(2)),
                            child: const Text('UA',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          Text(_currentCarPlate,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _toggleTyreSeason,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _currentSeasonTyre == 'Летняя резина'
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _currentSeasonTyre == 'Летняя резина'
                                ? Colors.amber
                                : Colors.blueAccent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentSeasonTyre == 'Летняя резина'
                                  ? Icons.wb_sunny
                                  : Icons.ac_unit,
                              size: 14,
                              color: _currentSeasonTyre == 'Летняя резина'
                                  ? Colors.amber
                                  : Colors.blueAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentSeasonTyre,
                              style: TextStyle(
                                color: _currentSeasonTyre == 'Летняя резина'
                                    ? Colors.amber
                                    : Colors.blueAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Center(
                    child: _currentCarImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_currentCarImage!),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          )
                        : Icon(Icons.directions_car,
                            size: 85, color: Colors.white.withOpacity(0.25)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Пробег',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('${_mileage.toStringAsFixed(0)} км',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showUpdateMileageDialog,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Изменить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Состояние автомобиля и узлы',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 135,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _carParts.length,
              itemBuilder: (context, index) {
                var part = _carParts[index];
                return GestureDetector(
                  onTap: () => _showPartDetailDialog(index),
                  child: Container(
                    width: 115,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(part['icon'], color: part['color'], size: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(part['title'],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${part['remainingKm']} км',
                                style: TextStyle(
                                    color: part['color'],
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(part['subtitle'],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 9),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Последние расходы',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () => setState(() => _currentIndex = 3),
                child: const Text('Все записи >',
                    style: TextStyle(color: Color(0xFFE53935), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._logs.take(3).map((log) => _buildLogItem(log)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Напоминания и ТО',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
                onPressed: () => _showAddReminderDialog(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._reminders.asMap().entries.map((entry) {
            int index = entry.key;
            var rem = entry.value;
            return buildReminderCard(
              icon: rem['icon'] ?? Icons.notifications,
              iconBgColor: rem['iconBgColor'] ?? const Color(0xFFE53935),
              title: rem['title'],
              subtitle: rem['deadline'],
              isUrgent: rem['isUrgent'] == true,
              progress: rem['progress'],
              onTap: () =>
                  _showAddReminderDialog(reminderToEdit: rem, editIndex: index),
            );
          }),
        ],
      ),
    );
  }

  Widget buildReminderCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isUrgent,
    double? progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent
                ? Colors.redAccent.withOpacity(0.8)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconBgColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isUrgent ? Colors.redAccent : Colors.grey[400],
                          fontSize: 14,
                          fontWeight:
                              isUrgent ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUrgent ? Colors.redAccent : Colors.blueAccent,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Мой гараж',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showAddCarDialog(),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Добавить авто',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._cars.asMap().entries.map((entry) {
          int index = entry.key;
          var car = entry.value;
          return Dismissible(
            key: Key(car['name'] + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _cars.removeAt(index);
                if (_currentCarName == car['name'] && _cars.isNotEmpty) {
                  _currentCarName = _cars[0]['name'];
                  _currentCarDetails = _cars[0]['details'];
                  _currentCarPlate = _cars[0]['plate'];
                  _mileage = _cars[0]['mileage'];
                  _currentCarImage = _cars[0]['imagePath'];
                  _currentSeasonTyre =
                      _cars[0]['seasonTyre'] ?? 'Летняя резина';
                }
              });
              _saveData();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Автомобиль удален из гаража')));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: car['name'] == _currentCarName
                      ? const Color(0xFFE53935)
                      : Colors.white.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (car['imagePath'] != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(car['imagePath']),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      color: Colors.blue[800],
                                      borderRadius: BorderRadius.circular(2)),
                                  child: const Text('UA',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 6),
                                Text(car['plate'],
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(car['seasonTyre'] ?? 'Летняя резина',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.grey, size: 20),
                            onPressed: () => _showAddCarDialog(
                                carToEdit: car, editIndex: index),
                          ),
                          if (car['name'] == _currentCarName)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE53935).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('Активный',
                                  style: TextStyle(
                                      color: Color(0xFFE53935),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(car['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(car['details'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Пробег: ${car['mileage'].toInt()} км',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: car['name'] == _currentCarName
                              ? Colors.grey[800]
                              : const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            _currentCarName = car['name'];
                            _currentCarDetails = car['details'];
                            _currentCarPlate = car['plate'];
                            _mileage = car['mileage'];
                            _currentCarImage = car['imagePath'];
                            _currentSeasonTyre =
                                car['seasonTyre'] ?? 'Летняя резина';
                            _currentIndex = 0;
                          });
                          _saveData();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Выбран автомобиль: ${car['name']}')));
                        },
                        child: Text(
                          car['name'] == _currentCarName
                              ? 'Выбрано'
                              : 'Выбрать',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRefuelsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Учет заправок',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.calculate,
                      color: Colors.white, size: 24),
                  tooltip: 'Калькулятор поездки',
                  onPressed: _showTripCalculatorDialog,
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _showAddRefuelDialog,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Заправить',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Средний расход',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                      _refuels.isNotEmpty
                          ? '${_refuels.first['consumption']} л/100км'
                          : '0 л',
                      style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                  width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
              Column(
                children: [
                  const Text('Всего заправок',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('${_refuels.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('История заправок',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_refuels.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('Нет записей о заправках',
                      style: TextStyle(color: Colors.grey)))),
        ..._refuels.map((ref) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF2C2C30),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.local_gas_station,
                        color: Color(0xFFE53935), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${ref['liters']} л • ${ref['price']} грн',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            'Пробег: ${ref['mileage'].toInt()} км | Расход: ${ref['consumption']} л/100км',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(ref['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Расходы и статистика',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
              onPressed: _showAddRecordDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: const Color(0xFF1E1E22),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Общие расходы за все время',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 6),
              Text('$_totalExpenses грн',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Янв', 40),
                  _buildBar('Фев', 30),
                  _buildBar('Мар', 45),
                  _buildBar('Апр', 45),
                  _buildBar('Май', 50),
                  _buildBar('Июн', 45),
                  _buildBar('Июл', 80, isRed: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('История всех затрат',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._logs.map((log) => _buildLogItem(log)),
      ],
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF2C2C30),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(log['icon'] ?? Icons.build,
                color: const Color(0xFFE53935), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(log['title'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(log['category'] ?? 'ТО',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 8)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(log['subtitle'],
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(log['price'],
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBar(String month, double height, {bool isRed = false}) {
    return Column(
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color:
                isRed ? const Color(0xFFE53935) : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(month, style: const TextStyle(color: Colors.grey, fontSize: 9)),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? const Color(0xFFE53935) : Colors.grey,
              size: 22),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: isSelected ? const Color(0xFFE53935) : Colors.grey,
                  fontSize: 9)),
        ],
      ),
    );
  }
}
