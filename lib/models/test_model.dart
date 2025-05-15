class TestModel {
  final int testId;
  final String testName;

  TestModel({
    required this.testId,
    required this.testName,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Creating TestModel from JSON: $json');
    final testId = json['test_Id'];
    final testName = json['test_Name'];

    if (testId == null) throw Exception('test_Id is null');
    if (testName == null) throw Exception('test_Name is null');

    return TestModel(
      testId: testId is int ? testId : int.parse(testId.toString()),
      testName: testName.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_Id': testId,
      'test_Name': testName,
    };
  }
}
