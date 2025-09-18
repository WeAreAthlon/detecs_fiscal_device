import 'package:datecs_fiscal_device/core/status.dart';
import 'package:datecs_fiscal_device/utils/extension.dart';

class Message {
  final int sequence;
  final int command;
  final String data;
  final Status status;
  String? message;

  Message({
    required this.sequence,
    required this.command,
    required this.data,
    required this.status,
    this.message,
  });

  @override
  String toString() {
    return '''
message: [$message];
Message {
  sequence: $sequence, 
  command: $command,
  dataReadable: ${data.readable},
  data: $data,
  status: $status
}''';
  }
}
