import 'dart:async';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:get_controller_plus/get_controller_plus.dart';
import 'package:simple_prize_roll/domain/constants.dart';
import 'package:simple_prize_roll/domain/entities.dart';
import 'package:simple_prize_roll/infrastructures/services.dart';
import 'package:simple_prize_roll/presentation/home/controllers/random_select_text_controller.dart';

class HomeController extends GetxControllerPlus {

  HomeController._();

  final _entries = Rxn<List<RollEntry>>();
  List<RollEntry>? get entries => _entries.value;

  final _rolledEntries = <RollEntry>[].obs;
  List<RollEntry> get rolledEntries => _rolledEntries;

  final _unrolledEntries = <RollEntry>[].obs;
  List<RollEntry> get unrolledEntries => _unrolledEntries;

  final _selectedEntry = Rxn<RollEntry>();
  RollEntry? get selectedEntry => _selectedEntry.value;

  final _prizes = globalPrizes.toList().obs;
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

  void _onExcelRead(Excel excel,) {
    // final sheets = excel.sheets;
    // if (sheets.isNotEmpty) {
    //   final sheet = sheets[sheets.keys.elementAt(0,)]!;
    //   final mappedData = sheet.rows.map(
    //     (row) => row.whereType<Data>().map(
    //       (data) => data.value.toString(),
    //     ).toList(growable: false,),
    //   ).toList(growable: false,);
    //   final entries = mappedData.map(
    //     (data) {
    //       final id = data[0];
    //       String? flag;
    //       if (data.length >= 2) {
    //         flag = data[1];
    //       }
    //       return RollEntry(id: id, flag: flag,);
    //     },
    //   );
    //   _entries.value = entries.toList(growable: false,);
    // }
  }

  void _showRandom() {
    final List<RollEntry> pool = _unrolledEntries;
    if (pool.isNotEmpty) {
      final i = _random.nextInt(pool.length,);
      _selectedEntry.value = pool[i];
    }
  }

  void start() {
    if (currentPrize == null) return;
    _waitTimer = Timer.periodic(
      const Duration(milliseconds: 100,),
      (timer) {
        _showRandom();
      },
    );
    update();
  }

  static const _baseIntervalMillis = 144.0;

  Future<void> stop() async {
    if (_waitTimer?.isActive == true) {
      _waitTimer?.cancel();
    } else {
      return;
    }
    double millis = _baseIntervalMillis;
    while (millis < 1210) {
      await Future.delayed(
        Duration(milliseconds: millis.floor(),),
      );
      _showRandom();
      millis *= 1.1;
    }
    final current = _selectedEntry.value;
    if (current != null) {
      current.wonPrize = _prizes.removeAt(0,);
      _rolledEntries.add(current,);
      _unrolledEntries.remove(current,);
    }
    update();
    // if (fixedFlag != null) {
    //   final index = _pool?.indexWhere((item) => item == fixedFlag,);
    //   if (index != null && index >= 0) {
    //     _value.value = _pool?.elementAt(index,) ?? "";
    //
    //   }
    // }
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
    final entries = globalEntries.map(
      (e) => RollEntry(id: e,),
    ).toList();
    _entries.value = entries;
    _unrolledEntries.value = entries;
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