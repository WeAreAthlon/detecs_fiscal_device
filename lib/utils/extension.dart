import 'package:datecs_fiscal_device/utils/separators.dart';

extension FiscalData on List {
  String toCommand() {
    return map((e) => "${e ?? ""}${Separator.TAB.char}").join("");
  }
}

extension ResponseData on String {
  List<String> toResponse() {
    return trimRight().split(Separator.TAB.char);
  }

  List<String> get response {
    return trimRight().split(Separator.TAB.char);
  }

  String get readable {
    return codeUnits
        .map((e) {
          if (e == 0x9) return '[\\t]';
          if (e == 0x10) return '[\\n]';
          if (e == 0x13) return '[\\r]';
          return String.fromCharCode(e);
        })
        .join('');
  }
}

extension CleanDouble on double {
  String cleanDouble() =>
      this == roundToDouble() ? toInt().toString() : toString();
}

extension BoolToInt on bool {
  int toInt() => this ? 1 : 0;
}

extension Binary on int {
  int get b {
    return int.parse(toRadixString(10), radix: 2);
  }
}
