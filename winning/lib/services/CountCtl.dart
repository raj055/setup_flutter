import 'package:get/get.dart' hide Response;

class CountCtl extends GetxController {
  int count = 0;

  static CountCtl get to => Get.find();

  CountCtl(int count) {
    this.count = count;
    update();
  }

  void increment() {
    count++;
    update();
  }

  void decrement() {
    count--;
    update();
  }

  void resetCount() {
    count = 0;
    update();
  }
}
