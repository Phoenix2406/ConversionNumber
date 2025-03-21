import 'dart:math';

import 'package:flutter/foundation.dart';

enum ConvertType {
  binary(name: "Binary", symbol: '₂', power: '2'),
  decimal(name: "Decimal", symbol: '₁₀'),
  hexadecimal(name: "Hexadecimal", symbol: '₁₆', power: '16'),
  octal(name: "Octal", symbol: '₈', power: '8'),
  bcd(name: "Binary Coded Decimal", symbol: 'BCD'),
  gray(name: "Code Gray", symbol: 'G'),
  excess3(name: "Excess-3", symbol: 'xs-3');

  const ConvertType({
    required this.name,
    required this.symbol,
    this.power,
  });

  final String name;
  final String symbol;
  final String? power;
}

enum PositionDirection {
  horizontal,
  vertical
}

class ConversionManager {
  final Map<String, Object> _stagesData = {};

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
    '9': '\u2079'
  };

  final Map<String, int> _hexadecimalLetterMap = {
    'A': 10,
    'B': 11,
    'C': 12,
    'D': 13,
    'E': 14,
    'F': 15
  };

  final Map<int, String> _hexadecimalNumberMap = {
    10: 'A',
    11: 'B',
    12: 'C',
    13: 'D',
    14: 'E',
    15: 'F'
  };

  final String value;
  final ConvertType convertFrom;
  final ConvertType convertTo;
  final bool showExplain;

  ConversionManager({
    required this.value,
    required this.convertFrom,
    required this.convertTo,
    required this.showExplain});

  String _binaryToDecimal() {
    List<String> binaryList = value.split('');
    List<int> rawResult = [];

    _stagesData.putIfAbsent("type", () => PositionDirection.horizontal);
    _stagesData.putIfAbsent("value", () => binaryList);

    for (int i = 0; i < binaryList.length; i++) {
      int binary = int.parse(binaryList.elementAt(i));
      if (binary == 0) {
        _stagesData.update("power", (list) => (list as List<String>)..add(' '),
            ifAbsent: () => [' ']);
        rawResult.add(0);
        continue;
      }

      _stagesData.update("power", (list) => (list as List<String>)..add("2${toSuperscript((binaryList.length - 1) - i)}"),
          ifAbsent: () => ["2${toSuperscript((binaryList.length - 1) - i)}"]);
      rawResult.add(pow(2, (binaryList.length - 1) - i).toInt());
    }
    int result = rawResult.reduce((num1, num2) => num1 + num2);

    _stagesData.putIfAbsent("rawResult", () => rawResult);
    _stagesData.putIfAbsent("result", () => result);

    if (kDebugMode) {
      print(_stagesData["type"]);
      print(_stagesData["value"]);
      print(_stagesData["power"]);
      print(_stagesData["rawResult"]);
      print(_stagesData["result"]);
    }
    return result.toString();
  }

  String _decimalToBinary() {
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

    List<int> remains = [];
    List<int> result = [];
    int decimal = int.parse(value);
    int remain = decimal % 2;

    _stagesData.putIfAbsent("type", () => PositionDirection.vertical);

    while (true) {
      _stagesData.update("value", (list) => (list as List<int>)..add(decimal),
          ifAbsent: () => [decimal]);

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

    _stagesData.putIfAbsent("remains", () => remains.reversed);
    _stagesData.putIfAbsent("result", () => result.reversed.join().toString());

    if (kDebugMode) {
      print(_stagesData["type"]);
      print(_stagesData["value"]);
      print(_stagesData["remains"]);
      print(_stagesData["result"]);
    }
    return result.reversed.join().toString();
  }

  String _hexadecimalToDecimal() {
    List<String> rawHex = value.split('');
    List<int> hexList = rawHex.map((hex) {
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

    _stagesData.putIfAbsent("type", () => PositionDirection.horizontal);
    _stagesData.putIfAbsent("value", () => rawHex);

    for (int i = 0; i < hexList.length; i++) {
      int hexadecimal = hexList.elementAt(i);

      _stagesData.update("power", (list) => (list as List<String>)..add("16${toSuperscript((hexList.length - 1) - i)}"),
          ifAbsent: () => ["16${toSuperscript((hexList.length - 1) - i)}"]);
      rawResult.add(hexadecimal * pow(16, (hexList.length - 1) - i).toInt());
    }
    int result = rawResult.reduce((num1, num2) => num1 + num2);

    _stagesData.putIfAbsent("rawResult", () => rawResult);
    _stagesData.putIfAbsent("result", () => result);

    if (kDebugMode) {
      print(_stagesData["type"]);
      print(_stagesData["value"]);
      print(_stagesData["power"]);
      print(_stagesData["rawResult"]);
      print(_stagesData["result"]);
    }
    return result.toString();
  }

  String _decimalToHexadecimal() {
    List<int> remains = [];
    List<String> result = [];
    int decimal = int.parse(value);
    int remain = decimal % 16;

    _stagesData.putIfAbsent("type", () => PositionDirection.vertical);

    while (true) {
      _stagesData.update("value", (list) => (list as List<String>)..add(remain < 10 ? remain.toString() : _hexadecimalNumberMap[remain].toString()),
          ifAbsent: () => [remain < 10 ? remain.toString() : _hexadecimalNumberMap[remain].toString()]);

      if (decimal > 0) {
        remains.add(remain);
        result.add(remain < 10 ? remain.toString() : _hexadecimalNumberMap[remain].toString());

        decimal = (decimal / 16).toInt();
        remain = decimal % 16;
      } else {
        break;
      }
    }

    if (kDebugMode) {
      print(_stagesData["type"]);
      print(_stagesData["value"]);
      print(_stagesData["power"]);
      print(_stagesData["rawResult"]);
      print(_stagesData["result"]);
    }
    return result.reversed.join().toString();
  }

  String _hexadecimalToBinary() {
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

    List<String> rawHex = value.split('');
    List<int> hexList = rawHex.map((hex) {
      final letterRegex = RegExp(r'^([a-fA-F])$');

      if (letterRegex.hasMatch(hex)) {
        return int.parse(_hexadecimalLetterMap[hex].toString());
      } else if (numRegex.hasMatch(hex)) {
        return int.parse(hex);
      } else {
        return 0;
      }
    }).toList();
    List<int> rawResult = [];
    List<String> result = [];

    for (int value in hexList) {
      int hexadecimal = value;
      int remain = hexadecimal % 2;

      while (true) {
        if (hexadecimal > 0) {
          // remains.add(remain);
          // result.add(remain);
          rawResult.add(remain);

          hexadecimal = (hexadecimal / 2).toInt();
          remain = hexadecimal % 2;
        } else {
          if (numRegex.hasMatch(hexadecimal.toString()) && rawResult.length < 4) {
            // result.add(0);
            rawResult.add(0);
          } else {
            result.add(rawResult.reversed.join().toString());
            rawResult.clear();
            break;
          }
        }
      }
    }

    if (kDebugMode) {
      print(_stagesData["type"]);
      print(_stagesData["value"]);
      print(_stagesData["power"]);
      print(_stagesData["rawResult"]);
      print(_stagesData["result"]);
    }
    return result.join(' ');
  }

  String _binaryToHexadecimal() {
    String rawBinary = value;
    rawBinary = rawBinary.padLeft((rawBinary.length + 3) ~/ 4 * 4, '0');
    List<String> binaryList = rawBinary.splitMapJoin(RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '')
        .split(',')..removeLast();
    List<int> rawResult = [];
    String result = "";

    for (String value in binaryList) {
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
      result += total < 10 ? total.toString() : _hexadecimalNumberMap[total].toString();
      rawResult.clear();
    }

    return result;
  }

  String _octalToBinary() {
    final numRegex = RegExp(r'^([0-7])$');

    List<String> rawOctal = value.split('');
    List<int> rawResult = [];
    String result = "";

    for (String value in rawOctal) {
      int octal = int.parse(value);
      int remain = octal % 2;

      while (true) {
        if (octal > 0) {
          rawResult.add(remain);

          octal = (octal / 2).toInt();
          remain = octal % 2;
        } else {
          if (numRegex.hasMatch(octal.toString()) && rawResult.length < 3) {
            // result.add(0);
            rawResult.add(0);
          } else {
            result += rawResult.reversed.join().toString();
            rawResult.clear();
            break;
          }
        }
      }
    }
    return result;
  }

  String _binaryToOctal() {
    String rawBinary = value;
    rawBinary = rawBinary.padLeft((rawBinary.length + 2) ~/ 3 * 3, '0');
    List<String> binaryList = rawBinary.splitMapJoin(RegExp('.{1,3}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '')
        .split(',')..removeLast();
    List<int> rawResult = [];
    String result = "";

    for (String value in binaryList) {
      List<String> binaryPart = value.split('');

      for (int i = 0; i < binaryPart.length; i++) {
        int binary = int.parse(binaryPart.elementAt(i));
        if (binary == 0) {
          _stagesData.update("power", (list) => (list as List<String>)..add(' '),
              ifAbsent: () => [' ']);
          rawResult.add(0);
          continue;
        }

        _stagesData.update("power", (list) => (list as List<String>)..add("2${toSuperscript((binaryPart.length - 1) - i)}"),
            ifAbsent: () => ["2${toSuperscript((binaryPart.length - 1) - i)}"]);
        rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
      }
      result += (rawResult.reduce((num1, num2) => num1 + num2)).toString();
      rawResult.clear();
    }
    return result;
  }

  String _octalToDecimal() {
    List<String> rawOctal = value.split('');
    List<int> rawResult = [];

    for (int i = 0; i < rawOctal.length; i++) {
      int octal = int.parse(rawOctal.elementAt(i));

      _stagesData.update("power", (list) => (list as List<String>)..add("8${toSuperscript((rawOctal.length - 1) - i)}"),
          ifAbsent: () => ["8${toSuperscript((rawOctal.length - 1) - i)}"]);
      rawResult.add(octal * pow(8, (rawOctal.length - 1) - i).toInt());
    }
    int result = rawResult.reduce((num1, num2) => num1 + num2);
    return result.toString();
  }

  String _decimalToOctal() {
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

  String _octalToHexadecimal() {
    String convertToBinary() {
      List<String> rawOctal = value.split('');
      List<int> rawResult = [];
      String result = "";

      for (String value in rawOctal) {
        int octal = int.parse(value);
        int remain = octal % 2;

        while (true) {
          if (octal > 0) {
            rawResult.add(remain);
            octal = (octal / 2).toInt();
            remain = octal % 2;
          } else {
            if (rawResult.length < 3) {
              rawResult.add(0);
            } else {
              result += rawResult.reversed.join().toString();
              rawResult.clear();
              break;
            }
          }
        }
      }
      return result;
    }

    String convertToHexadecimal() {
      String rawBinary = convertToBinary();
      rawBinary = rawBinary.padLeft((rawBinary.length + 3) ~/ 4 * 4, '0');
      List<String> binaryList = rawBinary.splitMapJoin(RegExp('.{1,4}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '')
          .split(',')..removeLast();
      List<int> rawResult = [];
      String result = "";

      for (String value in binaryList) {
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
        result += total < 10 ? total.toString() : _hexadecimalNumberMap[total].toString();
        rawResult.clear();
      }
      return result;
    }
    return convertToHexadecimal();
  }

  String _hexadecimalToOctal() {
    String convertToBinary() {
      final numRegex = RegExp(r'^(1[0-5]|[0-9])$');

      List<String> rawHex = value.split('');
      List<int> hexList = rawHex.map((hex) {
        final letterRegex = RegExp(r'^([a-fA-F])$');

        if (letterRegex.hasMatch(hex)) {
          return int.parse(_hexadecimalLetterMap[hex].toString());
        } else if (numRegex.hasMatch(hex)) {
          return int.parse(hex);
        } else {
          return 0;
        }
      }).toList();
      List<int> rawResult = [];
      List<String> result = [];

      for (int value in hexList) {
        int hexadecimal = value;
        int remain = hexadecimal % 2;

        while (true) {
          if (hexadecimal > 0) {
            // remains.add(remain);
            // result.add(remain);
            rawResult.add(remain);

            hexadecimal = (hexadecimal / 2).toInt();
            remain = hexadecimal % 2;
          } else {
            if (numRegex.hasMatch(hexadecimal.toString()) && rawResult.length < 4) {
              // result.add(0);
              rawResult.add(0);
            } else {
              result.add(rawResult.reversed.join().toString());
              rawResult.clear();
              break;
            }
          }
        }
      }
      return result.join('');
    }

    String convertToOctal() {
      String rawBinary = convertToBinary();
      rawBinary = rawBinary.padLeft((rawBinary.length + 2) ~/ 3 * 3, '0');
      List<String> binaryList = rawBinary.splitMapJoin(RegExp('.{1,3}'),
          onMatch: (m) => '${m.group(0)},',
          onNonMatch: (n) => '')
          .split(',')..removeLast();
      List<int> rawResult = [];
      String result = "";

      for (String value in binaryList) {
        List<String> binaryPart = value.split('');

        for (int i = 0; i < binaryPart.length; i++) {
          int binary = int.parse(binaryPart.elementAt(i));
          if (binary == 0) {
            _stagesData.update("power", (list) => (list as List<String>)..add(' '),
                ifAbsent: () => [' ']);
            rawResult.add(0);
            continue;
          }

          _stagesData.update("power", (list) => (list as List<String>)..add("2${toSuperscript((binaryPart.length - 1) - i)}"),
              ifAbsent: () => ["2${toSuperscript((binaryPart.length - 1) - i)}"]);
          rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
        }
        result += (rawResult.reduce((num1, num2) => num1 + num2)).toString();
        rawResult.clear();
      }
      return result.replaceFirst(result[0], '');
    }
    return convertToOctal();
  }

  String _bcdToDecimal() {
    String rawBinary = value;
    rawBinary = rawBinary.padLeft((rawBinary.length + 3) ~/ 4 * 4, '0');
    List<String> binaryList = rawBinary.splitMapJoin(RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '')
        .split(',')..removeLast();
    List<int> rawResult = [];
    String result = "";

    for (String value in binaryList) {
      List<String> binaryPart = value.split('');

      for (int i = 0; i < binaryPart.length; i++) {
        int binary = int.parse(binaryPart.elementAt(i));
        if (binary == 0) {
          rawResult.add(0);
          continue;
        }

        rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
      }

      result += rawResult.reduce((num1, num2) => num1 + num2).toString();
      rawResult.clear();
    }
    return result;
  }

  String _decimalToBCD() {
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');
    List<String> rawDecimal = value.split('');
    List<int> rawResult = [];
    List<String> result = [];

    for (String value in rawDecimal) {
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
    return result.join(' ');
  }

  String _grayToBinary() {
    List<String> rawBinary = value.split('');
    String binary = rawBinary[0];

    for (int i = 1; i < rawBinary.length; i++) {
      String result = (int.parse(binary[i - 1]) ^ int.parse(rawBinary[i])).toString();
      binary += result;
    }
    return binary;
  }

  String _binaryToGray() {
    List<String> rawGray = value.split('');
    String gray = rawGray[0];

    for (int i = 1; i < rawGray.length; i++) {
      String result = (int.parse(rawGray[i - 1]) ^ int.parse(rawGray[i])).toString();
      gray += result;
    }
    return gray;
  }

  String _excess3ToDecimal() {
    String rawExcess3 = value;
    rawExcess3 = rawExcess3.padLeft((rawExcess3.length + 3) ~/ 4 * 4, '0');
    List<String> binaryList = rawExcess3.splitMapJoin(RegExp('.{1,4}'),
        onMatch: (m) => '${m.group(0)},',
        onNonMatch: (n) => '')
        .split(',')..removeLast();
    List<int> rawResult = [];
    String result = "";

    for (String value in binaryList) {
      List<String> binaryPart = value.split('');

      for (int i = 0; i < binaryPart.length; i++) {
        int binary = int.parse(binaryPart.elementAt(i));
        if (binary == 0) {
          rawResult.add(0);
          continue;
        }

        rawResult.add(pow(2, (binaryPart.length - 1) - i).toInt());
      }

      result += (rawResult.reduce((num1, num2) => num1 + num2) - 3).toString();
      rawResult.clear();
    }
    return result;
  }

  String _decimalToExcess3() {
    final numRegex = RegExp(r'^(1[0-5]|[0-9])$');
    List<String> rawDecimal = value.split('');
    rawDecimal = rawDecimal.map((val) => (int.parse(val) + 3).toString()).toList();
    List<int> rawResult = [];
    List<String> result = [];

    for (String value in rawDecimal) {
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
    return result.join(' ');
  }

  String? convert() {
    switch (convertFrom) {
      case ConvertType.binary:
        switch (convertTo) {
          case ConvertType.decimal:
            return _binaryToDecimal();
          case ConvertType.hexadecimal:
            return _binaryToHexadecimal();
          case ConvertType.octal:
            return _binaryToOctal();
          case ConvertType.gray:
            return _binaryToGray();
          case ConvertType.excess3:
          // TODO: Handle this case.
            throw UnimplementedError();
          default:
          // TODO: Handle this case.
            throw UnimplementedError();
        }
      case ConvertType.decimal:
        switch (convertTo) {
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
          // TODO: Handle this case.
            throw UnimplementedError();
        }
      case ConvertType.hexadecimal:
        switch (convertTo) {
          case ConvertType.binary:
            return _hexadecimalToBinary();
          case ConvertType.decimal:
            return _hexadecimalToDecimal();
          case ConvertType.octal:
            return _hexadecimalToOctal();
          default:
          // TODO: Handle this case.
            throw UnimplementedError();
        }
      case ConvertType.octal:
        switch (convertTo) {
          case ConvertType.binary:
            return _octalToBinary();
          case ConvertType.decimal:
            return _octalToDecimal();
          case ConvertType.hexadecimal:
            return _octalToHexadecimal();
          default:
          // TODO: Handle this case.
            throw UnimplementedError();
        }
      case ConvertType.gray:
        switch (convertTo) {
          case ConvertType.binary:
            return _grayToBinary();
          default:
          // TODO: Handle this case.
            throw UnimplementedError();
        }
      case ConvertType.bcd:
        switch (convertTo) {
          case ConvertType.decimal:
            return _bcdToDecimal();
          default:
          // TODO: Handle this case.
            throw UnimplementedError();
        }
      case ConvertType.excess3:
        switch (convertTo) {
          case ConvertType.decimal:
            return _excess3ToDecimal();
          default:
          // TODO: Handle this case.
            throw UnimplementedError();
        }
    }
  }

  String toSuperscript(int number) {
    return number.toString().split('').map((script) => _superscriptMap[script.toString()]).join('');
  }

  Map<String, Object?> get getStagesData {
    return _stagesData;
  }
}