import 'package:hive/hive.dart';

part 'day_config.g.dart';

@HiveType(typeId: 2)
class DayConfig extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String shortName;

  @HiveField(2)
  bool enabled;

  @HiveField(3)
  int weekdayNumber; // 1-7 (Monday-Sunday)

  DayConfig({
    required this.name,
    required this.shortName,
    required this.enabled,
    required this.weekdayNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'shortName': shortName,
    'enabled': enabled,
    'weekdayNumber': weekdayNumber,
  };

  factory DayConfig.fromJson(Map<String, dynamic> json) => DayConfig(
    name: json['name'] as String,
    shortName: json['shortName'] as String,
    enabled: json['enabled'] as bool,
    weekdayNumber: json['weekdayNumber'] as int,
  );
}