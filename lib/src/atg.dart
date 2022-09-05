import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/user.dart';
import 'models/work_target.dart';
import 'ssv.dart';

final atg = AtG();
final _atgBaseUrl = Uri.parse('https://partner.sni.co.kr/');

class AtGException implements Exception {
  final String? message;
  const AtGException(this.message);
}

enum LoginFailedReason {
  none,
  unknown,
  usernameEmpty,
  passwordEmpty,
  badPasswordCount,
  invalidPassword,
  invalidUsernameOrPassword,
  shouldChangePassword,
  accountDisabled,
}

class LoginFailedException extends AtGException {
  final LoginFailedReason reason;
  LoginFailedException(this.reason, {String? message}) : super(message);
}

class AtG {
  static const String loggedOutMessage =
      '미사용 시간이 경과하거나 다른 곳에서 접속하여 로그아웃 되었습니다.\n다시 로그인 하세요.';

  final http.Client _client;
  final Map<String, String> _cookies = {};
  User? _user;

  AtG({http.BaseClient? httpClient}) : _client = httpClient ?? http.Client();

  Future<List<WorkTarget>> getWorkTargets(
      DateTime startDate, DateTime endDate) async {
    if (_user == null) {
      throw const AtGException('Should login first.');
    }

    var user = _user!;
    var payload =
        'SSV:utf-8nexaUsrId=${user.usrId}Dataset:dsSearch_RowType_cntrSpacNo:STRING(256)'
        'dprtCd:STRING(256)endStartYmd:STRING(256)endEndYmd:STRING(256)'
        'wkNm:STRING(256)wkScd:STRING(256)wkOcrnTcd:STRING(256)svWkInYn:STRING(256)'
        'leglMngmTrgtYn:STRING(256)srvcLv1:STRING(256)srvcLv2:STRING(256)'
        'wkCyclDcd:STRING(256)rwrkRqstYn:STRING(256)bldnNo:STRING(256)'
        'emplNo:STRING(256)remtWkInclYn:STRING(256)emplRgstDcd:STRING(256)'
        'dely:STRING(256)stndPlacCd:STRING(256)eqpnCtgrLvl1Cd:STRING(256)'
        'eqpnCtgrLvl2Cd:STRING(256)centTcd:STRING(256)indnPlacNm:STRING(256)'
        'stndEqpnCd:STRING(256)wkRsltCd:STRING(256)cntrSpacNm:STRING(256)'
        'dispCd:STRING(256)dprtNm:STRING(256)usrDtlDcd:STRING(256)'
        'I50294098${startDate.year.toString()}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}${endDate.year.toString()}${endDate.month.toString().padLeft(2, '0')}${endDate.day.toString().padLeft(2, '0')}2019030239Y30YOPDF0445디앤오강서사옥운영센터82';

    var result = await _sendRequest(
        '/sm/op/workpros/wkTrgtIqry/retrieveWkTrgt.do', payload);

    if (result.errorCode != '0') {
      if (result.errorCode == '-2' && result.errorMessage == loggedOutMessage) {
        throw const AtGException('loggedOut');
      }
      throw AtGException(result.errorMessage);
    }

    var rows = result.data['dsWkTrgtLst']!;
    var list = rows.map((e) => WorkTarget.fromSsv(e)).toList(growable: false);
    return list;
  }

