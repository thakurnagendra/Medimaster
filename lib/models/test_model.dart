class TestModel {
  final int testId;
  final String testName;

  TestModel({
    required this.testId,
    required this.testName,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      testId: json['test_Id'] ?? 0,
      testName: json['test_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_Id': testId,
      'test_Name': testName,
    };
  }
}
