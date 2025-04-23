import 'dart:io';
import 'dart:math';

import '../manager/toast_manager.dart';

enum ConvertType {
  binary(name: "Binary", symbol: '₂', power: '2'),
  decimal(name: "Decimal", symbol: '₁₀'),
  hexadecimal(name: "Hexadecimal", symbol: '₁₆', power: '16'),
  octal(name: "Octal", symbol: '₈', power: '8'),
  bcd(name: "Binary Coded Decimal", symbol: 'BCD'),
  gray(name: "Code Gray", symbol: 'G'),
  excess3(name: "Excess-3", symbol: 'xs-3');

  final String name;
  final String symbol;
  final String? power;

  const ConvertType({required this.name, required this.symbol, this.power});
}

class ConversionManager {
  final Map<String, String> _superscriptMap = {
    '0': '\u2070',
    '1': '\u00b9',
    '2': '\u00b2',
    '3': '\u00b3',
    '4': '\u2074',
    '5': '\u2075',
    '6': '\u2076',
    '7': '\u2077',
    '8': '\u2078',
    '9': '\u2079',
    '-': '\u207B',
  };

  final Map<String, int> _hexadecimalLetterMap = {
    'A': 10,
    'B': 11,
    'C': 12,
    'D': 13,
    'E': 14,
    'F': 15,
  };

  final Map<int, String> _hexadecimalNumberMap = {
    10: 'A',
    11: 'B',
    12: 'C',
    13: 'D',
    14: 'E',
    15: 'F',
  };

  late String _value;
  late ConvertType _convertFrom;
  late ConvertType _convertTo;
  late bool _showExplain;
  late bool _themeToggle;

  ConversionManager({
    required String value,
    required ConvertType from,
    required ConvertType to,
    required bool explain,
    required bool themeToggle,
  }) {
    _value = value;
    _convertFrom = from;
    _convertTo = to;
    _showExplain = explain;
    _themeToggle = themeToggle;
  }

  String _binaryToDecimal({String? value}) {
    value ??= _value;
    if (!value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Binary format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String binaryWithoutFraction({String? val}) {
      val ??= value;
      List<String> binaryList = value!.split('');
      List<int> rawResult = [];

      for (int i = 0; i < binaryList.length; i++) {
        int binary = int.parse(binaryList.elementAt(i));
        if (binary == 0) {
          rawResult.add(0);
          continue;
        }

        rawResult.add(pow(2, (binaryList.length - 1) - i).toInt());
      }
      int result = rawResult.reduce((num1, num2) => num1 + num2);
      return result.toString();
    }

    String binaryWithFraction() {
      List<String> binaryPart = _value.split(RegExp(r'[.,]'));
      String integerBinary = binaryPart.elementAt(0);
      String fractionBinary = binaryPart.elementAt(1);

      List<String> binaryList = fractionBinary.split('');
      List<double> rawResult = [];

      for (int i = 0; i < binaryList.length; i++) {
        int binary = int.parse(binaryList.elementAt(i));
        if (binary == 0) {
          rawResult.add(0);
          continue;
        }
        rawResult.add(pow(2, -(i + 1)).toDouble());
      }

      double integerResult = double.parse(
        binaryWithoutFraction(val: integerBinary),
      );
      double fractionResult = rawResult.reduce((num1, num2) => num1 + num2);
      double result = integerResult + fractionResult;
      return result.toString();
    }

    return _value.contains(RegExp(r'[.,]'))
        ? binaryWithFraction()
        : binaryWithoutFraction();
  }

  String _decimalToBinary() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[\d.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Decimal format must any integer",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String decimalWithoutFraction({String? value}) {
      value ??= _value;
      final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

      List<int> remains = [];
      List<int> result = [];
      int decimal = int.parse(value);
      int remain = decimal % 2;

      while (true) {
        if (decimal > 0) {
          remains.add(remain);
          result.add(remain);

          decimal = (decimal / 2).toInt();
          remain = decimal % 2;
        } else {
          if (numRegex.hasMatch(decimal.toString()) && result.length < 4) {
            result.add(0);
          } else {
            break;
          }
        }
      }
      return result.reversed.join().toString();
    }

    String decimalWithFraction() {
      List<String> decimalPart = _value.split(RegExp(r'[.,]'));
      String integerDecimal = decimalPart.elementAt(0);
      String fractionDecimal = decimalPart.elementAt(1);

      List<int> remains = [];
      int maxFractionLimit = 10;

      double convertToDecimal(String decimal) {
        int div = int.parse('1${List.filled(decimal.length, '0').join()}');
        return int.parse(decimal) / div;
      }

      double decimal = convertToDecimal(fractionDecimal) * 2;
      int remain = decimal.toInt();

      while (true) {
        remains.add(remain);
        if (decimal.toString().substring(2) != '0' &&
            remains.length < maxFractionLimit) {
          decimal = convertToDecimal(decimal.toString().substring(2)) * 2;
          remain = decimal.toInt();
        } else {
          break;
        }
      }

      String integerResult = decimalWithoutFraction(value: integerDecimal);
      String fractionResult = remains.join();
      String result = '$integerResult.$fractionResult';
      return result;
    }

    return _value.contains(RegExp(r'[.,]'))
        ? decimalWithFraction()
        : decimalWithoutFraction();
  }

