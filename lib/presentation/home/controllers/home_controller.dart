import 'dart:async';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:get_controller_plus/get_controller_plus.dart';
import 'package:simple_prize_roll/domain/entities.dart';
import 'package:simple_prize_roll/infrastructures/services.dart';
import 'package:simple_prize_roll/presentation/home/controllers/random_select_text_controller.dart';

class HomeController extends GetxControllerPlus {

  HomeController._();

  final _rolledEntries = <RollEntry>[].obs;
  List<RollEntry> get rolledEntries => _rolledEntries;

  final _unrolledEntries = <RollEntry>[].obs;
  List<RollEntry> get unrolledEntries => _unrolledEntries;

  final _selectedEntry = Rxn<RollEntry>();
  RollEntry? get selectedEntry => _selectedEntry.value;

  final _prizes = <RollPrize>[].obs;
  RollPrize? get currentPrize {
    if (_prizes.isNotEmpty) {
      return _prizes.first;
    }
    return null;
  }

  late final Random _random = Random(
    DateTime.now().millisecondsSinceEpoch,
  );

  Timer? _waitTimer;
  bool get isRolling => _waitTimer?.isActive == true;

  final randTextController = Get.put(
    RandomSelectTextController(),
  );

  List<RollEntry> _getEntrants(Sheet sheet,) {
    return sheet.rows.map(
      (row) {
        String? entrantId;
        String? fixedPrize;
        for (int i = 0; i < row.length; i++) {
          switch (i) {
            case 0:
              entrantId = row[i]?.value.toString();
              break;
            case 1:
              fixedPrize = row[i]?.value.toString();
              break;
          }
        }
        if (entrantId == null) return null;
        return RollEntry(id: entrantId, fixedPrize: fixedPrize,);
      },
    ).whereType<RollEntry>().toList();
  }

  List<RollPrize> _getRollPrizes(Sheet sheet,) {
    final prizes = <RollPrize>[];
    for (var row in sheet.rows) {
      String? prizeName;
      int count = 1;
      List<String>? fixedEntries;
      for (int i = 0; i < row.length; i++) {
        final value = row[i]?.value?.toString();
        switch (i) {
          case 0:
            prizeName = value;
            break;
          case 1:
            if (value != null) {
              int? maybeCount = num.tryParse(value,)?.toInt();
              if (maybeCount != null) {
                maybeCount = maybeCount.abs();
                if (maybeCount > 0) {
                  count = maybeCount;
                }
              }
            }
            break;
          case 2:
            if (value != null && value.isNotEmpty) {
              fixedEntries = value.split(";",).map((e) => e.trim(),).toList();
            }
            break;
        }
      }
      if (prizeName != null) {
        prizes.add(
          RollPrize(
            name: prizeName,
            count: count,
            fixedEntries: fixedEntries,
          ),
        );
      }
    }
    return prizes;
  }

  void _reset() {
    _unrolledEntries.value = [];
    _rolledEntries.value = [];
    _prizes.value = [];
  }

  void _onExcelRead(Excel excel,) {
    final sheets = excel.sheets.values.toList();
    if (sheets.isNotEmpty) {

      final entrantSheet = sheets[0];
      Sheet? prizesSheet;
      if (sheets.length >= 2) {
        prizesSheet = sheets[1];
      }
      if (prizesSheet != null) {
        final entrants = _getEntrants(entrantSheet,);
        final prizes = _getRollPrizes(prizesSheet,);

        _unrolledEntries.value = entrants;
        _rolledEntries.value = [];
        _prizes.value = prizes;
        return;
      }
    }
    _reset();
  }

  void _showRandom() {
    final List<RollEntry> pool = _unrolledEntries;
    if (pool.isNotEmpty) {
      final i = _random.nextInt(pool.length,);
      _selectedEntry.value = pool[i];
    }
  }

  void start() {
    if (currentPrize == null || _unrolledEntries.isEmpty) return;
    _waitTimer = Timer.periodic(
      const Duration(milliseconds: 100,),
      (timer) {
        _showRandom();
      },
    );
    update();
  }

  void _fillWinners(RollPrize prize,) {
    final count = prize.count;
    final fixedEntries = Map<String, bool>.fromEntries(
      (prize.fixedEntries ?? []).map((e) => MapEntry(e, true,),),
    );
    final List<RollEntry> unrolledCopy = [];
    final List<RollEntry> fixedUnrolledCopy = [];
    final chosenEntriesMap = <String, bool>{};
    for (var entry in _unrolledEntries) {
      if (fixedEntries[entry.id] == true) {
        fixedUnrolledCopy.add(entry,);
      } else {
        unrolledCopy.add(entry,);
      }
    }
    final List<RollEntry> entrantsToAdd = [];
    for (int i = 0; i < count; i++) {
      late final RollEntry selectedEntry;
      if (fixedUnrolledCopy.isNotEmpty) {
        selectedEntry = fixedUnrolledCopy.removeAt(0,)..wonPrize = prize.name;
        entrantsToAdd.add(
          selectedEntry,
        );
      } else {
        selectedEntry = unrolledCopy.removeAt(
          _random.nextInt(unrolledCopy.length,),
        )..wonPrize = prize.name;
        entrantsToAdd.add(
          selectedEntry,
        );
      }
      chosenEntriesMap[selectedEntry.id] = true;
    }
    _rolledEntries.addAll(entrantsToAdd,);
    _unrolledEntries.removeWhere(
      (entry) => chosenEntriesMap[entry.id] == true,
    );
    _prizes.removeAt(0,);
    update();
  }

  Future<void> stop() async {
    if (_waitTimer?.isActive != true) {
      return;
    }
    final currentPrize = this.currentPrize;
    if (currentPrize == null || _unrolledEntries.isEmpty) return;

    _waitTimer?.cancel();
    _selectedEntry.value = null;

    _fillWinners(currentPrize,);
  }

  Future<void> exportWinners() async {
    final List<RollEntry> winners = List.from(_rolledEntries,);
    if (winners.isEmpty) {
      return;
    }
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet == null) return;
    excel.rename(defaultSheet, "Winners",);
    final sheet = excel.sheets["Winners"];
    if (sheet == null) return;
    sheet.insertRowIterables(
      [
        "No.", "AWB", "Hadiah",
      ],
      0,
    );
    for (int i = 0; i < winners.length; i++) {
      final entrant = winners[i];
      final idx = i + 1;
      sheet.insertRowIterables(
        [
          idx.toString(),
          entrant.id,
          entrant.wonPrize ?? "",
        ],
        idx,
      );
    }
    Get.find<ExcelProviderService>().saveExcel(
      excel: excel,
      fileName: "Winner.xlsx",
    );
  }

  @override
  void onInit() {
    super.onInit();
    Get.find<ExcelProviderService>().onExcelRead.listen(
      (excel) {
        if (excel != null) {
          _onExcelRead(excel,);
        }
      },
    );
    // final entries = globalEntries.map(
    //   (e) => RollEntry(id: e,),
    // ).toList();
    // _entries.value = entries;
    // _unrolledEntries.value = entries;
  }

  @override
  void onClose() {
    _rolledEntries.close();
    _unrolledEntries.close();
    _waitTimer?.cancel();
    super.onClose();
  }
}

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(
      HomeController._(),
    );
  }
}