  Future<bool> updateWorkStatus(
      String wkNo, String newStatus, String? resultContent) async {
    if (wkNo.isEmpty) {
      throw ArgumentError.value(wkNo, "wkNo", "value is empty");
    }

    if (newStatus != statusInProgress && newStatus != statusCompleted) {
      throw ArgumentError.value(newStatus, "newStatus",
          "value must be either 'statusInProgress' or 'statusCompleted'.");
    }

    if (newStatus == statusInProgress) {
      if (resultContent == null) {
        throw ArgumentError.notNull(resultContent);
      } else if (resultContent.isEmpty) {
        throw ArgumentError.value(
            resultContent, 'resultContent', 'value is empty');
      }
    }

    final data = (await getWorkItem(wkNo)).data;
    if (data.isEmpty) {
      throw AtGException('work item not found. wkNo: $wkNo');
    }

    final work = data['dsWkRslt']![0];
    final ord = data['dsWkOrdRslt']![0];

    if (work['wkScd'] == newStatus && ord['wkRsltCnts'] == resultContent) {
      return true;
    }

    if (int.parse(work['wkScd']!) >= 3) {
      return false;
    }

    if (work['wkScd'] == statusPublished && newStatus != statusInProgress) {
      return false;
    }

    if (work['wkScd'] == statusInProgress && newStatus != statusCompleted) {
      return false;
    }

    bool ptrlTimeSeen = false;
    String ptrlBeginTimeM = '';
    String ptrlEndTimeM = '';
    String wkBegnDt = '';
    String wkBegnDtTmp = '';
    String wkEndDt = '';
    String wkEndDtTmp = '';

    final ptrls = data['dsPtrlRslt']!;
    if (ptrls.isNotEmpty) {
      for (final ptrl in ptrls) {
        final ptrlBeginTime = ptrl['ptrlBegnDt'] ?? '';
        final ptrlEndTime = ptrl['ptrlEndDt'] ?? '';

        ptrlTimeSeen = ptrlTimeSeen ||
            (ptrlBeginTime.isNotEmpty && ptrlEndTime.isNotEmpty);

        if (ptrlBeginTime.isNotEmpty) {
          if (ptrlBeginTimeM.isEmpty ||
              ptrlBeginTimeM.compareTo(ptrlBeginTime) > 0) {
            ptrlBeginTimeM = ptrlBeginTime;
          }
        }
        if (ptrlEndTime.isNotEmpty) {
          if (ptrlEndTimeM.isEmpty || ptrlEndTimeM.compareTo(ptrlEndTime) < 0) {
            ptrlEndTimeM = ptrlEndTime;
          }
        }
      }

      final wkDt = ord['wkDt']!;
      final setWkDt = '${wkDt.substring(0, 4)}-'
          '${wkDt.substring(4, 6)}-'
          '${wkDt.substring(6, 8)}';

      final setBeginTimeM = '${ptrlBeginTimeM.substring(0, 2)}:'
          '${ptrlBeginTimeM.substring(2, 4)}:'
          '${ptrlBeginTimeM.substring(4, 6)}';

      final setEndTimeM = '${ptrlEndTimeM.substring(0, 2)}:'
          '${ptrlEndTimeM.substring(2, 4)}:'
          '${ptrlEndTimeM.substring(4, 6)}';

      wkBegnDt = wkDt + ptrlBeginTimeM;
      wkBegnDtTmp = '$setWkDt $setBeginTimeM';
      wkEndDt = wkDt + ptrlEndTimeM;
      wkEndDtTmp = '$setWkDt $setEndTimeM';
    }

    StringBuffer sb = StringBuffer();
    sb.write('SSV:utf-8');
    sb.write('nexaUsrId=${_user!.usrId}');

    // dsWkRslt
    var columns = [
      'wkNo',
      'wkNm',
      'vndrNo',
      'vndrNm',
      'wkPlacNo',
      'wkPlacNm',
      'wkOcrnTcd',
      'wkOcrnTcdNm',
      'wkScd',
      'wkScdNm',
      'wkPrrnEndYmd',
      'wkPrrnEndYmdWeek'
    ];

    sb.write('Dataset:dsWkRslt');
    sb.write('_RowType_');

    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      sb.write(col);
      sb.write(':STRING(256)');
      if (i < columns.length - 1) {
        sb.write('');
      } else {
        sb.write('');
      }
    }

    if (work['wkScd'] != newStatus) {
      sb.write('U');
      for (var i = 0; i < columns.length; i++) {
        final col = columns[i];
        if (col == 'wkScd') {
          sb.write(newStatus);
        } else {
          sb.write(work[col]);
        }
        if (i < columns.length - 1) {
          sb.write('');
        } else {
          sb.write('');
        }
      }
    }

