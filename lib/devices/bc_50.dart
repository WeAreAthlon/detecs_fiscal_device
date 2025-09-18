part of '../core/device.dart';

class BC50FiscalDevice extends Device {
  BC50FiscalDevice(super.comm);

  bool isFiscalOpen() {
    return lastStatus?.fiscalReceiptOpen ?? false;
  }

  bool isNonFiscalOpen() {
    return lastStatus?.nonFiscalReceiptOpen ?? false;
  }

  Future<void> openFiscalReceipt({
    required int opperatorCode,
    required String opperatorPassword,
    String? uniqueSaleNumber,
    required int salePoint,
    bool invoice = false,
  }) async {
    assert(
      opperatorCode >= 1 && opperatorCode <= 30,
      'opperatorCode must be in range 1..30',
    );
    assert(
      opperatorPassword.length <= 8,
      'opperatorPassword must 8 characters or less',
    );
    assert(
      salePoint >= 1 && salePoint <= 99999,
      'salePoint must be in range 1..99999',
    );
    assert(
      uniqueSaleNumber == null ||
          RegExp(
            r'^[A-Z]{2}[0-9]{6}-[0-9A-Za-z]{4}-[0-9]{7}$',
          ).hasMatch(uniqueSaleNumber),
      'Invalid format: must match "LLDDDDDD-CCCC-DDDDDDD"',
    );

    debugPrint('openFiscalReceipt');

    final message = await execute(
      Commands.openFiscalReceipt.code,
      data: [
        opperatorCode,
        opperatorPassword,
        if (uniqueSaleNumber != null) uniqueSaleNumber,
        salePoint,
        invoice ? "I" : "",
      ].toCommand(),
    );

    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error opening fiscal receipt', error);
    }
  }

  Future<void> registerSales({
    required String productName,
    required int taxCode,
    required double price,
    double? quantity,
    DiscountType? discountType,
    double? discountValue,
    required int department,
    String? unit,
  }) async {
    assert(productName.isNotEmpty, 'Product name must not be empty');
    assert(
      taxCode >= 1 && taxCode <= 8,
      'taxCode must be in range 1..8 (vat group A-H)',
    );
    assert(price > 0, 'Price must be greater than 0');
    assert(
      quantity == null || quantity > 0,
      'Quantity must be greater than 0 or null',
    );
    assert(
      discountValue == null || discountValue >= 0,
      'discountValue must be greater than or equal to 0',
    );
    assert(
      department >= 0 && department <= 99,
      'department must be in range 0..99. 0 is for no department',
    );
    assert(
      unit == null || unit.length <= 6 && unit.isNotEmpty,
      'unit must be 6 characters or less and not empty',
    );
    final message = await execute(
      Commands.registrationOfSale.code,
      data: [
        productName,
        taxCode,
        price,
        quantity?.cleanDouble(),
        discountType?.index,
        discountValue?.cleanDouble(),
        department,
        if (unit != null) unit,
      ].toCommand(),
    );
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error register sales', error);
    }
  }

  Future<double> getSubtotal({
    bool? print,
    bool? display,
    DiscountType? discountType,
    double? discountValue,
  }) async {
    final message = await execute(
      Commands.readSubtotal.code,
      data: [
        print?.toInt(),
        display?.toInt(),
        discountType?.index,
        discountValue?.cleanDouble(),
      ].toCommand(),
    );

    final [$e, slip, subtotal, ...taxes] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error register sales', error);
    }

    return double.tryParse(subtotal) ?? 0.0;
  }

  Future<void> receiptTotal({
    required int paidMode,
    required double amountToPay,
    int? paymentType,
    int? changeCurrency,
  }) async {
    assert(
      paidMode >= 0 && paidMode <= 6 || paidMode == 12,
      'paidMode must be in range 0..5 (0=cash, 1=credit card, 2=debit card, 3=other #3, 4=other #4, 5=other #5, 6=foreign currency, 12=payment with pinpad)',
    );
    assert(amountToPay >= 0, 'amountToPay must be greater than or equal to 0');
    assert(
      paymentType == null ||
          (paymentType == 1 && paymentType == 12 && paidMode != 6),
      'paymentType must be 1 or 12 (1=with money, 12=with loyalty points)',
    );
    assert(
      changeCurrency == null ||
          (changeCurrency >= 0 && changeCurrency <= 1 && paidMode == 6),
      'changeCurrency must be 0 or 1 (0=current currency, 1=foreign currency)',
    );
    final message = await execute(
      Commands.paymentAndTotalSum.code,
      data: [
        paidMode,
        amountToPay.cleanDouble(),
        if (paymentType != null) paymentType,
        if (changeCurrency != null) changeCurrency,
      ].toCommand(),
    );
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error payment and calculating totals', error);
    }
  }

  Future<void> printFiscalText({
    required String text,
    TextBold? bold,
    TextItalic? italic,
    TextHeight? height,
    TextUnderline? underline,
    TextAlign? alignment,
  }) async {
    final message = await execute(
      Commands.printingFreeFiscalText.code,
      data: [
        text,
        bold?.index,
        italic?.index,
        height?.index,
        underline?.index,
        alignment?.index,
      ].toCommand(),
    );
    final [$e] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error printing fiscal text', error);
    }
  }

  Future<TranscationStatus> getFiscalTransactionStatus() async {
    final message = await execute(Commands.statusOfFiscalTransaction.code);
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException(
        'Error getting fiscal transaction status',
        error,
      );
    }

    return TranscationStatus.fromMessage(message);
  }

  Future<void> closeFiscalReceipt() async {
    final message = await execute(Commands.closeFiscalReceipt.code);
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error closing fiscal receipt', error);
    }
  }

  Future<void> cancelFiscalReceipt() async {
    final message = await execute(Commands.cancelFiscalReceipt.code);
    final [$e] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error canceling fiscal receipt', error);
    }
  }

  Future<void> paperFeed({required int lines}) async {
    final message = await execute(
      Commands.feedPaper.code,
      data: [lines].toCommand(),
    );
    final [$e] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error feeding paper', error);
    }
  }

  Future<void> printSeparatingLine({required SeparatingLine type}) async {
    assert(
      type != SeparatingLine.none,
      'Separating line type must not be none',
    );

    final message = await execute(
      Commands.printSeparatingLine.code,
      data: [type.index].toCommand(),
    );
    final [$e] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error printing separating line', error);
    }
  }

  Future<String> generateUniqueSaleNumber({int? operator}) async {
    final currentOperator = operator ?? await getCurrentOperatorCode();
    final serial = await getSerialNumber();
    final number = await getNextFiscalReceiptNumber();

    return [
      serial,
      currentOperator.toString().padLeft(4, '0'),
      number.toString().padLeft(7, '0'),
    ].join('-');
  }

  Future<String> getUniqueSaleNumber() async {
    final uniqueSaleNumber = await readWriteParameter(
      name: Parameters.UNP.name,
    );

    if (uniqueSaleNumber == null || uniqueSaleNumber.isEmpty) {
      throw FiscalCodeException('Unique sale number is empty or not set', 0);
    }
    return uniqueSaleNumber;
  }

  Future<void> openNonFiscalReceipt() async {
    final message = await execute(Commands.openNonFiscalReceipt.code);
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error opening non-fiscal receipt', error);
    }
  }

  Future<void> printNonFiscalText({
    required String text,
    TextBold? bold,
    TextItalic? italic,
    TextHeight? height,
    TextUnderline? underline,
    TextAlign? alignment,
  }) async {
    final message = await execute(
      Commands.printingFreeNonFiscalText.code,
      data: [
        text,
        bold?.index,
        italic?.index,
        height?.index,
        underline?.index,
        alignment?.index,
      ].toCommand(),
    );
    final [$e] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error printing non-fiscal text', error);
    }
  }

  Future<void> closeNonFiscalReceipt() async {
    final message = await execute(Commands.closeNonFiscalReceipt.code);
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error closing non-fiscal receipt', error);
    }
  }

  Future<int> getCurrentOperatorCode() async {
    final code = await readWriteParameter(
      name: Parameters.CurrClerk.name,
      index: 0,
    );

    if (code == null || code.isEmpty) {
      throw FiscalCodeException('Current operator code is empty or not set', 0);
    }
    return int.parse(code);
  }

  Future<String> getCurrentOperatorPassword(int operator) async {
    final pass = await readWriteParameter(
      name: Parameters.OperPasw.name,
      index: operator - 1,
    );

    if (pass == null || pass.isEmpty) {
      throw FiscalCodeException(
        'Current operator password is empty or not set',
        0,
      );
    }
    return pass;
  }

  Future<String> getSerialNumber() async {
    final serial = await readWriteParameter(name: Parameters.IDnumber.name);

    if (serial == null || serial.isEmpty) {
      throw FiscalCodeException('Serial number is empty or not set', 0);
    }
    return serial;
  }

  Future<int> getNextFiscalReceiptNumber() async {
    final number = await readWriteParameter(name: Parameters.nFBon.name);

    if (number == null || number.isEmpty) {
      throw FiscalCodeException(
        'Next fiscal receipt number is empty or not set',
        0,
      );
    }
    return int.parse(number);
  }

  Future<String?> readWriteParameter({
    required String name,
    int? index,
    String? value,
  }) async {
    assert(name.isNotEmpty, 'Name must not be empty');
    assert(
      index == null || (index >= 0 && index <= 9999),
      'Index must be in range 0..9999',
    );
    assert(value == null || value.isNotEmpty, 'Value must not be empty');

    final message = await execute(
      Commands.readWriteParameter.code,
      data: [name, index, value].toCommand(),
    );
    final [$e, ...rest] = message.data.response;
    final error = int.tryParse($e) ?? 0;

    if (error != 0) {
      throw FiscalCodeException('Error getting parameter', error);
    }

    return rest.isNotEmpty ? rest.first : null;
  }
}
