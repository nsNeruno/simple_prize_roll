import 'dart:collection';

import 'package:get/get.dart';

import '../presentation/home/home.dart';

class AppPages extends ListBase<GetPage> {

  late final _pages = List.unmodifiable(
    <GetPage>[
      GetPage(
        name: homePage,
        page: () => HomePage(),
        binding: HomeBindings(),
      ),
    ],
  );

  @override
  int get length => _pages.length;

  @override
  GetPage operator [](int index) => _pages[index];

  @override
  void operator []=(int index, GetPage value) {
    // Not implemented
  }

  static const homePage = "/";

  @override
  set length(int newLength) {
    // Not implemented
  }
}