import 'package:desktop/desktop.dart';
import 'package:get/get.dart';
import 'package:simple_prize_roll/presentation/home/controllers/random_select_text_controller.dart';

class RandomSelectText extends GetView<RandomSelectTextController> {

  const RandomSelectText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Obx(
      () => Text(controller.value,),
    );
  }
}