import 'bmi_record_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final double height; // stored in cm
  final double weight; // stored in kg
  final String gender;
  final double? targetWeight;
  final DateTime? targetDate;
  final List<BmiRecord> history;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.gender,
    this.targetWeight,
    this.targetDate,
    this.history = const [],
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? height,
    double? weight,
    String? gender,
    double? targetWeight,
    DateTime? targetDate,
    List<BmiRecord>? history,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      history: history ?? this.history,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      height: json['height']?.toDouble() ?? 170.0,
      weight: json['weight']?.toDouble() ?? 70.0,
      gender: json['gender'] ?? 'Male',
      targetWeight: json['targetWeight']?.toDouble(),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => BmiRecord.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'gender': gender,
      'targetWeight': targetWeight,
      'targetDate': targetDate?.toIso8601String(),
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}
