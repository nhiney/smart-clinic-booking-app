import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('test_screenshots/patient/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      // ignore: avoid_print
      print('[SCREENSHOT] saved test_screenshots/patient/$name.png');
      return true;
    },
  );
}
