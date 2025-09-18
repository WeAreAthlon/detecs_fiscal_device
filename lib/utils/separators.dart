enum Separator {
  PRE(0x01), // Start of message
  EOT(0x03), // End of transmission
  SEP(0x04), // Separator for data fields
  PST(0x05), // Postamble
  TAB(0x09); // Tab

  final int value;
  const Separator(this.value);
}

extension SeparatorExtension on Separator {
  String get char => String.fromCharCode(value);
}
