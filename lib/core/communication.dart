import 'dart:async';
import 'dart:typed_data';

abstract class Communication {
  Future<void> write(Uint8List bytes);

  Future<void> connect();
  Future<void> disconnect();

  Future<Uint8List> readByte({int? timeout}) {
    return read(1, timeout: timeout);
  }

  Future<Uint8List> read(int bytes, {int? timeout});

  void reset();
}
