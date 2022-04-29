import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

class RandomSelectTextController extends GetxController {

  List<String>? _pool;

  final _isSpinning = false.obs;
  bool get isSpinning => _isSpinning.value;

  final _value = "".obs;
  String get value => _value.value;

  late final Random _random = Random(DateTime.now().millisecondsSinceEpoch,);

  static const _baseIntervalMillis = 144.0;

  Timer? _spinTimer;

  void _showRandom() {
    final pool = _pool;
    if (pool != null && pool.isNotEmpty) {
      final i = _random.nextInt(pool.length,);
      _value.value = pool[i];
    }
  }

  void _spinForever() {
    if (_isSpinning.value) return;
    _isSpinning.value = true;
    _spinTimer = Timer.periodic(
      Duration(milliseconds: _baseIntervalMillis.floor(),),
      (_) {
        _showRandom();
      },
    );
  }

  Future<void> stopSpin({String? fixedFlag,}) async {
    if (_spinTimer?.isActive == true) {
      _spinTimer?.cancel();
    }
    double millis = _baseIntervalMillis;
    while (millis < 2500) {
      await Future.delayed(
        Duration(milliseconds: millis.floor(),),
        () {
          _showRandom();
        },
      );
      millis *= 1.1;
    }
    if (fixedFlag != null) {
      final index = _pool?.indexWhere((item) => item == fixedFlag,);
      if (index != null && index >= 0) {
        _value.value = _pool?.elementAt(index,) ?? "";

      }
    }
  }

  void start(List<String> pool,) {
    if (pool.isEmpty) return;
    _pool = pool;
    _spinForever();
  }

  @override
  void onClose() {
    _value.close();
    _isSpinning.close();
    if (_spinTimer?.isActive == true) {
      _spinTimer?.cancel();
    }
    super.onClose();
  }
}