  String _binaryToHexadecimal({String? value}) {
    value ??= _value;

    if (!value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Binary format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> binaryPartMap = {};
    List<String> binaryParts = value.split(RegExp(r'[.,]'));

    String integerBinary = binaryParts.elementAt(0);
    integerBinary = integerBinary.padLeft(
      (integerBinary.length + 3) ~/ 4 * 4, '0',
    );
    List<String> binaryIntegerList = integerBinary
      .splitMapJoin(
        RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '',
      )
      .split(',')..removeLast();
    binaryPartMap.putIfAbsent("integer", () => binaryIntegerList);

    if (binaryParts.length != 1) {
      String fractionBinary = binaryParts.elementAt(1);
      fractionBinary = fractionBinary.padRight(
        (fractionBinary.length + 3) ~/ 4 * 4, '0',
      );
      List<String> binaryFractionList = fractionBinary
        .splitMapJoin(
          RegExp('.{1,4}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '',
        )
        .split(',')..removeLast();
      binaryPartMap.putIfAbsent("fraction", () => binaryFractionList);
    }

    List<int> rawResult = [];
    String result = "";

    for (var valueList in binaryPartMap.values) {
      for (String value in valueList) {
        List<String> binaryPart = value.split('');

        for (int i = 0; i < binaryPart.length; i++) {
          int binary = int.parse(binaryPart.elementAt(i));
          if (binary == 0) {
            rawResult.add(0);
            continue;
          }
          rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
        }

        int total = rawResult.reduce((num1, num2) => num1 + num2);
        result +=
            total < 10
                ? total.toString()
                : _hexadecimalNumberMap[total].toString();
        rawResult.clear();
      }

      if (value.contains(RegExp(r'[.,]')) &&
          !result.contains(RegExp(r'[.,]'))) {
        result += '.';
      }
    }
    return result;
  }

  String _hexadecimalToBinary({String? value}) {
    value ??= _value;
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

    if (!value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[0-9a-fA-F.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Hexadecimal format must 0-9 and A-F",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<int>> hexPartMap = {};
    List<String> hexadecimalPart = value.split(RegExp(r'[.,]'));

    String integerHexadecimal = hexadecimalPart.elementAt(0);
    List<int> hexIntegerList =
        integerHexadecimal.split('').map((hex) {
          final letterRegex = RegExp(r'^([a-fA-F])$');

          if (letterRegex.hasMatch(hex)) {
            return int.parse(_hexadecimalLetterMap[hex].toString());
          } else if (numRegex.hasMatch(hex)) {
            return int.parse(hex);
          } else {
            return 0;
          }
        }).toList();
    hexPartMap.putIfAbsent("integer", () => hexIntegerList);

    if (hexadecimalPart.length != 1) {
      String fractionHexadecimal = hexadecimalPart.elementAt(1);
      List<int> hexFractionList =
          fractionHexadecimal.split('').map((hex) {
            final letterRegex = RegExp(r'^([a-fA-F])$');

            if (letterRegex.hasMatch(hex)) {
              return int.parse(_hexadecimalLetterMap[hex].toString());
            } else if (numRegex.hasMatch(hex)) {
              return int.parse(hex);
            } else {
              return 0;
            }
          }).toList();
      hexPartMap.putIfAbsent("fraction", () => hexFractionList);
    }

    List<int> rawResult = [];
    List<String> result = [];

    for (var valueList in hexPartMap.values) {
      for (int value in valueList) {
        int hexadecimal = value;
        int remain = hexadecimal % 2;

        while (true) {
          if (hexadecimal > 0) {
            rawResult.add(remain);

            hexadecimal = (hexadecimal / 2).toInt();
            remain = hexadecimal % 2;
          } else {
            if (numRegex.hasMatch(hexadecimal.toString()) &&
                rawResult.length < 4) {
              rawResult.add(0);
            } else {
              result.add(rawResult.reversed.join().toString());
              rawResult.clear();
              break;
            }
          }
        }
      }
      if (value.contains(RegExp(r'[.,]')) &&
          !result.join().contains(RegExp(r'[.,]'))) {
        result.add('.');
      }
    }
    return result.join(' ');
  }

  String _decimalToHexadecimal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[\d.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Decimal format must any integer",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String decimalWithoutFraction({String? value}) {
      value ??= _value;

      List<int> remains = [];
      List<String> result = [];
      int decimal = int.parse(value);
      int remain = decimal % 16;

      while (true) {
        if (decimal > 0) {
          remains.add(remain);
          result.add(
            remain < 10
                ? remain.toString()
                : _hexadecimalNumberMap[remain].toString(),
          );

          decimal = (decimal / 16).toInt();
          remain = decimal % 16;
        } else {
          break;
        }
      }
      return result.reversed.join().toString();
    }

    String decimalWithFraction() {
      List<String> decimalPart = _value.split(RegExp(r'[.,]'));
      String integerDecimal = decimalPart.elementAt(0);
      String fractionDecimal = decimalPart.elementAt(1);

      List<int> remains = [];
      int maxFractionLimit = 10;

      double convertToDecimal(String decimal) {
        int div = int.parse('1${List.filled(decimal.length, '0').join()}');
        return int.parse(decimal) / div;
      }

      double decimal = convertToDecimal(fractionDecimal) * 16;
      int remain = decimal.toInt();

      while (true) {
        remains.add(remain);
        if (decimal.toString().substring(remain.toString().length + 1) != '0' &&
            remains.length < maxFractionLimit) {
          decimal =
              convertToDecimal(
                decimal.toString().substring(remain.toString().length + 1)) * 16;
          remain = decimal.toInt();
        } else {
          break;
        }
      }

      String integerResult = decimalWithoutFraction(value: integerDecimal);
      String fractionResult =
          remains
              .map((val) =>
                      val < 10
                          ? val.toString()
                          : _hexadecimalNumberMap[val].toString(),
              ).join();
      String result = '$integerResult.$fractionResult';
      return result;
    }

    return _value.contains(RegExp(r'[.,]'))
        ? decimalWithFraction()
        : decimalWithoutFraction();
  }

  String _hexadecimalToDecimal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[1-9a-fA-F.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Hexadecimal format must 0-9 and A-F",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String hexWithoutFraction({String? value}) {
      value ??= _value;
      List<String> rawHex = value.split('');
      List<int> hexList =
          rawHex.map((hex) {
            final letterRegex = RegExp(r'^([a-fA-F])$');
            final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

            if (letterRegex.hasMatch(hex)) {
              return int.parse(_hexadecimalLetterMap[hex].toString());
            } else if (numRegex.hasMatch(hex)) {
              return int.parse(hex);
            } else {
              return 0;
            }
          }).toList();
      List<int> rawResult = [];

      for (int i = 0; i < hexList.length; i++) {
        int hexadecimal = hexList.elementAt(i);
        rawResult.add(hexadecimal * pow(16, (hexList.length - 1) - i).toInt());
      }

      int result = rawResult.reduce((num1, num2) => num1 + num2);
      return result.toString();
    }

    String hexWithFraction() {
      List<String> hexadecimalPart = _value.split(RegExp(r'[.,]'));
      String integerHexadecimal = hexadecimalPart.elementAt(0);
      String fractionHexadecimal = hexadecimalPart.elementAt(1);

      List<String> rawHexadecimalList = fractionHexadecimal.split('');
      List<int> hexadecimalList =
          rawHexadecimalList.map((hex) {
            final letterRegex = RegExp(r'^([a-fA-F])$');
            final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

            if (letterRegex.hasMatch(hex)) {
              return int.parse(_hexadecimalLetterMap[hex].toString());
            } else if (numRegex.hasMatch(hex)) {
              return int.parse(hex);
            } else {
              return 0;
            }
          }).toList();
      List<double> rawResult = [];

      for (int i = 0; i < hexadecimalList.length; i++) {
        int hexadecimal = hexadecimalList.elementAt(i);
        if (hexadecimal == 0) {
          rawResult.add(0);
          continue;
        }
        rawResult.add(hexadecimal * pow(16, -(i + 1)).toDouble());
      }

      double integerResult = double.parse(
        hexWithoutFraction(value: integerHexadecimal),
      );
      double fractionResult = rawResult.reduce((num1, num2) => num1 + num2);
      double result = integerResult + fractionResult;
      return result.toString();
    }

    return _value.contains(RegExp(r'[.,]'))
        ? hexWithFraction()
        : hexWithoutFraction();
  }

  String _binaryToOctal({String? value}) {
    value ??= _value;

    if (!value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Binary format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> binaryPartMap = {};
    List<String> binaryParts = value.split(RegExp(r'[.,]'));

    String integerBinary = binaryParts.elementAt(0);
    integerBinary = integerBinary.padLeft(
      (integerBinary.length + 2) ~/ 3 * 3, '0',
    );
    List<String> binaryIntegerList = integerBinary
      .splitMapJoin(
        RegExp('.{1,3}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '',
      )
      .split(',')..removeLast();
    binaryPartMap.putIfAbsent("integer", () => binaryIntegerList);

    if (binaryParts.length != 1) {
      String fractionBinary = binaryParts.elementAt(1);
      fractionBinary = fractionBinary.padRight(
        (fractionBinary.length + 2) ~/ 3 * 3, '0',
      );
      List<String> binaryFractionList = fractionBinary
        .splitMapJoin(
          RegExp('.{1,3}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '',
        )
        .split(',')..removeLast();
      binaryPartMap.putIfAbsent("fraction", () => binaryFractionList);
    }

    List<int> rawResult = [];
    String result = "";

    for (var valueList in binaryPartMap.values) {
      for (String value in valueList) {
        List<String> binaryPart = value.split('');

        for (int i = 0; i < binaryPart.length; i++) {
          int binary = int.parse(binaryPart.elementAt(i));
          if (binary == 0) {
            rawResult.add(0);
            continue;
          }
          rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
        }
        result += (rawResult.reduce((num1, num2) => num1 + num2)).toString();
        rawResult.clear();
      }

      if (value.contains(RegExp(r'[.,]')) &&
          !result.contains(RegExp(r'[.,]'))) {
        result += '.';
      }
    }
    return result;
  }

  String _octalToBinary({String? value}) {
    value ??= _value;
    final numRegex = RegExp(r'^([0-7])$');

    if (!value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[0-7.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Octal format must 0-7",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> octalPartMap = {};
    List<String> octalPart = value.split(RegExp(r'[.,]'));

    String integerOctal = octalPart.elementAt(0);
    List<String> octalIntegerList = integerOctal.split('');
    octalPartMap.putIfAbsent("integer", () => octalIntegerList);

    if (octalPart.length != 1) {
      String fractionOctal = octalPart.elementAt(1);
      List<String> octalFractionList = fractionOctal.split('');
      octalPartMap.putIfAbsent("fraction", () => octalFractionList);
    }

    List<int> rawResult = [];
    String result = "";

    for (var valueList in octalPartMap.values) {
      for (String value in valueList) {
        int octal = int.parse(value);
        int remain = octal % 2;

        while (true) {
          if (octal > 0) {
            rawResult.add(remain);

            octal = (octal / 2).toInt();
            remain = octal % 2;
          } else {
            if (numRegex.hasMatch(octal.toString()) && rawResult.length < 3) {
              rawResult.add(0);
            } else {
              result += rawResult.reversed.join().toString();
              rawResult.clear();
              break;
            }
          }
        }
      }
      if (value.contains(RegExp(r'[.,]')) &&
          !result.contains(RegExp(r'[.,]'))) {
        result += '.';
      }
    }
    return result;
  }

  String _decimalToOctal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[\d.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Decimal format must any integer",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String decimalWithoutFraction({String? value}) {
      value ??= _value;

      List<int> remains = [];
      List<String> result = [];
      int decimal = int.parse(value);
      int remain = decimal % 8;

      while (true) {
        if (decimal > 0) {
          remains.add(remain);
          result.add(remain.toString());

          decimal = (decimal / 8).toInt();
          remain = decimal % 8;
        } else {
          break;
        }
      }
      return result.reversed.join().toString();
    }

    String decimalWithFraction() {
      List<String> decimalPart = _value.split(RegExp(r'[.,]'));
      String integerDecimal = decimalPart.elementAt(0);
      String fractionDecimal = decimalPart.elementAt(1);

      List<int> remains = [];
      int maxFractionLimit = 10;

      double convertToDecimal(String decimal) {
        int div = int.parse('1${List.filled(decimal.length, '0').join()}');
        return int.parse(decimal) / div;
      }

      double decimal = convertToDecimal(fractionDecimal) * 8;
      int remain = decimal.toInt();

      while (true) {
        remains.add(remain);
        if (decimal.toString().substring(remain.toString().length + 1) != '0' &&
            remains.length < maxFractionLimit) {
          decimal =
              convertToDecimal(
                decimal.toString().substring(remain.toString().length + 1)) * 8;
          remain = decimal.toInt();
        } else {
          break;
        }
      }

      String integerResult = decimalWithoutFraction(value: integerDecimal);
      String fractionResult = remains.join();
      String result = '$integerResult.$fractionResult';
      return result;
    }

    return _value.contains(RegExp(r'[.,]'))
        ? decimalWithFraction()
        : decimalWithoutFraction();
  }

  String _octalToDecimal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[0-7.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Octal format must 0-7",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String octalWithoutFraction({String? value}) {
      value ??= _value;
      List<String> rawOctal = value.split('');
      List<int> rawResult = [];

      for (int i = 0; i < rawOctal.length; i++) {
        int octal = int.parse(rawOctal.elementAt(i));
        rawResult.add(octal * pow(8, (rawOctal.length - 1) - i).toInt());
      }
      int result = rawResult.reduce((num1, num2) => num1 + num2);
      return result.toString();
    }

    String octalWithFraction() {
      List<String> octalPart = _value.split(RegExp(r'[.,]'));
      String integerOctal = octalPart.elementAt(0);
      String fractionOctal = octalPart.elementAt(1);

      List<String> octalList = fractionOctal.split('');
      List<double> rawResult = [];

      for (int i = 0; i < octalList.length; i++) {
        int octal = int.parse(octalList.elementAt(i));
        if (octal == 0) {
          rawResult.add(0);
          continue;
        }
        rawResult.add(octal * pow(8, -(i + 1)).toDouble());
      }

      double integerResult = double.parse(
        octalWithoutFraction(value: integerOctal),
      );
      double fractionResult = rawResult.reduce((num1, num2) => num1 + num2);
      double result = integerResult + fractionResult;
      return result.toString();
    }

    return _value.contains(RegExp(r'[.,]'))
        ? octalWithFraction()
        : octalWithoutFraction();
  }

  String _hexadecimalToOctal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[0-9a-fA-F.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Hexadecimal format must 0-9 and A-F",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String binaryResult = _hexadecimalToBinary(value: _value);
    String octalResult = _binaryToOctal(
      value: binaryResult.replaceAll(' ', ''),
    );
    return octalResult.replaceFirst(octalResult[0], '');
  }

  String _octalToHexadecimal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[0-7.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Octal format must 0-7",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    String binaryResult = _octalToBinary(value: _value);
    String hexResult = _binaryToHexadecimal(value: binaryResult);
    return hexResult;
  }

  String _decimalToBCD() {
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[\d.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Decimal format must any integer",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> decimalPartMap = {};
    List<String> decimalPart = _value.split(RegExp(r'[.,]'));

    String integerDecimal = decimalPart.elementAt(0);
    List<String> decimalIntegerList = integerDecimal.split('');
    decimalPartMap.putIfAbsent("integer", () => decimalIntegerList);

    if (decimalPart.length != 1) {
      String fractionDecimal = decimalPart.elementAt(1);
      List<String> decimalFractionList = fractionDecimal.split('');
      decimalPartMap.putIfAbsent("fraction", () => decimalFractionList);
    }

    List<int> rawResult = [];
    List<String> result = [];

    for (var valueList in decimalPartMap.values) {
      for (String value in valueList) {
        int decimal = int.parse(value);
        int remain = decimal % 2;

        while (true) {
          if (decimal > 0) {
            rawResult.add(remain);

            decimal = (decimal / 2).toInt();
            remain = decimal % 2;
          } else {
            if (numRegex.hasMatch(decimal.toString()) && rawResult.length < 4) {
              rawResult.add(0);
            } else {
              result.add(rawResult.reversed.join());
              rawResult.clear();
              break;
            }
          }
        }
      }
      if (_value.contains(RegExp(r'[.,]')) &&
          !result.join().contains(RegExp(r'[.,]'))) {
        result.add('.');
      }
    }
    return result.join(' ');
  }

  String _bcdToDecimal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! BCD format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> bcdPartMap = {};
    List<String> bcdPart = _value.split(RegExp(r'[.,]'));

    String integerBCD = bcdPart.elementAt(0);
    integerBCD = integerBCD.padLeft((integerBCD.length + 3) ~/ 4 * 4, '0');
    List<String> bcdIntegerList = integerBCD
      .splitMapJoin(
        RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '',
      )
      .split(',')..removeLast();
    bcdPartMap.putIfAbsent("integer", () => bcdIntegerList);

    if (bcdPart.length != 1) {
      String fractionBCD = bcdPart.elementAt(1);
      fractionBCD = fractionBCD.padRight(
        (fractionBCD.length + 3) ~/ 4 * 4, '0',
      );
      List<String> bcdFractionList = fractionBCD
        .splitMapJoin(
          RegExp('.{1,4}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '',
        )
        .split(',')..removeLast();
      bcdPartMap.putIfAbsent("fraction", () => bcdFractionList);
    }

    List<int> rawResult = [];
    String result = "";

    for (var valueList in bcdPartMap.values) {
      for (String value in valueList) {
        List<String> binaryPart = value.split('');
        for (int i = 0; i < binaryPart.length; i++) {
          int binary = int.parse(binaryPart.elementAt(i));
          if (binary == 0) {
            rawResult.add(0);
            continue;
          }
          rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
        }

        int checkValid = rawResult.reduce((num1, num2) => num1 + num2);
        if (checkValid > 9) {
          ToastManager(
            msg: "Invalid Result! BCD value can't more than 10",
            textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
            theme: _themeToggle,
          ).create();
          return "N/A";
        }

        result += checkValid.toString();
        rawResult.clear();
      }

      if (_value.contains(RegExp(r'[.,]')) &&
          !result.contains(RegExp(r'[.,]'))) {
        result += '.';
      }
    }
    return result;
  }

  String _binaryToGray() {
    if (!_value.contains(RegExp(r'^[01]+$'))) {
      ToastManager(
        msg: "Invalid Format! Binary format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    List<String> rawGray = _value.split('');
    String gray = rawGray[0];

    for (int i = 1; i < rawGray.length; i++) {
      String result =
          (int.parse(rawGray[i - 1]) ^ int.parse(rawGray[i])).toString();
      gray += result;
    }
    return gray;
  }

  String _grayToBinary() {
    if (!_value.contains(RegExp(r'^[01]+$'))) {
      ToastManager(
        msg: "Invalid Format! Gray format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    List<String> rawBinary = _value.split('');
    String binary = rawBinary[0];

    for (int i = 1; i < rawBinary.length; i++) {
      String result =
          (int.parse(binary[i - 1]) ^ int.parse(rawBinary[i])).toString();
      binary += result;
    }
    return binary;
  }

  String _binaryToExcess3() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Excess-3 format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> xs3PartMap = {};
    List<String> xs3Part = _value.split(RegExp(r'[.,]'));

    String integerXS3 = xs3Part.elementAt(0);
    integerXS3 = integerXS3.padLeft((integerXS3.length + 3) ~/ 4 * 4, '0');
    List<String> xs3IntegerList = integerXS3
      .splitMapJoin(
        RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '',
      )
      .split(',')..removeLast();
    xs3PartMap.putIfAbsent("integer", () => xs3IntegerList);

    if (xs3Part.length != 1) {
      String fractionXS3 = xs3Part.elementAt(1);
      fractionXS3 = fractionXS3.padRight(
        (fractionXS3.length + 3) ~/ 4 * 4, '0',
      );
      List<String> xs3FractionList = fractionXS3
        .splitMapJoin(
          RegExp('.{1,4}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '',
        )
        .split(',')..removeLast();
      xs3PartMap.putIfAbsent("fraction", () => xs3FractionList);
    }

    String excess3Adder = "0011";
    List<String> xs3AdderList = excess3Adder.split('');
    List<int> rawResult = [];
    List<String> result = [];

    for (var valueList in xs3PartMap.values) {
      for (String valuePart in valueList) {
        int carry = 0;
        List<String> binaryPart = valuePart.split('');

        for (int i = binaryPart.length - 1; i >= 0; i--) {
          int binary = int.parse(binaryPart.elementAt(i));
          int excess3 = int.parse(xs3AdderList.elementAt(i));

          int xorResult = binary ^ excess3 ^ carry;
          carry = (binary & excess3) | (binary & carry) | (excess3 & carry);
          rawResult.add(xorResult);
        }

        if (carry == 1) rawResult.add(1);
        String checkValid = _binaryToDecimal(value: rawResult.reversed.join());
        if (int.parse(checkValid) > 12) {
          ToastManager(
            msg: "Invalid Result! Excess-3 value can't more than 12",
            textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
            theme: _themeToggle,
          ).create();
          return "N/A";
        }

        result.add(rawResult.reversed.join());
        rawResult.clear();
      }

      if (_value.contains(RegExp(r'[.,]')) &&
          !result.join().contains(RegExp(r'[.,]'))) {
        result.add('.');
      }
    }

    return result.join(' ');
  }

  String _excess3ToBinary() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Excess-3 format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> xs3PartMap = {};
    List<String> xs3Part = _value.split(RegExp(r'[.,]'));

    String integerXS3 = xs3Part.elementAt(0);
    integerXS3 = integerXS3.padLeft((integerXS3.length + 3) ~/ 4 * 4, '0');
    List<String> xs3IntegerList = integerXS3
      .splitMapJoin(
        RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '',
      )
      .split(',')..removeLast();
    xs3PartMap.putIfAbsent("integer", () => xs3IntegerList);

    if (xs3Part.length != 1) {
      String fractionXS3 = xs3Part.elementAt(1);
      fractionXS3 = fractionXS3.padRight(
        (fractionXS3.length + 3) ~/ 4 * 4, '0',
      );
      List<String> xs3FractionList = fractionXS3
        .splitMapJoin(
          RegExp('.{1,4}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '',
        )
        .split(',')..removeLast();
      xs3PartMap.putIfAbsent("fraction", () => xs3FractionList);
    }

    String excess3Adder = "0011";
    List<String> xs3AdderList = excess3Adder.split('');
    List<int> rawResult = [];
    List<String> result = [];

    for (var valueList in xs3PartMap.values) {
      for (String valuePart in valueList) {
        int borrow = 0;
        List<String> binaryPart = valuePart.split('');

        for (int i = binaryPart.length - 1; i >= 0; i--) {
          int binary = int.parse(binaryPart.elementAt(i));
          int excess3 = int.parse(xs3AdderList.elementAt(i));

          int xorResult = binary ^ excess3 ^ borrow;
          int notBinary = binary ^ 1;
          int notXOR = (binary ^ excess3) ^ 1;
          borrow = (notBinary & excess3) | (notXOR & borrow);

          rawResult.add(xorResult);
        }

        String checkValid = _binaryToDecimal(value: rawResult.reversed.join());
        if (int.parse(checkValid) < 3) {
          ToastManager(
            msg: "Invalid Result! Excess-3 value can't less than 0",
            textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
            theme: _themeToggle,
          ).create();
          return "N/A";
        }

        result.add(rawResult.reversed.join());
        rawResult.clear();
      }

      if (_value.contains(RegExp(r'[.,]')) &&
          !result.join().contains(RegExp(r'[.,]'))) {
        result.add('.');
      }
    }

    return result.join(' ');
  }

  String _decimalToExcess3() {
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[\d.,]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Decimal format must any integer",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> decimalPartMap = {};
    List<String> decimalPart = _value.split(RegExp(r'[.,]'));

    String integerDecimal = decimalPart.elementAt(0);
    List<String> decimalIntegerList =
        integerDecimal
            .split('')
            .map((val) => (int.parse(val) + 3).toString())
            .toList();
    decimalPartMap.putIfAbsent("integer", () => decimalIntegerList);

    if (decimalPart.length != 1) {
      String fractionDecimal = decimalPart.elementAt(1);
      List<String> decimalFractionList =
          fractionDecimal
              .split('')
              .map((val) => (int.parse(val) + 3).toString())
              .toList();
      decimalPartMap.putIfAbsent("fraction", () => decimalFractionList);
    }

    List<int> rawResult = [];
    List<String> result = [];

    for (var valueList in decimalPartMap.values) {
      for (String value in valueList) {
        int decimal = int.parse(value);
        int remain = decimal % 2;

        while (true) {
          if (decimal > 0) {
            rawResult.add(remain);

            decimal = (decimal / 2).toInt();
            remain = decimal % 2;
          } else {
            if (numRegex.hasMatch(decimal.toString()) && rawResult.length < 4) {
              rawResult.add(0);
            } else {
              result.add(rawResult.reversed.join());
              rawResult.clear();
              break;
            }
          }
        }
      }

      if (_value.contains(RegExp(r'[.,]')) &&
          !result.join().contains(RegExp(r'[.,]'))) {
        result.add('.');
      }
    }
    return result.join(' ');
  }

  String _excess3ToDecimal() {
    if (!_value.contains(
      RegExp(r'^(?![.,])(?!.*[.,].*[.,])[01,.]+(?<![.,])$'),
    )) {
      ToastManager(
        msg: "Invalid Format! Excess-3 format must 0 and 1",
        textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
        theme: _themeToggle,
      ).create();
      return "N/A";
    }

    Map<String, List<String>> xs3PartMap = {};
    List<String> xs3Part = _value.split(RegExp(r'[.,]'));

    String integerXS3 = xs3Part.elementAt(0);
    integerXS3 = integerXS3.padLeft((integerXS3.length + 3) ~/ 4 * 4, '0');
    List<String> xs3IntegerList = integerXS3
      .splitMapJoin(
        RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '',
      )
      .split(',')..removeLast();
    xs3PartMap.putIfAbsent("integer", () => xs3IntegerList);

    if (xs3Part.length != 1) {
      String fractionXS3 = xs3Part.elementAt(1);
      fractionXS3 = fractionXS3.padRight(
        (fractionXS3.length + 3) ~/ 4 * 4, '0',
      );
      List<String> xs3FractionList = fractionXS3
        .splitMapJoin(
          RegExp('.{1,4}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '',
        )
        .split(',')..removeLast();
      xs3PartMap.putIfAbsent("fraction", () => xs3FractionList);
    }

    List<int> rawResult = [];
    String result = "";

    for (var valueList in xs3PartMap.values) {
      for (String value in valueList) {
        List<String> binaryPart = value.split('');

        for (int i = 0; i < binaryPart.length; i++) {
          int binary = int.parse(binaryPart.elementAt(i));
          if (binary == 0) {
            rawResult.add(0);
            continue;
          }

          rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
        }

        int checkValid = rawResult.reduce((num1, num2) => num1 + num2) - 3;
        if (checkValid < 0) {
          ToastManager(
            msg: "Invalid Result! Excess-3 value can't less than 0",
            textSize: Platform.isWindows || Platform.isMacOS ? 18.0 : 14.0,
            theme: _themeToggle,
          ).create();
          return "N/A";
        }

        result += checkValid.toString();
        rawResult.clear();
      }

      if (_value.contains(RegExp(r'[.,]')) &&
          !result.contains(RegExp(r'[.,]'))) {
        result += '.';
      }
    }
    return result;
  }

  String? convert() {
    switch (_convertFrom) {
      case ConvertType.binary:
        switch (_convertTo) {
          case ConvertType.decimal:
            return _binaryToDecimal();
          case ConvertType.hexadecimal:
            return _binaryToHexadecimal();
          case ConvertType.octal:
            return _binaryToOctal();
          case ConvertType.gray:
            return _binaryToGray();
          case ConvertType.excess3:
            return _binaryToExcess3();
          default:
            return "Unknown";
        }
      case ConvertType.decimal:
        switch (_convertTo) {
          case ConvertType.binary:
            return _decimalToBinary();
          case ConvertType.hexadecimal:
            return _decimalToHexadecimal();
          case ConvertType.octal:
            return _decimalToOctal();
          case ConvertType.bcd:
            return _decimalToBCD();
          case ConvertType.excess3:
            return _decimalToExcess3();
          default:
            return "Unknown";
        }
      case ConvertType.hexadecimal:
        switch (_convertTo) {
          case ConvertType.binary:
            return _hexadecimalToBinary();
          case ConvertType.decimal:
            return _hexadecimalToDecimal();
          case ConvertType.octal:
            return _hexadecimalToOctal();
          default:
            return "Unknown";
        }
      case ConvertType.octal:
        switch (_convertTo) {
          case ConvertType.binary:
            return _octalToBinary();
          case ConvertType.decimal:
            return _octalToDecimal();
          case ConvertType.hexadecimal:
            return _octalToHexadecimal();
          default:
            return "Unknown";
        }
      case ConvertType.bcd:
        switch (_convertTo) {
          case ConvertType.decimal:
            return _bcdToDecimal();
          default:
            return "Unknown";
        }
      case ConvertType.gray:
        switch (_convertTo) {
          case ConvertType.binary:
            return _grayToBinary();
          default:
            return "Unknown";
        }
      case ConvertType.excess3:
        switch (_convertTo) {
          case ConvertType.binary:
            return _excess3ToBinary();
          case ConvertType.decimal:
            return _excess3ToDecimal();
          default:
            return "Unknown";
        }
    }
  }

  String addSuperscript(int number) {
    return number
        .toString()
        .split('')
        .map((script) => _superscriptMap[script.toString()])
        .join();
  }
}
