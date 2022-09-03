// ignore_for_file: unnecessary_this

import 'dart:convert';

const SsvCodec ssv = SsvCodec();

class SsvCodec extends Codec<SsvResult, String> {
  const SsvCodec();

  @override
  Converter<String, SsvResult> get decoder => const SsvDecoder();

  @override
  Converter<SsvResult, String> get encoder => throw UnimplementedError();
}

class SsvDecoder extends Converter<String, SsvResult> {
  const SsvDecoder();

  @override
  SsvResult convert(String input) {
    var parser = _SsvParser(input);
    Map<String, List<Map<String, String>>> data = {};

    while (parser.readDataset()) {
      List<Map<String, String>> rows = List.empty(growable: true);

      while (parser.readRow()) {
        rows.add(parser.row!);
      }

      data[parser.dataset!] = rows;
    }

    SsvResult result = SsvResult(parser.errorCode, parser.errorMsg, data);
    return result;
  }
}

class _SsvParser {
  static const recordSeparator = '';
  static const unitSeparator = '';

  static final RegExp headerPattern = RegExp(
      'SSV:UTF-8ErrorCode:\\w+=([^]+)ErrorMsg:\\w+=([^]*)',
      caseSensitive: true);
  static final RegExp fieldSeparator = RegExp('|');

  final String contents;
  late int pos;
  late int len;
  late String errorCode;
  late String errorMsg;

  String? dataset;
  List<String>? columns;
  Map<String, String>? row;
  int _state = 0;

  _SsvParser(this.contents) {
    var match = headerPattern.matchAsPrefix(contents);
    if (match == null) {
      throw const FormatException();
    }
    errorCode = match.group(1)!;
    errorMsg = match.group(2)!;
    pos = match.end;
    len = contents.length;
    _state = 0;
  }

  bool readDataset() {
    _state = 0;

    var idx = contents.indexOf('${recordSeparator}Dataset:', pos);
    if (idx < 0) {
      return false;
    }
    pos = idx + 9;
    idx = contents.indexOf(recordSeparator, pos);
    if (idx < 0) {
      throw const FormatException('RS expected');
    }

    dataset = contents.substring(pos, idx);
    pos = idx + 1;

    columns = null;
    row = null;

    if (_readRowType()) {
      _state = 1;
      assert(columns != null);
    } else {
      _state = 1;
    }

    return true;
  }

  bool _readRowType() {
    if (!contents.startsWith("_RowType_$unitSeparator", pos)) {
      columns = null;
      return false;
    }
    pos += 10;
    columns = List.empty(growable: true);
    while (pos < len) {
      var idx = contents.indexOf(fieldSeparator, pos);
      if (idx < 0) {
        throw const FormatException();
      }
      var column = contents.substring(pos, idx);
      var idx2 = column.indexOf(':');
      if (idx2 >= 0) {
        column = column.substring(0, idx2);
      }
      columns!.add(column);
      pos = idx + 1;
      if (contents[idx] == recordSeparator) {
        break;
      }
    }

    return true;
  }

  bool readRow() {
    if (_state != 1) {
      throw StateError('readDataset() first.');
    }

    row = null;

    if (pos >= len) {
      return false;
    }
    if (contents[pos] == recordSeparator) {
      return false;
    }

    if (!'NIUDO'.contains(contents[pos])) {
      throw const FormatException();
    }
    pos++;
    if (contents[pos] != unitSeparator) {
      throw const FormatException('US expected.');
    }
    pos++;

    row = {};
    for (var i = 0; i < columns!.length; i++) {
      var idx = contents.indexOf(fieldSeparator, pos);
      if (idx < 0) {
        throw const FormatException();
      }
      if (i < columns!.length - 1) {
        if (contents[idx] != unitSeparator) {
          throw const FormatException();
        }
      } else {
        if (contents[idx] != recordSeparator) {
          throw const FormatException();
        }
      }
      var value = contents.substring(pos, idx);
      pos = idx + 1;

      row![columns![i]] = value;
    }

    return true;
  }
}

class SsvResult {
  late final String? errorCode;
  late final String? errorMessage;
  late final List<String> errorArgs;
  late final Map<String, List<Map<String, String>>> data;

  SsvResult(this.errorCode, String errorMessage, this.data) {
    var idx = errorMessage.indexOf('|');
    if (idx >= 0) {
      this.errorMessage = errorMessage.substring(0, idx);
      this.errorArgs = errorMessage.substring(idx).split(',');
    } else {
      this.errorMessage = errorMessage;
      this.errorArgs = List<String>.empty();
    }
  }

  bool get isError => errorCode != null && errorCode != '0';
}
