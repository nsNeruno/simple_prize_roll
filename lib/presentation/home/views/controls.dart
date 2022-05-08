import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_prize_roll/presentation/home/controllers/home_controller.dart';

class Controls extends GetView<HomeController> {

  const Controls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Hadiah saat ini",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Text(
                controller.currentPrize?.name ?? "-",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pemenang terpilih",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Text(
                controller.selectedEntry?.id ?? "-",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: GetBuilder<HomeController>(
            builder: (controller) => ElevatedButton(
              onPressed: controller.isRolling ? controller.stop : controller.start,
              child: Padding(
                padding: const EdgeInsets.all(12.0,),
                child: Text(
                  controller.isRolling ? "Stop" : "Start",
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}