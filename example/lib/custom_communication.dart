import 'dart:typed_data';

import 'package:datecs_fiscal_device/core/communication.dart';

class CustomCommunication extends Communication {
  @override
  Future<void> connect() {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> read(int bytes, {int? timeout}) {
    throw UnimplementedError();
  }

  @override
  void reset() {
    throw UnimplementedError();
  }

  @override
  Future<void> write(Uint8List bytes) {
    throw UnimplementedError();
  }
}
