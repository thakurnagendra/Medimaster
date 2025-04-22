import 'package:get/get.dart';
import '../controllers/credit_list_controller.dart';

class CreditListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreditListController>(() => CreditListController());
  }
}
