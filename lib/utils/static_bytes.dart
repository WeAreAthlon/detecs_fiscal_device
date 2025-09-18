enum StaticBytes {
  PRE(1),
  LEN(4),
  SEQ(1),
  CMD(4),
  SEP(1),
  STAT(8),
  PST(1),
  BCC(4),
  EOT(1);

  final int size;
  const StaticBytes(this.size);
}

int get staticBytesInData {
  return StaticBytes.LEN.size +
      StaticBytes.SEQ.size +
      StaticBytes.CMD.size +
      StaticBytes.SEP.size +
      StaticBytes.STAT.size +
      StaticBytes.PST.size;
}

extension StaticBytesExtension on StaticBytes {
  int get offset {
    switch (this) {
      case StaticBytes.PRE:
        return 0;
      case StaticBytes.LEN:
        return StaticBytes.PRE.size;
      case StaticBytes.SEQ:
        return StaticBytes.LEN.offset + StaticBytes.LEN.size;
      case StaticBytes.CMD:
        return StaticBytes.SEQ.offset + StaticBytes.SEQ.size;
      default:
        return -1;
    }
  }

  int get overhead => this == StaticBytes.LEN ? 0x20 : 0;

  int get end {
    return offset + size;
  }
}
