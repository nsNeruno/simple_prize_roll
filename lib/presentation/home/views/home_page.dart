import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_prize_roll/presentation/home/controllers/home_controller.dart';
import 'package:simple_prize_roll/presentation/home/views/controls.dart';
import 'package:simple_prize_roll/presentation/home/views/participant_list.dart';
import 'package:simple_prize_roll/presentation/home/views/random_select_text.dart';
import 'package:simple_prize_roll/presentation/home/views/winner_list.dart';

class HomePage extends GetView<HomeController> {

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.redAccent,
                  Colors.red,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/logo_jnt.png",
                  height: MediaQuery.of(context,).size.height * 0.1,
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0,),
              child: Row(
                children: const [
                  Expanded(
                    child: WinnerList(),
                    flex: 7,
                  ),
                  SizedBox(width: 20.0,),
                  Expanded(
                    child: ParticipantList(),
                    flex: 3,
                  ),
                  SizedBox(width: 20.0,),
                  Expanded(
                    child: Controls(),
                    flex: 7,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}