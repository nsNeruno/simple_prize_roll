import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_prize_roll/infrastructures/pages.dart';
import 'package:simple_prize_roll/infrastructures/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final size = await DesktopWindow.getWindowSize();
    await DesktopWindow.setMinWindowSize(size,);
  } catch (err) {
    print(err);
    if (err is Error) {
      print(err.stackTrace,);
    }
  }
  // await DesktopWindow.setFullScreen(true);

  runApp(
    const SimplePrizeRollApp(),
  );
}

class SimplePrizeRollApp extends StatelessWidget {
  const SimplePrizeRollApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Simple Prize Roll',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      getPages: AppPages(),
      initialRoute: AppPages.homePage,
      initialBinding: BindingsBuilder(
        () {
          Get.put(
            MenuProviderService(),
          );
          Get.put(
            InputFileProviderService(),
          );
          Get.put(
            ExcelProviderService(),
          );
        },
      ),
    );
  }
}