    if (work['wkScd'] != newStatus) {
      sb.write('O');
    } else {
      sb.write('N');
    }

    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      sb.write(work[col]);
      if (i < columns.length - 1) {
        sb.write('');
      } else {
        sb.write('');
      }
    }
    sb.write('');

    // dsPtrlRslt
    columns = [
      'wkNo',
      'srtnSqnc',
      'florCd',
      'florNm',
      'ptrlBrofNo',
      'ptrlBrofNm',
      'ptrlBegnDt',
      'ptrlEndDt',
      'wkSpndTime',
      'chkYn',
      'ctrnYn',
      '_status_',
      'selectCheck',
    ];

    sb.write('Dataset:dsPtrlRslt');
    sb.write('_RowType_');

    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      sb.write(col);
      if (col == '_status_' || col == 'selectCheck') {
        sb.write(':STRING(1)');
      } else {
        sb.write(':STRING(256)');
      }
      if (i < columns.length - 1) {
        sb.write('');
      } else {
        sb.write('');
      }
    }

    for (final ptrl in ptrls) {
      if (ptrl['ctrnYn']!.isEmpty) {
        for (var j = 0; j < 2; j++) {
          if (j == 0) {
            sb.write('U');
          } else {
            sb.write('O');
          }

          for (var i = 0; i < columns.length; i++) {
            final col = columns[i];

            if (col == '_status_') {
              if (j == 0) {
                sb.write('I');
              } else {
                sb.write('');
              }
            } else if (col == 'selectCheck') {
              sb.write('');
            } else {
              sb.write(ptrl[col]);
            }

            if (i < columns.length - 1) {
              sb.write('');
            } else {
              sb.write('');
            }
          }
        }
      }
    }
    sb.write('');

    // dsWkOrdRslt
    columns = [
      'wkNo',
      'wkNmopCt',
      'wkBegnDt',
      'wkEndDt',
      'wkItmRsltCd',
      'wkRsltCnts',
      'wkSpndTime',
      'abnrEndYn',
      'wkItmRsltImpn',
      'wkDt',
      'wkBegnDtTmp',
      'wkEndDtTmp',
    ];

    sb.write('Dataset:dsWkOrdRslt');
    sb.write('_RowType_');

    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      sb.write(col);
      sb.write(':STRING(256)');

      if (i < columns.length - 1) {
        sb.write('');
      } else {
        sb.write('');
      }
    }

    for (var j = 0; j < 2; j++) {
      if (j == 0) {
        sb.write('U');
      } else {
        sb.write('O');
      }

      for (var i = 0; i < columns.length; i++) {
        final col = columns[i];
        String value;
        if (j == 0 && col == 'wkBegnDt') {
          value = wkBegnDt;
        } else if (j == 0 && col == 'wkBegnDtTmp') {
          value = wkBegnDtTmp;
        } else if (j == 0 && col == 'wkEndDt') {
          value = wkEndDt;
        } else if (j == 0 && col == 'wkEndDtTmp') {
          value = wkEndDtTmp;
        } else if (j == 0 && col == 'wkItmRsltCd') {
          if (work['wkScd'] == statusPublished && ord['wkItmRsltCd']!.isEmpty) {
            value = '2A';
          } else {
            value = ord['wkItmRsltCd']!;
          }
        } else if (j == 0 &&
            col == 'wkRsltCnts' &&
            newStatus == statusInProgress) {
          value = resultContent!;
        } else if (col == 'abnrEndYn') {
          value = '';
        } else {
          value = ord[col]!;
        }
        sb.write(value);

        if (i < columns.length - 1) {
          sb.write('');
        } else {
          sb.write('');
        }
      }
    }
    sb.write('');
    final payload = sb.toString();

    final result = await _sendRequest(
        '/sm/op/workpros/nclnnEveryWkMngm/saveWkRslt.do', payload);
    // return true;
    return !result.isError;
    // return sb.toString();
  }

  Future<SsvResult> getWorkItem(String wkNo) async {
    var user = _user!;

    var payload =
        'SSV:utf-8nexaUsrId=${user.usrId}Dataset:dsSearch_RowType_wkNo:STRING(256)'
        'N$wkNo';

    var result = await _sendRequest(
        '/sm/op/workpros/nclnnEveryWkMngm/retrieveNclnnEveryWk.do', payload);

    return result;
  }

  Future<User> login(String username, String password) async {
    username = username.trim();
    if (username.isEmpty) {
      throw LoginFailedException(LoginFailedReason.usernameEmpty);
    }
    if (password.isEmpty) {
      throw LoginFailedException(LoginFailedReason.passwordEmpty);
    }

    _cookies.clear();
    _user = null;

    var payload =
        'SSV:utf-8usrId=$usernameusrPw=$passwordsysDcd=PSinvalidYn=Y'
        'nexaUsrId=undefinedDataset:dsCond_RowType_usrId:STRING(256)'
        'pwd:STRING(256)sysDcd:STRING(256)'
        'I$username$passwordPS';

    var result = await _sendRequest('/common/login/login.do', payload,
        ignoreError: true);

    if (result.errorCode == '0') {
      var chk = result.data['dsUserChk']![0];
      if (chk['pwdChgTgrtYn'] == 'Y' || chk['pwdChgTgrtYn'] == 'y') {
        throw LoginFailedException(LoginFailedReason.shouldChangePassword);
      }

      var data = result.data['dsUser']![0];
      _user = User(
          usrId: data['usrId']!,
          usrNm: data['usrNm']!,
          empNo: data['empNo']!,
          dprtCd: data['dprtCd']!,
          usrDtlDcd: data['usrDtlDcd']!);
      return _user!;
    } else {
      switch (result.errorMessage) {
        case 'MSG_INF_0305':
          throw LoginFailedException(LoginFailedReason.accountDisabled);
        case 'MSG_INF_0399':
          throw LoginFailedException(LoginFailedReason.badPasswordCount);
        case 'MSG_INF_0295':
          throw LoginFailedException(
              LoginFailedReason.invalidUsernameOrPassword);
        case 'MSG_INF_0296':
          throw LoginFailedException(LoginFailedReason.invalidPassword);
        default:
          throw LoginFailedException(LoginFailedReason.unknown);
      }
    }
  }

  Future<void> changePassword(
      String username, String oldPassword, String newPassword) async {
    var user = _user!;

    final payload =
        'SSV:utf-8nexaUsrId=${user.usrId}Dataset:dsCond_RowType_'
        'usrId:STRING(256)usrPw:STRING(256)postPw:STRING(256)'
        'postPwCfrm:STRING(256)crtfNo:STRING(256)sysDcd:STRING(256)I'
        '$username$oldPassword$newPassword$newPassword$oldPasswordPS';

    await _sendRequest('/common/login/saveChngPwd.do', payload,
        ignoreError: false);
  }

  void _parseCookies(http.Response response) {
    var setcookieStr = response.headers['set-cookie'];
    if (setcookieStr != null) {
      var matches = RegExp('(AWSALB|AWSALBCORS|LENA-UID|JSESSIONID)=([^;]*);')
          .allMatches(setcookieStr);
      for (var m in matches) {
        _cookies[m.group(1)!] = m.group(2)!;
      }
    }
  }

  String _generateCookieHeader() {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join(';');
  }

  Future<SsvResult> _sendRequest(String path, String payload,
      {bool ignoreError = false}) async {
    final requestUrl = _atgBaseUrl.replace(path: path);
    final response = await _client.post(requestUrl, body: payload, headers: {
      'cookie': _generateCookieHeader(),
      'accept-language': 'ko,en;q=0.9,en-US;q=0.8'
    });
    _parseCookies(response);

    var result = ssv.fuse(utf8).decode(response.bodyBytes);

    if (!ignoreError) {
      if (result.errorCode != '0') {
        if (result.errorCode == '-2' &&
            result.errorMessage == loggedOutMessage) {
          throw const AtGException('loggedOut');
        }
        throw AtGException(result.errorMessage);
      }
    }

    return result;
  }

  void close() {
    _client.close();
  }
}
