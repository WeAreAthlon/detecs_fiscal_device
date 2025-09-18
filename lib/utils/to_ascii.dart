import 'package:datecs_fiscal_device/utils/cp1251_map.dart';

List<int> toAscii(String? data) {
  final List<int> output = [];
  if (data == null) {
    return output;
  }

  for (int codePoint in data.runes) {
    if (codePoint < 0x80) {
      output.add(codePoint);
    } else if (cp1251[codePoint] != null) {
      output.add(cp1251[codePoint]!);
    } else {
      output.add(codePoint);
    }
  }
  return output;
}
