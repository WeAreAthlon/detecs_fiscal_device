int decodeAsciiHex(List<int> asciiBytes) {
  if (asciiBytes.isEmpty || asciiBytes.any((b) => b < 0x30)) {
    throw FormatException('Invalid ASCII-hex input');
  }

  final buffer = asciiBytes.map((c) {
    final hexDigit = c - 0x30;
    return hexDigit.toRadixString(16).toUpperCase();
  }).join();

  return int.parse(buffer, radix: 16);
}
