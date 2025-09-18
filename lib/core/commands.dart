import 'package:datecs_fiscal_device/core/message.dart';
import 'package:datecs_fiscal_device/utils/extension.dart';

enum Commands {
  status(0x4A),
  openFiscalReceipt(0x30),
  registrationOfSale(0x31),
  closeFiscalReceipt(0x38),
  cancelFiscalReceipt(0x3C),
  printingFreeFiscalText(0x36),
  readSubtotal(0x33),
  feedPaper(0x2C),
  paymentAndTotalSum(0x35),
  printSeparatingLine(0x5C),
  openNonFiscalReceipt(0x26),
  closeNonFiscalReceipt(0x27),
  printingFreeNonFiscalText(0x2A),
  statusOfFiscalTransaction(0x4C),
  readWriteParameter(0xFF);

  final int code;
  const Commands(this.code);
}

class TranscationStatus {
  final int isOpen;
  final int number;
  final int items;
  final double amount;
  final double paid;

  TranscationStatus({
    required this.isOpen,
    required this.number,
    required this.items,
    required this.amount,
    required this.paid,
  });

  factory TranscationStatus.fromMessage(Message message) {
    final data = message.data.response;

    return TranscationStatus(
      isOpen: int.parse(data[1]),
      number: int.parse(data[2]),
      items: int.parse(data[3]),
      amount: double.parse(data[4]),
      paid: double.parse(data[5]),
    );
  }

  @override
  String toString() {
    return '''TranscationStatus{
  isOpen: $isOpen,
  number: $number,
  items: $items,
  amount: $amount,
  paid: $paid
}''';
  }
}
