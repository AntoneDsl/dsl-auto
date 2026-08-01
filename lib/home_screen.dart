import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'widgets/quick_actions_widget.dart';
import 'widgets/service_resourse_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSL AUTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121214),
        primaryColor: const Color(0xFFE53935),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Объявляем список вот здесь:
  List<Map<String, dynamic>> _myLogs = [];
  double _calculateCurrentMonthTotal() {
    final now = DateTime.now();
    double total = 0;

    // Убедись, что переменная со списком на главном экране называется logs
    // (или замени 'logs' на имя твоего списка, если оно отличается)
    for (var item in _myLogs) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;

      // Получаем дату из записи
      final dateField = item['date'];
      DateTime? itemDate;
      if (dateField is DateTime) {
        itemDate = dateField;
      } else if (dateField is String) {
        itemDate = DateTime.tryParse(dateField);
      }

      // Складываем только если запись относится к текущему году и месяцу
      if (itemDate != null &&
          itemDate.year == now.year &&
          itemDate.month == now.month) {
        total += price;
      }
    }

    return total;
  }

  String _userName = 'Антон';

  // Ключ для привязки данных к конкретному автомобилю в гараже
  String _activeCarId = 'default_car';

  String _currentCarName = 'Мой автомобиль';
  String _currentCarDetails = 'Добавьте параметры';
  String _currentCarPlate = 'AA 0000 AA';
  double _mileage = 0.0;
  String? _currentCarImage;
  String _currentSeasonTyre = 'Летняя резина';

  // Полис страхования (привязан к активному авто через сохранение)
  Map<String, dynamic> _insuranceData = {
    'company': 'ПЗУ Украина',
    'policyNumber': 'AA 1234567',
    'expiryDate': '2026-09-15',
  };

  List<Map<String, dynamic>> _cars = [];

  List<Map<String, dynamic>> _carParts = [
    {
      'title': 'Масло двигателя',
      'remainingKm': 0,
      'maxKm': 10000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.oil_barrel,
      'color': Colors.grey,
      'history': []
    },
    {
      'title': 'Масло в АКПП',
      'remainingKm': 0,
      'maxKm': 60000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.settings_applications,
      'color': Colors.grey,
      'history': [],
    },
    {
      'title': 'Тормозная жидкость',
      'remainingKm': 0,
      'maxKm': 40000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.opacity,
      'color': Colors.grey,
      'history': [],
    },
    {
      'title': 'Свечи зажигания',
      'remainingKm': 0,
      'maxKm': 30000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.flash_on,
      'color': Colors.grey,
      'history': [],
    },
    {
      'title': 'Ремень / цепь ГРМ',
      'remainingKm': 0,
      'maxKm': 90000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.all_inclusive,
      'color': Colors.grey,
      'history': [],
    },
    {
      'title': 'Воздушный фильтр',
      'remainingKm': 0,
      'maxKm': 15000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.air,
      'color': Colors.grey,
      'history': []
    },
    {
      'title': 'Тормозные колодки',
      'remainingKm': 0,
      'maxKm': 30000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.settings_suggest,
      'color': Colors.grey,
      'history': []
    },
    {
      'title': 'Аккумулятор',
      'remainingKm': 0,
      'maxKm': 50000,
      'subtitle': 'настройте ресурс',
      'icon': Icons.battery_charging_full,
      'color': Colors.grey,
      'history': [],
    },
  ];

  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _refuels = [];
  List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> _trips = []; // История поездок

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Загрузка общих данных и списка авто
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? _userName;
      _activeCarId = prefs.getString('active_car_id') ?? 'default_car';

      String? carsString = prefs.getString('cars_list_data');
      if (carsString != null) {
        List decodedCars = jsonDecode(carsString);
        _cars = decodedCars.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }); // Загружаем специфичные данные для активного автомобиля
    await _loadCarSpecificData(_activeCarId);
  }

  // Загрузка параметров конкретного авто (запчасти, логи, заправки, страховки)
  Future<void> _loadCarSpecificData(String carId) async {
    final prefs = await SharedPreferences.getInstance();

    // Если есть машины в гараже, подтягиваем параметры выбранной
    if (_cars.isNotEmpty) {
      var foundCar = _cars.firstWhere(
        (c) => c['id'] == carId,
        orElse: () => _cars.first,
      );
      _activeCarId = foundCar['id'] ?? 'default_car';
      _currentCarName = foundCar['name'] ?? 'Мой автомобиль';
      _currentCarDetails = foundCar['details'] ?? 'Добавьте параметры';
      _currentCarPlate = foundCar['plate'] ?? 'AA 0000 AA';
      _mileage = (foundCar['mileage'] as num?)?.toDouble() ?? 0.0;
      _currentCarImage = foundCar['imagePath'];
      _currentSeasonTyre = foundCar['seasonTyre'] ?? 'Летняя резина';
    }

    // Загрузка изолированных списков по префиксу авто
    String prefix = 'car_${_activeCarId}_';

    String? insuranceString = prefs.getString('${prefix}insurance_data');
    if (insuranceString != null) {
      _insuranceData = Map<String, dynamic>.from(jsonDecode(insuranceString));
    } else {
      _insuranceData = {
        'company': 'ПЗУ Украина',
        'policyNumber': 'AA 1234567',
        'expiryDate': '2026-09-15'
      };
    }

    String? partsString = prefs.getString('${prefix}car_parts_data');
    if (partsString != null) {
      List decodedParts = jsonDecode(partsString);
      _carParts = decodedParts.map((e) {
        var map = Map<String, dynamic>.from(e);
        map['icon'] = _getIconData(map['iconCode']);
        map['color'] =
            map['colorValue'] != null ? Color(map['colorValue']) : Colors.grey;
        return map;
      }).toList();
    } else {
      // Сброс на дефолтные значения если для авто еще не создавались
      _resetDefaultParts();
    }

    String? logsString = prefs.getString('${prefix}logs_data');
    if (logsString != null) {
      List decoded = jsonDecode(logsString);
      _logs = decoded.map((e) {
        var map = Map<String, dynamic>.from(e);
        map['icon'] = _getIconData(map['iconCode']);
        return map;
      }).toList();
    } else {
      _logs = [];
    }

    String? refuelsString = prefs.getString('${prefix}refuels_data');
    if (refuelsString != null) {
      List decoded = jsonDecode(refuelsString);
      _refuels = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _refuels = [];
    }

    String? remindersString = prefs.getString('${prefix}reminders_data');
    if (remindersString != null) {
      List decoded = jsonDecode(remindersString);
      _reminders = decoded.map((e) {
        var map = Map<String, dynamic>.from(e);
        map['icon'] = _getIconData(map['iconCode']);
        map['iconBgColor'] = map['iconBgColorValue'] != null
            ? Color(map['iconBgColorValue'])
            : const Color(0xFFE53935);
        return map;
      }).toList();
    } else {
      _reminders = [];
    }

    String? tripsString = prefs.getString('${prefix}trips_data');
    if (tripsString != null) {
      List decoded = jsonDecode(tripsString);
      _trips = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _trips = [];
    }

    setState(() {});
  }

  void _resetDefaultParts() {
    _carParts = [
      {
        'title': 'Масло двигателя',
        'remainingKm': 10000,
        'maxKm': 10000,
        'subtitle': 'норма',
        'icon': Icons.oil_barrel,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Масло в АКПП',
        'remainingKm': 60000,
        'maxKm': 60000,
        'subtitle': 'норма',
        'icon': Icons.settings_applications,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Тормозная жидкость',
        'remainingKm': 40000,
        'maxKm': 40000,
        'subtitle': 'норма',
        'icon': Icons.opacity,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Свечи зажигания',
        'remainingKm': 30000,
        'maxKm': 30000,
        'subtitle': 'норма',
        'icon': Icons.flash_on,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Ремень / цепь ГРМ',
        'remainingKm': 90000,
        'maxKm': 90000,
        'subtitle': 'норма',
        'icon': Icons.all_inclusive,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Воздушный фильтр',
        'remainingKm': 15000,
        'maxKm': 15000,
        'subtitle': 'норма',
        'icon': Icons.air,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Тормозные колодки',
        'remainingKm': 30000,
        'maxKm': 30000,
        'subtitle': 'норма',
        'icon': Icons.settings_suggest,
        'color': Colors.green,
        'history': []
      },
      {
        'title': 'Аккумулятор',
        'remainingKm': 50000,
        'maxKm': 50000,
        'subtitle': 'норма',
        'icon': Icons.battery_charging_full,
        'color': Colors.green,
        'history': []
      },
    ];
  }

  // Сохранение данных
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('active_car_id', _activeCarId);
    await prefs.setString('cars_list_data', jsonEncode(_cars));

    // Обновляем текущий авто в общем списке
    for (var car in _cars) {
      if (car['id'] == _activeCarId) {
        car['name'] = _currentCarName;
        car['details'] = _currentCarDetails;
        car['plate'] = _currentCarPlate;
        car['mileage'] = _mileage;
        car['imagePath'] = _currentCarImage;
        car['seasonTyre'] = _currentSeasonTyre;
      }
    }
    await prefs.setString('cars_list_data', jsonEncode(_cars));

    // Сохранение специфичных данных по префиксу
    String prefix = 'car_${_activeCarId}_';
    await prefs.setString(
        '${prefix}insurance_data', jsonEncode(_insuranceData));
    await prefs.setString('${prefix}refuels_data', jsonEncode(_refuels));
    await prefs.setString('${prefix}trips_data', jsonEncode(_trips));

    List serializedParts = _carParts.map((part) {
      var map = Map<String, dynamic>.from(part);
      if (part['icon'] is IconData) {
        map['iconCode'] = (part['icon'] as IconData).codePoint;
      }
      if (part['color'] is Color) {
        map['colorValue'] = (part['color'] as Color).value;
      }
      map.remove('icon');
      map.remove('color');
      return map;
    }).toList();
    await prefs.setString(
        '${prefix}car_parts_data', jsonEncode(serializedParts));

    List serializedLogs = _logs.map((log) {
      var map = Map<String, dynamic>.from(log);
      if (log['icon'] is IconData) {
        map['iconCode'] = (log['icon'] as IconData).codePoint;
      }
      map.remove('icon');
      return map;
    }).toList();
    await prefs.setString('${prefix}logs_data', jsonEncode(serializedLogs));

    List serializedReminders = _reminders.map((rem) {
      var map = Map<String, dynamic>.from(rem);
      if (rem['icon'] is IconData) {
        map['iconCode'] = (rem['icon'] as IconData).codePoint;
      }
      if (rem['iconBgColor'] is Color) {
        map['iconBgColorValue'] = (rem['iconBgColor'] as Color).value;
      }
      map.remove('icon');
      map.remove('iconBgColor');
      return map;
    }).toList();
    await prefs.setString(
        '${prefix}reminders_data', jsonEncode(serializedReminders));
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

  Map<String, dynamic> _getInsuranceStatus() {
    try {
      final today = DateTime.now();
      final expiry = DateTime.parse(_insuranceData['expiryDate']);
      final diffDays = expiry.difference(today).inDays;

      if (diffDays < 0) {
        return {'color': const Color(0xFFE53935), 'text': 'Просрочена'};
      }
      if (diffDays <= 30) {
        return {'color': Colors.orange, 'text': 'Осталось $diffDays дн.'};
      }
      return {
        'color': Colors.green,
        'text': 'До ${_insuranceData['expiryDate']}'
      };
    } catch (_) {
      return {
        'color': Colors.green,
        'text': _insuranceData['expiryDate'] ?? 'Активна'
      };
    }
  }

  void _applyMileageDelta(int mileageDiff) {
    if (mileageDiff <= 0) return;

    setState(() {
      _mileage += mileageDiff;
      for (var part in _carParts) {
        int rem = (part['remainingKm'] as int) - mileageDiff;
        if (rem < 0) rem = 0;
        part['remainingKm'] = rem;

        double max = (part['maxKm'] ?? 10000).toDouble();
        double ratio = max > 0 ? rem / max : 0;

        if (rem == 0 && max > 0) {
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
    _saveData();
  }

  void _toggleTyreSeason() {
    setState(() {
      _currentSeasonTyre = _currentSeasonTyre == 'Летняя резина'
          ? 'Зимняя резина'
          : 'Летняя резина';
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Установлена сезонность: $_currentSeasonTyre')),
    );
  }

  void _showInsuranceDialog() {
    final companyController =
        TextEditingController(text: _insuranceData['company']);
    final numberController =
        TextEditingController(text: _insuranceData['policyNumber']);
    final dateController =
        TextEditingController(text: _insuranceData['expiryDate']);

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
            const Text('Полис страхования',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: companyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Страховая компания',
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
              controller: numberController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Номер полиса',
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
              controller: dateController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Действителен до (ГГГГ-ММ-ДД)',
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
                  setState(() {
                    _insuranceData = {
                      'company': companyController.text,
                      'policyNumber': numberController.text,
                      'expiryDate': dateController.text,
                    };
                  });
                  _saveData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Данные страховки обновлены!')));
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

  void _showAddRecordDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'Топливо';

    final categories = [
      {'id': 'Топливо', 'name': 'Топливо', 'icon': '⛽'},
      {'id': 'Ремонт', 'name': 'Ремонт', 'icon': '🔧'},
      {'id': 'Мойка', 'name': 'Мойка', 'icon': '🧽'},
      {'id': 'Штрафы', 'name': 'Штрафы', 'icon': '⚠️'},
      {'id': 'Расходники', 'name': 'Расходники', 'icon': '📦'},
    ];

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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat['id'];
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedCategory = cat['id']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE53935)
                              : const Color(0xFF2C2C30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE53935)
                                  : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Text(cat['icon']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(cat['name']!,
                                style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Название или описание',
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
                  labelText: 'Сумма (грн)',
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
                    if (priceController.text.isNotEmpty) {
                      IconData catIcon = Icons.build_circle;
                      if (selectedCategory == 'Топливо')
                        catIcon = Icons.local_gas_station;
                      if (selectedCategory == 'Ремонт') catIcon = Icons.build;
                      if (selectedCategory == 'Мойка')
                        catIcon = Icons.local_car_wash;
                      if (selectedCategory == 'Штрафы') catIcon = Icons.warning;
                      if (selectedCategory == 'Расходники')
                        catIcon = Icons.category;

                      String titleText = titleController.text.isEmpty
                          ? selectedCategory
                          : titleController.text;

                      setState(() {
                        _logs.insert(0, {
                          'title': titleText,
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

  // Калькулятор поездки с историей
  void _showTripCalculatorDialog() {
    final fromController = TextEditingController();
    final toController = TextEditingController();
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Калькулятор и расчет поездки',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Откуда',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF2C2C30),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: toController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Куда',
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
                  const SizedBox(height: 12),
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
                            labelText: 'Цена 1л (грн)',
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
                                Text(
                                    '${totalLitersNeeded.toStringAsFixed(1)} л',
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE53935)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Закрыть',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            if (distance > 0) {
                              setState(() {
                                _trips.insert(0, {
                                  'from': fromController.text.isEmpty
                                      ? 'Старт'
                                      : fromController.text,
                                  'to': toController.text.isEmpty
                                      ? 'Финиш'
                                      : toController.text,
                                  'distance': distance,
                                  'cost': totalCost.toStringAsFixed(0),
                                  'liters':
                                      totalLitersNeeded.toStringAsFixed(1),
                                  'date': 'Только что',
                                });
                              });
                              _saveData();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Поездка сохранена в историю!')));
                            }
                          },
                          child: const Text('Сохранить поездку',
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
                      : 'Дата (например, 2026-09-15)',
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
        text:
            carToEdit != null && carToEdit['details'].toString().contains(' • ')
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
                        String uniqueId = carToEdit != null
                            ? carToEdit['id']
                            : DateTime.now().millisecondsSinceEpoch.toString();
                        setState(() {
                          if (carToEdit == null) {
                            _cars.add({
                              'id': uniqueId,
                              'name': carName,
                              'details': details,
                              'plate': plate,
                              'mileage': mileage,
                              'imagePath': tempImagePath,
                              'seasonTyre': tempSeasonTyre,
                            });
                            _activeCarId = uniqueId;
                            _currentCarName = carName;
                            _currentCarDetails = details;
                            _currentCarPlate = plate;
                            _mileage = mileage;
                            _currentCarImage = tempImagePath;
                            _currentSeasonTyre = tempSeasonTyre;
                            _resetDefaultParts();
                            _logs.clear();
                            _refuels.clear();
                            _reminders.clear();
                            _trips.clear();
                          } else {
                            carToEdit['id'] = uniqueId;
                            carToEdit['name'] = carName;
                            carToEdit['details'] = details;
                            carToEdit['plate'] = plate;
                            carToEdit['mileage'] = mileage;
                            carToEdit['imagePath'] = tempImagePath;
                            carToEdit['seasonTyre'] = tempSeasonTyre;

                            if (_activeCarId == uniqueId) {
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
                                ? 'Автомобиль добавлен в гараж!'
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
                      double lastMileage =
                          (_refuels.first['mileage'] as num).toDouble();
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
                    if (mileageDiff > 0) {
                      _applyMileageDelta(mileageDiff);
                    } else {
                      setState(() {
                        _mileage = newMileage;
                      });
                      _saveData();
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Пробег обновлен: ${_mileage.toInt()} км')),
                    );
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
    double progress = maxKm > 0 ? (1.0 - (remaining / maxKm)) : 0;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;

    final costController = TextEditingController(text: '1500');
    final customRemainingController =
        TextEditingController(text: remaining.toString());
    final customMaxController = TextEditingController(text: maxKm.toString());

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
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
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
                const Text('Настройка ресурса вручную:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customRemainingController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Остаток (км)',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2C2C30),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: customMaxController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Ресурс (км)',
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      int? newRem =
                          int.tryParse(customRemainingController.text);
                      int? newMax = int.tryParse(customMaxController.text);
                      if (newRem != null && newMax != null) {
                        setState(() {
                          part['remainingKm'] = newRem;
                          part['maxKm'] = newMax;
                          part['subtitle'] =
                              newRem > 0 ? 'настроено' : 'требует замены';
                          part['color'] = newRem > 0
                              ? Colors.blueAccent
                              : const Color(0xFFE53935);
                        });
                        _saveData();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Параметры узла обновлены')));
                      }
                    },
                    child: const Text('Сохранить настройку ресурса',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Стоимость замены (грн)',
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
                      int fullMax = part['maxKm'] ?? 10000;
                      setState(() {
                        part['remainingKm'] = fullMax;
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
                          content: Text(
                              '${part['title']} заменен, ресурс сброшен до $fullMax км!')));
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
            title: const Text('Калькулятор и поездки',
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
    var insuranceStatus = _getInsuranceStatus();

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
          const SizedBox(height: 16),

// 1. Блок быстрых кнопок
          _buildQuickActions(context),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: _showInsuranceDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: insuranceStatus['color'], width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: insuranceStatus['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.description,
                            color: insuranceStatus['color'], size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Полис страхования',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                              '${_insuranceData['company']} • ${_insuranceData['policyNumber']}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(insuranceStatus['text'],
                          style: TextStyle(
                              color: insuranceStatus['color'],
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('Нажмите для правки',
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
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
          _logs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                      child: Text('Нет записей о расходах для этого авто',
                          style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: _logs.take(3).toList().asMap().entries.map((entry) {
                    int index = entry.key;
                    var log = entry.value;
                    return Dismissible(
                      key: Key('log_${index}_${log['title']}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _logs.removeAt(index);
                        });
                        _saveData();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Расход удален')));
                      },
                      child: _buildLogItemWithCheckbox(log, index),
                    );
                  }).toList(),
                ),
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
          _reminders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                      child: Text('Нет активных напоминаний',
                          style: TextStyle(color: Colors.grey))),
                )
              : Column(
                  children: _reminders.asMap().entries.map((entry) {
                    int index = entry.key;
                    var rem = entry.value;
                    return buildReminderCard(
                      icon: rem['icon'] ?? Icons.notifications,
                      iconBgColor:
                          rem['iconBgColor'] ?? const Color(0xFFE53935),
                      title: rem['title'],
                      subtitle: rem['deadline'],
                      isUrgent: rem['isUrgent'] == true,
                      progress: rem['progress'],
                      onTap: () => _showAddReminderDialog(
                          reminderToEdit: rem, editIndex: index),
                    );
                  }).toList(),
                ),
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
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: isUrgent
                                  ? Colors.redAccent
                                  : Colors.grey[400],
                              fontSize: 14)),
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
                      isUrgent ? Colors.redAccent : Colors.blueAccent),
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
        // 🚀 НАШИ БЫСТРЫЕ КНОПКИ
        QuickActionsWidget(
          logs: _logs,
          onAddLog: (newLog) {
            setState(() {
              _logs.insert(0, newLog);
            });
          },
          onOpenRefuel: () {
            _showAddRefuelDialog();
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        ServiceResourceWidget(
          currentMileage: _cars.isNotEmpty
              ? (int.tryParse(_cars.first['mileage']?.toString() ?? '0') ?? 0)
              : 0,
        ),
        const SizedBox(height: 16),
        _cars.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'В гараже пока нет автомобилей.\nДобавьте первое авто!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            : Column(
                children: _cars.asMap().entries.map((entry) {
                  int index = entry.key;
                  var car = entry.value;
                  bool isActive = car['id'] == _activeCarId;
                  return Dismissible(
                    key: Key(car['id'] ?? index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _cars.removeAt(index);
                        if (isActive && _cars.isNotEmpty) {
                          _loadCarSpecificData(_cars[0]['id']);
                        } else if (_cars.isEmpty) {
                          _activeCarId = 'default_car';
                          _currentCarName = 'Мой автомобиль';
                          _currentCarDetails = 'Добавьте параметры';
                          _currentCarPlate = 'AA 0000 AA';
                          _mileage = 0.0;
                          _currentCarImage = null;
                          _resetDefaultParts();
                          _logs.clear();
                          _refuels.clear();
                          _reminders.clear();
                          _trips.clear();
                        }
                      });
                      _saveData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Автомобиль удален из гаража')));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
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
                                              borderRadius:
                                                  BorderRadius.circular(2)),
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
                                    child: Text(
                                        car['seasonTyre'] ?? 'Летняя резина',
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
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFE53935)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
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
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Пробег: ${(car['mileage'] as num).toInt()} км',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? Colors.grey[800]
                                      : const Color(0xFFE53935),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  await _loadCarSpecificData(car['id']);
                                  setState(() {
                                    _currentIndex = 0;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Интерфейс переключен на: ${car['name']}')));
                                },
                                child: Text(
                                  isActive ? 'Выбрано' : 'Выбрать',
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
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildRefuelsTab() {
    // Берём все логи (или фильтруем по категории 'refuel' / 'заправка', если нужно)
    final refuelLogs = _logs.where((log) {
      final type = log['type']?.toString().toLowerCase() ?? '';
      final category = log['category']?.toString().toLowerCase() ?? '';
      final title = log['title']?.toString().toLowerCase() ?? '';
      return type.contains('refuel') ||
          category.contains('refuel') ||
          title.contains('заправка');
    }).toList();

    // Если отфильтрованный список пуст, используем _logs напрямую
    final displayLogs = refuelLogs.isNotEmpty ? refuelLogs : _logs;

    // Парсим числа из строк (убираем 'грн', 'л', пробелы)
    double parseNum(dynamic val) {
      if (val == null) return 0;
      final str = val.toString().replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(str) ?? 0;
    }

    // Считаем сумму и литры
    double totalSpent = 0;
    double totalLiters = 0;

    for (var log in displayLogs) {
      final costVal =
          log['cost'] ?? log['price'] ?? log['totalCost'] ?? log['amount'] ?? 0;
      // Поиск литров с проверкой названия из заголовка (например "10 л")
      var litersVal = log['liters'] ??
          log['fuelAmount'] ??
          log['volume'] ??
          log['amountLiters'];

      if (litersVal == null && log['title'] != null) {
        final match = RegExp(r'(\d+)\s*л').firstMatch(log['title'].toString());
        if (match != null) litersVal = match.group(1);
      }

      totalSpent += parseNum(costVal);
      totalLiters += parseNum(litersVal);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Шапка и Статистика
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Учет заправок',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showAddRefuelDialog,
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                          label: const Text('Заправить',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 📊 Анимированная карточка статистики
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C1435), Color(0xFF151828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRefuelStatItem(
                            'Потрачено',
                            '${totalSpent.toStringAsFixed(0)} ₴',
                            Icons.account_balance_wallet,
                            Colors.purpleAccent,
                          ),
                          _buildRefuelStatItem(
                            'Залито всего',
                            '${totalLiters.toStringAsFixed(1)} л',
                            Icons.local_gas_station,
                            Colors.orangeAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Всего заправок:',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${displayLogs.length} раз',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Список заправок
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: displayLogs.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.ev_station,
                              size: 64, color: Colors.grey.shade700),
                          const SizedBox(height: 12),
                          const Text('Заправок пока нет',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = displayLogs[index];

                      // Красиво достаем литры и стоимость
                      double litersParsed = parseNum(
                          log['liters'] ?? log['fuelAmount'] ?? log['volume']);
                      if (litersParsed == 0 && log['title'] != null) {
                        final match = RegExp(r'(\d+)\s*л')
                            .firstMatch(log['title'].toString());
                        if (match != null)
                          litersParsed = double.tryParse(match.group(1)!) ?? 0;
                      }

                      final costStr = (log['cost'] ??
                              log['price'] ??
                              log['totalCost'] ??
                              log['amount'] ??
                              '')
                          .toString()
                          .replaceAll('грн', '')
                          .trim();

                      // final mileage = log['mileage'] ??
                      log['currentMileage'] ??
                          log['odometer'] ??
                          log['km'] ??
                          '—';
                      final title = log['title'] ?? log['date'] ?? 'Заправка';

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 80)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - value) * 25),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E22),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.redAccent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.local_gas_station_rounded,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (log['mileage'] ??
                                                        log['currentMileage'] ??
                                                        log['odometer'] ??
                                                        log['km']) !=
                                                    null
                                                ? '${log['mileage'] ?? log['currentMileage'] ?? log['odometer'] ?? log['km']} км'
                                                : (log['date'] ??
                                                        log['dateTime'] ??
                                                        log['timestamp'] ??
                                                        log['createdAt'] ??
                                                        'Заправка')
                                                    .toString(),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '+${litersParsed.toStringAsFixed(0)} л',
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$costStr ₴',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: displayLogs.length,
                  ),
                ),
        ),
      ],
    );
  }

// Вспомогательный виджет для элементов статистики (поставь его сразу под функцией выше)

// Вспомогательный элемент статистики (вставь его прямо под методом _buildRefuelsTab)
  Widget _buildRefuelStatItem(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
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
            const Text('Расходы и поездки',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.calculate, color: Color(0xFFE53935)),
              tooltip: 'Калькулятор поездок',
              onPressed: _showTripCalculatorDialog,
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
                  _buildBar('Янв', 10),
                  _buildBar('Фев', 10),
                  _buildBar('Мар', 10),
                  _buildBar('Апр', 10),
                  _buildBar('Май', 10),
                  _buildBar('Июн', 10),
                  _buildBar('Июл', _totalExpenses > 0 ? 80.0 : 10.0,
                      isRed: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Раздел истории поездок
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('История поездок',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _showTripCalculatorDialog,
              child: const Text('+ Рассчитать',
                  style: TextStyle(color: Color(0xFFE53935), fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _trips.isEmpty
            ? const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Нет сохраненных поездок',
                        style: TextStyle(color: Colors.grey))))
            : Column(
                children: _trips.asMap().entries.map((entry) {
                  int index = entry.key;
                  var trip = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
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
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.alt_route,
                              color: Colors.blueAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${trip['from']} → ${trip['to']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                  '${trip['distance']} км • ${trip['liters']} л',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text('${trip['cost']} грн',
                            style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.grey, size: 18),
                          onPressed: () {
                            setState(() {
                              _trips.removeAt(index);
                            });
                            _saveData();
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 24),
        const Text('История всех затрат',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _logs.isEmpty
            ? const Center(
                child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Нет записей о расходах',
                        style: TextStyle(color: Colors.grey))))
            : Column(
                children: _logs.asMap().entries.map((entry) {
                  int index = entry.key;
                  var log = entry.value;
                  return _buildLogItemWithCheckbox(log, index);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildLogItemWithCheckbox(Map<String, dynamic> log, int index) {
    bool isChecked = log['isChecked'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: const Color(0xFFE53935),
            onChanged: (val) {
              setState(() {
                log['isChecked'] = val ?? false;
              });
              _saveData();
            },
          ),
          Expanded(child: _buildLogItem(log)),
          IconButton(
            icon:
                const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
            onPressed: () {
              setState(() {
                _logs.removeAt(index);
              });
              _saveData();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Расход удален')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    bool isChecked = log['isChecked'] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    Flexible(
                      child: Text(
                        log['title']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isChecked ? Colors.grey : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
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
              style: TextStyle(
                  color: isChecked ? Colors.grey : Colors.white,
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

  // 1. Умная карточка узла (ТО) с прогресс-баром
  Widget _buildFluidCard({
    required String title,
    required int currentKm,
    required int maxKm,
    required IconData icon,
    required Color color,
  }) {
    double progress = (currentKm / maxKm).clamp(0.0, 1.0);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '$currentKm км',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              color: progress > 0.8 ? Colors.redAccent : color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

// 2. Блок быстрых действий
  // Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Заправка',
            icon: Icons.local_gas_station,
            color: Colors.redAccent,
            onTap: () {
              _showAddRefuelDialog();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            label: 'Сервис',
            icon: Icons.build,
            color: Colors.blueAccent,
            onTap: () {
              _showAddRecordDialog();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            label: 'Заметка',
            icon: Icons.note_add,
            color: Colors.orangeAccent,
            onTap: () {
              _showAddRecordDialog();
            },
          ),
        ),
      ],
    );
  }

  // Карточка общих трат за месяц

  // Кнопка для быстрого действия
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
