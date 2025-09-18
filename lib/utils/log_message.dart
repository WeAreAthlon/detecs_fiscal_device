import 'package:flutter/foundation.dart';

extension LogMessageExtension on Uint8List {
  String debug() {
    return map(
      (e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'),
    ).join(' ');
  }
}

extension HexLogMessageExtension on int {
  String debug() {
    return toRadixString(16).toUpperCase().padLeft(2, '0');
  }
}
