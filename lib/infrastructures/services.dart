import 'dart:io';

import 'package:desktop/desktop.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menubar/menubar.dart';

class MenuProviderService extends GetxService {

  @override
  void onInit() {
    super.onInit();
    setApplicationMenu(
      [
        Submenu(
          label: "File",
          children: [
            MenuItem(
              label: "Open",
              shortcut: LogicalKeySet.fromSet(
                {
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyO,
                },
              ),
              onClicked: () {
                FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: [
                    "xlsx", "xls", "csv", "odt",
                  ],
                ).then(
                  (pickerResult) {
                    final files = pickerResult?.files;
                    if (files != null && files.isNotEmpty) {
                      final path = files.first.path;
                      if (path != null) {
                        final file = File(path,);
                        Get.find<ExcelProviderService>().readFile(file: file,);
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class InputFileProviderService extends GetxService {

  final _selectedFile = Rxn<File>();
  File? get selectedFile => _selectedFile.value;

  Future<void> selectDataFile() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        "xlsx", "xls", "csv", "odt",
      ],
    );
    final files = pickerResult?.files;
    if (files != null && files.isNotEmpty) {
      final filePath = files.first.path;
      if (filePath != null) {
        _selectedFile.value = File(filePath,);
      }
    }
  }
}

class ExcelProviderService extends GetxService {

  final _excel = Rxn<Excel>();
  Excel? get excel => _excel.value;
  Stream<Excel?> get onExcelRead => _excel.stream;

  Future<Excel?> readFile({required File file,}) async {
    try {
      final excelBytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(excelBytes,);
      _excel.value = excel;
      return excel;
    } catch (err) {
      print(err,);
      return null;
    }
  }

  Future<void> saveExcel({required Excel excel, String? fileName,}) async {
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: "Save to Spreadsheet",
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [
        "xlsx", "xls", "csv", "odt",
      ],
      lockParentWindow: true,
    );
    if (savePath != null) {
      List<int>? excelBytes;
      if (fileName != null) {
        excelBytes = excel.save(fileName: fileName,);
      } else {
        excelBytes = excel.save();
      }
      if (excelBytes != null) {
        File file = File(savePath,);
        file = await file.writeAsBytes(excelBytes, flush: true,);
      }
    }
  }
}