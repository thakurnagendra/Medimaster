class TestModel {
  final int testId;
  final String testName;
  final String? category;
  final double? rate;
  final String? type;

  TestModel({
    required this.testId,
    required this.testName,
    this.category,
    this.rate,
    this.type,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      testId: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      testName: json['test_Name'] ?? '',
      category: json['test_Group'] as String?,
      rate: json['rate'] != null
          ? double.tryParse(json['rate'].toString())
          : null,
      type: json['serviceType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': testId,
      'test_Name': testName,
      'test_Group': category,
      'rate': rate,
      'serviceType': type,
    };
  }
}
