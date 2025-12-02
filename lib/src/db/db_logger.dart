import 'dart:developer' as developer;

typedef DbLogger = void Function(String message);

class DBLogger {
  static DbLogger? _logger;

  static void configure(DbLogger logger) {
    _logger = logger;
  }

  static void info(String message) {
    if (_logger != null) {
      _logger!(message);
    } else {
      developer.log(message, name: 'super_dbtx');
    }
  }
}

// class Dummy {
//   DBLogger? log;
//   getPrint() {
//     DBLogger.configure((msg) {
// print('');
// });
//   }
// }

// class A {
//   void test() {
//     print(DBLogger._logger);
//   }
// }
