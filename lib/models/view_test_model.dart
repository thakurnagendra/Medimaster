class ViewTestModel {
  final int testId;
  final String testName;

  ViewTestModel({
    required this.testId,
    required this.testName,
  });

  factory ViewTestModel.fromJson(Map<String, dynamic> json) {
    return ViewTestModel(
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
