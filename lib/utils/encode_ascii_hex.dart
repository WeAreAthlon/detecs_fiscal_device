List<int> encodeAsciiHex(int value) {
  final hexString = value.toRadixString(16).padLeft(4, '0').toUpperCase();

  return hexString.codeUnits.map((c) {
    final hexDigit = int.parse(String.fromCharCode(c), radix: 16);
    return 0x30 + hexDigit;
  }).toList();
}
