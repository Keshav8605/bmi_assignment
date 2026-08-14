import 'bmi_record_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final double height; // stored in cm
  final double weight; // stored in kg
  final String gender;
  final List<BmiRecord> history;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.gender,
    this.history = const [],
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? height,
    double? weight,
    String? gender,
    List<BmiRecord>? history,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
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
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}
