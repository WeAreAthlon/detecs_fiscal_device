import 'dart:typed_data';

import 'package:datecs_fiscal_device/core/communication.dart';
import 'package:datecs_fiscal_device/core/exceptions.dart';
import 'package:datecs_fiscal_device/core/message.dart';
import 'package:datecs_fiscal_device/core/status.dart';
import 'package:datecs_fiscal_device/utils/compute_checksum.dart';
import 'package:datecs_fiscal_device/utils/decode_Ascii_hex.dart';
import 'package:datecs_fiscal_device/utils/extension.dart';
import 'package:datecs_fiscal_device/utils/log_message.dart';
import 'package:datecs_fiscal_device/utils/separators.dart';
import 'package:datecs_fiscal_device/utils/static_bytes.dart';
import 'package:datecs_fiscal_device/utils/to_unicode.dart';
import 'package:flutter/foundation.dart';

abstract class IParser {
  Future<Message> parseBuffer();
}

abstract class Parser {
  final Communication comm;

  Parser(this.comm);

  Future<Message> parseBuffer() async {
    try {
      final message = BytesBuilder();

      // Read PRE
      final preBytes = await comm.read(StaticBytes.PRE.size);

      if (preBytes.isEmpty) {
        throw FiscalParserException('No data received from device.', 0);
      }

      if (kDebugMode) {
        message.add(preBytes);
      }

      if (preBytes.first != Separator.PRE.value) {
        throw FiscalParserException('Invalid PRE byte: ${preBytes.first}', 1);
      }

      // Read LEN
      final Uint8List lenBytes = await comm.read(StaticBytes.LEN.size);
      final decodedLen = decodeAsciiHex(lenBytes);
      final dataLength =
          decodedLen - StaticBytes.LEN.overhead - staticBytesInData;

      if (kDebugMode) {
        message.add(lenBytes);
        debugPrint("Received [LEN]: ${lenBytes.debug()}");
      }

      // Read SEQ
      final Uint8List seqBytes = await comm.read(StaticBytes.SEQ.size);

      if (kDebugMode) {
        message.add(seqBytes);
      }

      if (seqBytes.first < 0x20 || seqBytes.first > 0xFF) {
        throw FiscalParserException(
          'Invalid SEQ byte: ${seqBytes.first.debug()}',
          2,
        );
      }

      // Read CMD
      final Uint8List cmdBytes = await comm.read(StaticBytes.CMD.size);
      final cmd = decodeAsciiHex(cmdBytes);

      if (kDebugMode) {
        message.add(cmdBytes);
        debugPrint("Received [CMD]: ${cmdBytes.debug()}");
      }

      // Read DATA
      final Uint8List dataBytes = await comm.read(dataLength);
      final data = toUnicode(dataBytes);

      if (kDebugMode) {
        message.add(dataBytes);
        debugPrint("Received [DATA]: ${dataBytes.debug()}");
        debugPrint("Decoded data: ${data.readable}");
      }

      // Read SEP
      final Uint8List sepBytes = await comm.read(StaticBytes.SEP.size);

      if (kDebugMode) {
        message.add(sepBytes);
      }
      if (sepBytes.first != Separator.SEP.value) {
        throw FiscalParserException('Invalid SEP byte: ${sepBytes.first}', 3);
      }

      // Read STAT
      final Uint8List statBytes = await comm.read(StaticBytes.STAT.size);
      final status = Status(statBytes);
      if (kDebugMode) {
        message.add(statBytes);
        debugPrint("Received [STAT]: ${statBytes.debug()}");
        debugPrint("Received status: ${status.bytes}");
      }

      // Read PST
      final Uint8List pstBytes = await comm.read(StaticBytes.PST.size);
      if (kDebugMode) {
        message.add(pstBytes);
      }
      if (pstBytes.first != Separator.PST.value) {
        throw FiscalParserException(
          'Invalid PST byte: ${pstBytes.first.debug()}',
          4,
        );
      }

      // Read BCC
      final Uint8List bccBytes = await comm.read(StaticBytes.BCC.size);
      if (kDebugMode) {
        message.add(bccBytes);

        debugPrint("Received [BCC]: ${bccBytes.debug()}");
      }

      //Verify checksum (you need to implement this)
      final calculatedBcc = computeChecksum(
        lenBytes +
            seqBytes +
            cmdBytes +
            dataBytes +
            sepBytes +
            statBytes +
            pstBytes,
      );
      final parsedBcc = decodeAsciiHex(bccBytes);
      if (calculatedBcc != parsedBcc) {
        throw FiscalParserException(
          'Checksum mismatch: expected $calculatedBcc, got $parsedBcc',
          5,
        );
      }

      // Read EOT
      final [eot] = await comm.read(StaticBytes.EOT.size);
      if (kDebugMode) {
        message.add([eot]);
      }
      if (eot != Separator.EOT.value) {
        throw FiscalParserException('Invalid EOT byte: $eot', 6);
      }

      if (kDebugMode) {
        debugPrint("Received [MESSAGE]: ${message.toBytes().debug()}");
      }

      return Message(
        sequence: seqBytes.first,
        command: cmd,
        data: data,
        status: status,
      );
    } catch (e) {
      rethrow;
    }
  }

  void reset() {
    comm.reset();
  }
}
