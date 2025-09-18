int computeChecksum(List<int> bytes) {
  int sum = bytes.fold(0, (a, b) => a + b);
  return sum & 0xFFFF; // Or however many bits are expected
}
