// import 'dart:async';
// import 'dart:io';

// import 'package:flutter_driver/flutter_driver.dart';

// const String _examplePackage = 'io.flutter.plugins.cameraexample';

// Future<void> main() async {
//   if (!(Platform.isLinux || Platform.isMacOS)) {
//     print('This test must be run on a POSIX host. Skipping...');
//     exit(0);
//   }
//   final bool adbExists =
//       Process.runSync('which', <String>['adb']).exitCode == 0;
//   if (!adbExists) {
//     print('This test needs ADB to exist on the \$PATH. Skipping...');
//     exit(0);
//   }
//   print('Granting camera permissions...');
//   Process.runSync('adb', <String>[
//     'shell',
//     'pm',
//     'grant',
//     _examplePackage,
//     'android.permission.CAMERA'
//   ]);
//   Process.runSync('adb', <String>[
//     'shell',
//     'pm',
//     'grant',
//     _examplePackage,
//     'android.permission.RECORD_AUDIO'
//   ]);
//   print('Starting test.');
//   final FlutterDriver driver = await FlutterDriver.connect();
//   final String result =
//       await driver.requestData(null, timeout: const Duration(minutes: 1));
//   await driver.close();
//   print('Test finished. Revoking camera permissions...');
//   Process.runSync('adb', <String>[
//     'shell',
//     'pm',
//     'revoke',
//     _examplePackage,
//     'android.permission.CAMERA'
//   ]);
//   Process.runSync('adb', <String>[
//     'shell',
//     'pm',
//     'revoke',
//     _examplePackage,
//     'android.permission.RECORD_AUDIO'
//   ]);
//   exit(result == 'pass' ? 0 : 1);
// }
