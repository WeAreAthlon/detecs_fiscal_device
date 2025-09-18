import 'dart:typed_data';

class Status {
  final Uint8List raw;

  Status(this.raw)
    : assert(raw.length == 8, 'FiscalStatus must be 8 bytes long');

  bool get coverOpen => _bit(0, 6);
  bool get commandCodeInvalid => _bit(0, 1);
  bool get syntaxError => _bit(0, 0);
  bool get overflow => _bit(1, 0);
  bool get commandNotPermitted => _bit(1, 1);
  bool get endOfPaper => _bit(2, 0);
  bool get errorAccessingFmData => _bit(4, 0);
  bool get fmDataFull => _bit(4, 4);
  bool get fiscalReceiptOpen => _bit(2, 3);
  bool get nonFiscalReceiptOpen => _bit(2, 5);
  bool get generalError => _bit(0, 5);

  bool _bit(int byteIndex, int bit) => _bitOf(raw, byteIndex, bit);

  bool _bitOf(Uint8List raw, int byteIndex, int bit) {
    assert(
      byteIndex < raw.length,
      'Byte index $byteIndex is out of bounds for raw data of length ${raw.length}.',
    );
    return (raw[byteIndex] & (1 << bit)) != 0;
  }

  Status.empty()
    : raw = Uint8List(8); // Create an empty status with all bits set to 0

  String get bytes => "[${raw.map((e) => e.toRadixString(2)).join(' ')}]";

  List<String> criticalStatuses(Uint8List criticalStatus) {
    assert(
      criticalStatus.length == 8,
      'Critical status must be 8 bytes long, but was ${criticalStatus.length} bytes.',
    );
    List<String> exeptions = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 7; j >= 0; j--) {
        final negative = netagiveStatuses[(i, j)] ?? false;
        final bitStatus = _bitOf(raw, i, j);
        final bitError = negative ? !bitStatus : bitStatus;

        if (_bitOf(criticalStatus, i, j) && bitError) {
          exeptions.add(statusDescription(i, j));
        }
      }
    }
    return exeptions;
  }

  String statusDescription(int byteIndex, int bit) {
    return statusMessages[(byteIndex, bit)] ?? "Unknown status";
  }

  @override
  String toString() {
    return '''Status {
    coverOpen: $coverOpen,
    commandCodeInvalid: $commandCodeInvalid,
    syntaxError: $syntaxError,
    overflow: $overflow,
    commandNotPermitted: $commandNotPermitted,
    endOfPaper: $endOfPaper,
    errorAccessingFmData: $errorAccessingFmData,
    fmDataFull: $fmDataFull,
    fiscalReceiptOpen: $fiscalReceiptOpen,
    nonFiscalReceiptOpen: $nonFiscalReceiptOpen,
    generalError: $generalError
  }''';
  }
}

final Map<(int, int), bool> netagiveStatuses = {
  (0, 7): true,
  (1, 7): true,
  (2, 7): true,
  (3, 7): true,
  (4, 7): true,
  (4, 2): true,
  (4, 1): true,
  (5, 7): true,
  (5, 3): true,
  (5, 4): true,
  (5, 1): true,
  (6, 7): true,
};

final Map<(int, int), String> statusMessages = {
  // Byte 0
  (0, 7): "For internal use  1",
  (0, 6): "Cover is open",
  (0, 5): "General error - this is OR of all errors marked with #",
  (0, 4): "# Failure in printing mechanism.",
  (0, 3): "For internal use  0",
  (0, 2): "The real time clock is not synchronized",
  (0, 1): "# Command code is invalid.",
  (0, 0): "# Syntax error.",

  // Byte 1
  (1, 7): "For internal use  1",
  (1, 6): "For internal use  0",
  (1, 5): "For internal use  0",
  (1, 4): "For internal use  0",
  (1, 3): "For internal use  0",
  (1, 2): "Always 0",
  (1, 1): "# Command is not permitted'",
  (1, 0): "# Overflow during command execution",

  // Byte 2
  (2, 7): "For internal use  1",
  (2, 6): "For internal use  0",
  (2, 5): "Nonfiscal receipt is open",
  (2, 4): "EJ nearly full",
  (2, 3): "Fiscal receipt is open",
  (2, 2): "EJ is full",
  (2, 1): "Paper near end",
  (2, 0): "# End of paper",

  // Byte 3
  (3, 7): "For internal use  1",
  (3, 6): "For internal use  0",
  (3, 5): "For internal use  0",
  (3, 4): "For internal use  0",
  (3, 3): "For internal use  0",
  (3, 2): "For internal use  0",
  (3, 1): "For internal use  0",
  (3, 0): "For internal use  0",

  // Byte 4
  (4, 7): "For internal use  1",
  (4, 6): "Fiscal memory is not found or damaged",
  (4, 5): "OR of all errors marked with * from Bytes 4 - 5",
  (4, 4): "* Fiscal memory is full",
  (4, 3): "There is space for less than 60 reports in Fiscal memory",
  (4, 2): "Serial number and number of FM are set",
  (4, 1): "Tax number is set",
  (4, 0): "* Error accessing data in the FM",

  // Byte 5
  (5, 7): "For internal use  1",
  (5, 6): "For internal use  0",
  (5, 5): "For internal use  0",
  (5, 4): "VAT are set at least once",
  (5, 3): "Device is fiscalized",
  (5, 2): "For internal use  0",
  (5, 1): "FM is formated",
  (5, 0): "For internal use  0",

  // Byte 6
  (6, 7): "For internal use  1",
  (6, 6): "For internal use  0",
  (6, 5): "For internal use  0",
  (6, 4): "For internal use  0",
  (6, 3): "For internal use  0",
  (6, 2): "For internal use  0",
  (6, 1): "For internal use  0",
  (6, 0): "For internal use  0",

  // Byte 7
  (7, 7): "For internal use  1",
  (7, 6): "For internal use  0",
  (7, 5): "For internal use  0",
  (7, 4): "For internal use  0",
  (7, 3): "For internal use  0",
  (7, 2): "For internal use  0",
  (7, 1): "For internal use  0",
  (7, 0): "For internal use  0",
};
