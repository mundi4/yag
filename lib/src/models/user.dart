//import 'package:flutter/material.dart';

//@immutable
class User {
  final String usrId;
  final String usrNm;
  final String empNo;
  final String dprtCd;
  final String usrDtlDcd;

  const User(
      {required this.usrId,
      required this.usrNm,
      required this.empNo,
      required this.dprtCd,
      required this.usrDtlDcd});

  @override
  int get hashCode => usrId.hashCode;

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.usrId == usrId &&
      other.usrNm == usrNm &&
      other.empNo == empNo &&
      other.dprtCd == dprtCd &&
      other.usrDtlDcd == usrDtlDcd;

  factory User.fromSsv(Map<String, String> ssv) {
    return User(
        usrId: ssv['usrId']!,
        usrNm: ssv['usrNm']!,
        empNo: ssv['empNo']!,
        dprtCd: ssv['dprtCd']!,
        usrDtlDcd: ssv['usrDtlDcd']!);
  }
}
