import 'package:datecs_fiscal_device/core/commands.dart';
import 'package:datecs_fiscal_device/core/exceptions.dart';
import 'package:datecs_fiscal_device/core/message.dart';
import 'package:datecs_fiscal_device/core/parser.dart';
import 'package:datecs_fiscal_device/core/status.dart';
import 'package:datecs_fiscal_device/utils/encode_ascii_hex.dart';
import 'package:datecs_fiscal_device/utils/extension.dart';
import 'package:datecs_fiscal_device/utils/log_message.dart';
import 'package:datecs_fiscal_device/utils/parameters.dart';
import 'package:datecs_fiscal_device/utils/enums.dart';
import 'package:datecs_fiscal_device/utils/separators.dart';
import 'package:datecs_fiscal_device/utils/static_bytes.dart';
import 'package:datecs_fiscal_device/utils/to_ascii.dart';
import 'package:flutter/foundation.dart';

part '../devices/bc_50.dart';

sealed class Device extends Parser {
  int sequance = 0x20; //range form 0x20 to 0xFF

  Status? _status;
  Status? get lastStatus => _status;

  Device(super.comm);

  Uint8List _critialStatus = Uint8List(8);

  void setCriticalStatus(Uint8List status) {
    assert(
      status.length == 8,
      "Critical status must be 8 bytes long, but was ${status.length} bytes.",
    );
    _critialStatus = status;
  }

  Future<Status> getStatus() {
    return execute(Commands.status.code).then((m) => m.status);
  }

  Future<Message> execute(int command, {String? data}) async {
    await writePackage(command, data: data);

    final message = await readPackage();
    _status = message.status;
    if (command != Commands.status.code) {
      final exeptions = _status?.criticalStatuses(_critialStatus);
      if (exeptions != null && exeptions.isNotEmpty) {
        throw FiscalParserException(
          "Critical status detected: ${exeptions.join('; ')}",
          10,
        );
      }
    }
    return message;
  }

  Future<void> writePackage(int command, {String? data}) async {
    _updateSequence();
    final message = packMessage(command, data: data);

    if (kDebugMode) {
      debugPrint("Sending message: ${message.debug()}");
    }

    reset();
    await comm.write(message);
  }

  Future<Message> readPackage() {
    return parseBuffer();
  }

  void _updateSequence() {
    sequance++;
    if (sequance > 0xFF) {
      sequance = 0x20; // Reset sequence number if it exceeds 0x7F
    }
  }

  /*
  * This method packs a message for the fiscal printer.Records are packed in a specific format:
  *
  * 1. PRE (0x01) - Pre-amble, a fixed byte indicating the start of the message
  * 2. LEN (4 bytes) - Length of the message, excluding PRE and EOT
  *   - LEN = 4 (LEN) + 1 (SEQ) + 4 (CMD) + data.length + 1 (PST) + 0x20
  * 3. SEQ (0x20) - Sequence number used to identify the message
  * 4. CMD (4 bytes) - Command code, e.g. 0x23
  * 5. DATA (plain ASCII bytes) - The data to be sent, encoded in CP1251
  * 6. PST (0x05) - Postamble, a fixed byte indicating the end of the data section
  * 7. BCC (4 bytes) - Block Check Character, calculated as the sum of all bytes from LEN to PST
  * 8. EOT (0x03) - End of transmission, a fixed byte indicating the end of the message
  *
  * The BCC is calculated as the sum of all bytes from LEN to PST, and is represented as a 4-digit hexadecimal number.
  *
  * The template of the message is as follows:
  *  [PRE][LEN][SEQ][CMD][DATA][PST][BCC][EOT]
  *
  */
  Uint8List packMessage(int command, {String? data}) {
    List<int> message = [];

    debugPrint(
      "Command: 0x${command.toRadixString(16).padLeft(2, '0').toUpperCase()}",
    );
    debugPrint("Data to be send: ${data?.readable}");

    // PRE
    message.add(Separator.PRE.value);

    // LEN = 4 (LEN) + 1 (SEQ) + 4 (CMD) + data.length + 1 (PST) + 0x20
    final dataBytes = toAscii(data);
    final lenValue =
        StaticBytes.LEN.size +
        StaticBytes.SEQ.size +
        StaticBytes.CMD.size +
        dataBytes.length +
        StaticBytes.PST.size +
        0x20;
    message.addAll(encodeAsciiHex(lenValue));

    // SEQ
    message.add(sequance);

    // CMD (e.g. 0x23 → '0023' → ASCII hex)
    message.addAll(encodeAsciiHex(command));

    // DATA (plain ASCII bytes)
    message.addAll(dataBytes);

    // PST
    message.add(Separator.PST.value);

    // BCC (sum from LEN to PST)
    final bccEndIndex = message.lastIndexOf(Separator.PST.value) + 1;
    final bccSum = message
        .sublist(StaticBytes.LEN.offset, bccEndIndex)
        .fold<int>(0, (a, b) => a + b);
    message.addAll(encodeAsciiHex(bccSum));

    // EOT
    message.add(Separator.EOT.value);

    return Uint8List.fromList(message);
  }
}
