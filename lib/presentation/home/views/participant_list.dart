import 'package:desktop/desktop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_prize_roll/presentation/home/controllers/home_controller.dart';

class ParticipantList extends StatelessWidget {

  const ParticipantList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.all(12.0,),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(24.0,),
      ),
      child: ListTableTheme(
        data: const ListTableThemeData(
          hoverColor: Colors.blueGrey,
        ),
        child: Obx(
          () {
            final entries = controller.unrolledEntries;
            return ListTable(
              colCount: 1,
              itemCount: entries.length,
              tableHeaderBuilder: (context, index, constraints,) {
                return Card(
                  elevation: 16.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Peserta",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              tableRowBuilder: (context, row, col, constraints,) {
                final entry = entries[row];
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(entry.id,),
                );
              },
            );
          },
        ),
      ),
    );
  }
}