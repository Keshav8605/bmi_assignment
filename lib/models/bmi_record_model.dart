class BmiRecord {
  final String id;
  final double bmiValue;
  final DateTime date;
  final double weight;

  BmiRecord({
    required this.id,
    required this.bmiValue,
    required this.date,
    required this.weight,
  });

  factory BmiRecord.fromJson(Map<String, dynamic> json) {
    return BmiRecord(
      id: json['id'],
      bmiValue: json['bmiValue'],
      date: DateTime.parse(json['date']),
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bmiValue': bmiValue,
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }
}
