class FiscalParserException implements Exception {
  final String message;
  final int? code;
  FiscalParserException(this.message, [this.code]);

  @override
  String toString() =>
      'FiscalParserException: $message ${code != null ? "(code: $code)" : ""}';
}

class FiscalCodeException implements Exception {
  final String message;
  final int code;
  FiscalCodeException(this.message, this.code);

  @override
  String toString() => 'FiscalCodeException: (code: $code) $message';
}

class CommunicationCodeException implements Exception {
  final String message;
  final int code;
  CommunicationCodeException(this.message, this.code);

  @override
  String toString() => 'CommunicationCodeException: (code: $code) $message';
}
