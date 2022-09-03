//import 'package:flutter/material.dart';

const String statusPublished = "1";
const String statusInProgress = "2";
const String statusCompleted = "3";
const String statusDelayed = "4";

//@immutable
class WorkTarget {
  final String wkNo;
  final String wkNm;
  final String cntrSpacNo;
  final String centStndWkNo;
  final String wkScd;
  final String wkSnm;
  final String wkPlacNm;
  final String stndWkNo;
  final String wkPrrnBegnYmd;
  final String wkPrrnEndYmd;
  final String wkRsltCnts;

  const WorkTarget(
      {required this.wkNo,
      required this.wkNm,
      required this.cntrSpacNo,
      required this.centStndWkNo,
      required this.wkScd,
      required this.wkSnm,
      required this.wkPlacNm,
      required this.stndWkNo,
      required this.wkPrrnBegnYmd,
      required this.wkPrrnEndYmd,
      required this.wkRsltCnts});

  factory WorkTarget.fromSsv(Map<String, String> ssv) {
    return WorkTarget(
        wkNo: ssv['wkNo']!,
        wkNm: ssv['wkNm']!,
        cntrSpacNo: ssv['cntrSpacNo']!,
        centStndWkNo: ssv['centStndWkNo']!,
        wkScd: ssv['wkScd']!,
        wkSnm: ssv['wkSnm']!,
        wkPlacNm: ssv['wkPlacNm']!,
        stndWkNo: ssv['stndWkNo']!,
        wkPrrnBegnYmd: ssv['wkPrrnBegnYmd']!,
        wkPrrnEndYmd: ssv['wkPrrnEndYmd']!,
        wkRsltCnts: ssv['wkRsltCnts']!);
  }

  WorkTarget withStatus(String code, String? resultContents) {
    String statusText;
    switch (code) {
      case '1':
        statusText = '작업발행';
        break;
      case '2':
        statusText = '진행중';
        break;
      case '3':
        statusText = '작업완료';
        break;
      case '4':
        statusText = '지연완료';
        break;
      default:
        throw ArgumentError.value(code, 'code', 'invalid code');
    }

    return WorkTarget(
        wkNo: wkNo,
        wkNm: wkNm,
        cntrSpacNo: cntrSpacNo,
        centStndWkNo: centStndWkNo,
        wkScd: code,
        wkSnm: statusText,
        wkPlacNm: wkPlacNm,
        stndWkNo: stndWkNo,
        wkPrrnBegnYmd: wkPrrnBegnYmd,
        wkPrrnEndYmd: wkPrrnEndYmd,
        wkRsltCnts: resultContents ?? wkRsltCnts);
  }
}
