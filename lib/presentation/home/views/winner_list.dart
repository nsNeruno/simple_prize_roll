import 'package:desktop/desktop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_prize_roll/presentation/home/controllers/home_controller.dart';

class WinnerList extends GetView<HomeController> {

  const WinnerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(12.0,),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(24.0,),
      ),
      constraints: const BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pemenang",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),
          ),
          const SizedBox(height: 4.0,),
          Expanded(
            child: Obx(
              () {
                final entries = controller.rolledEntries;
                return ListTableTheme(
                  data: const ListTableThemeData(
                    hoverColor: Colors.blue,
                    background: Colors.blueGrey,
                  ),
                  child: ListTable(
                    colCount: 3,
                    itemCount: entries.length,
                    tableHeaderBuilder: (context, col, constraints,) {
                      late final String header;
                      switch (col) {
                        case 0:
                          header = "No.";
                          break;
                        case 1:
                          header = "No. Resi";
                          break;
                        case 2:
                          header = "Hadiah";
                          break;
                        default:
                          header = "";
                          break;
                      }
                      return Card(
                        elevation: 16.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            header,
                          ),
                        ),
                      );
                    },
                    tableRowBuilder: (context, row, col, constraints,) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Builder(
                          builder: (_) {
                            final entry = entries[row];
                            switch (col) {
                              case 0:
                                return Text((row + 1).toString(),);
                              case 1:
                                return Text(entry.id,);
                              case 2:
                                return Text(entry.wonPrize ?? "-",);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      );
                    },
                    colFraction: const {
                      0: 0.10,
                      1: 0.45,
                      2: 0.45,
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12.0,),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(24.0,),
            ),
            child: Obx(
              () {
                final entries = controller.rolledEntries;
                return ListTableTheme(
                  data: const ListTableThemeData(
                    hoverColor: Colors.blue,
                    background: Colors.blueGrey,
                  ),
                  child: ListTable(
                    colCount: 3,
                    itemCount: entries.length,
                    tableHeaderBuilder: (context, col, constraints,) {
                      late final String header;
                      switch (col) {
                        case 0:
                          header = "No.";
                          break;
                        case 1:
                          header = "No. Resi";
                          break;
                        case 2:
                          header = "Hadiah";
                          break;
                        default:
                          header = "";
                          break;
                      }
                      return Card(
                        elevation: 16.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            header,
                          ),
                        ),
                      );
                    },
                    tableRowBuilder: (context, row, col, constraints,) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Builder(
                          builder: (_) {
                            final entry = entries[row];
                            switch (col) {
                              case 0:
                                return Text((row + 1).toString(),);
                              case 1:
                                return Text(entry.id,);
                              case 2:
                                return Text(entry.wonPrize ?? "-",);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      );
                    },
                    colFraction: const {
                      0: 0.10,
                      1: 0.45,
                      2: 0.45,
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}