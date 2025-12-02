import '../db/db_exceptions.dart';

Future<T> safeExec<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (e) {
    // Wrap all exceptions into DBQueryException for predictable handling
    throw DBQueryException(e.toString());
  }
}
