import 'package:datecs_fiscal_device/utils/cp1251_map.dart';
import 'package:flutter/foundation.dart';

// Create reverse lookup table for CP1251
final Map<int, int> reverseCp1251 = {
  for (final entry in cp1251.entries) entry.value: entry.key,
};

String toUnicode(Uint8List bytes) {
  final buffer = StringBuffer();

  for (final byte in bytes) {
    if (byte < 0x80) {
      buffer.writeCharCode(byte);
    } else if (reverseCp1251.containsKey(byte)) {
      buffer.writeCharCode(reverseCp1251[byte]!);
    } else {
      buffer.writeCharCode(byte); // Fallback, may not render correctly
    }
  }

  return buffer.toString();
}
