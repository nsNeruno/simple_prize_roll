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

  final _entries = <RollEntry>[].obs;
  List<RollEntry> get entries => _entries;

  final _rolledEntries = <RollEntry>[].obs;
  List<RollEntry> get rolledEntries => _rolledEntries;

  final _unrolledEntries = <RollEntry>[].obs;
  List<RollEntry> get unrolledEntries => _unrolledEntries;

  final _selectedEntry = Rxn<RollEntry>();
  RollEntry? get selectedEntry => _selectedEntry.value;

  final _prizes = <String>[].obs;
  String? get currentPrize {
    if (_prizes.isNotEmpty) {
      return _prizes.first;
    }
    return null;
  }

  late final Random _random = Random(DateTime.now().millisecondsSinceEpoch,);
  Timer? _waitTimer;
  bool get isRolling => _waitTimer?.isActive == true;

  final randTextController = Get.put(RandomSelectTextController(),);

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

  List<String> _getPrizes(Sheet sheet,) {
    final prizesMap = <String, int>{};
    for (var row in sheet.rows) {
      String? prizeName;
      int? count;
      for (int i = 0; i < row.length; i++) {
        switch (i) {
          case 0:
            prizeName = row[i]?.value.toString();
            break;
          case 1:
            final value = row[i]?.value;
            if (value != null) {
              if (value is num) {
                count = value.abs().truncate();
              } else if (value is String) {
                count = int.tryParse(value,);
              }
            }
            break;
        }
        if (prizeName != null) {
          prizesMap[prizeName] = count ?? 1;
        }
      }
    }
    return prizesMap.entries.map<List<String>>(
      (entry) => List.generate(entry.value, (_) => entry.key,),
    ).expand((groups) => groups,).toList();
  }

  void _reset() {
    _entries.value = [];
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
        final prizes = _getPrizes(prizesSheet,);

        _entries.value = entrants;
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

  static const _baseIntervalMillis = 144.0;

  RollEntry? _getFixedEntrant(String fixedPrize,) {
    final idx = _unrolledEntries.indexWhere((entry) => entry.fixedPrize == fixedPrize,);
    if (idx >= 0) {
      return _unrolledEntries[idx];
    }
    return null;
  }

  Future<void> stop() async {
    if (_waitTimer?.isActive != true) {
      return;
    }
    final currentPrize = this.currentPrize;
    if (currentPrize == null || _unrolledEntries.isEmpty) return;
    final fixedEntrant = _getFixedEntrant(currentPrize,);

    _waitTimer?.cancel();
    double millis = _baseIntervalMillis;
    while (millis < 1210) {
      await Future.delayed(
        Duration(milliseconds: millis.floor(),),
      );
      _showRandom();
      millis *= 1.1;
    }
    if (fixedEntrant != null) {
      fixedEntrant.wonPrize = _prizes.removeAt(0,);
      _rolledEntries.add(fixedEntrant,);
      _unrolledEntries.remove(fixedEntrant,);
    } else {
      var current = _selectedEntry.value;
      if (current != null) {
        if (current.fixedPrize != null) {
          final nonFixedEntries = _unrolledEntries.where(
            (entry) => entry.fixedPrize == null,
          ).toList(growable: false,);
          current = nonFixedEntries[_random.nextInt(nonFixedEntries.length,)];
        }
        current.wonPrize = _prizes.removeAt(0,);
        _rolledEntries.add(current,);
        _unrolledEntries.remove(current,);
      }
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
    Get.find<ExcelReaderService>().onExcelRead.listen(
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
    _entries.close();
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