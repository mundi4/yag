import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../atg.dart';
import 'user.dart';

const _secureStorage = FlutterSecureStorage();

final LoginModel loginModel = LoginModel();

class LoginModel extends ChangeNotifier {
  String _username = '';
  String _password = '';
  User? _user;
  LoginFailedReason _failedReason = LoginFailedReason.none;

  String get username {
    return _username;
  }

  set username(String value) {
    if (_username != value) {
      _username = value;
      notifyListeners();
    }
  }

  String get password {
    return _password;
  }

  set password(String value) {
    if (_password != value) {
      _password = value;
      notifyListeners();
    }
  }

  User? get user {
    return _user;
  }

  set user(User? value) {
    if (_user != value) {
      _user = value;
      notifyListeners();
    }
  }

  LoginFailedReason get failedReason {
    return _failedReason;
  }

  set failedReason(LoginFailedReason failedReason) {
    if (_failedReason != failedReason) {
      _failedReason = failedReason;
      notifyListeners();
    }
  }

  Future<void> loadFromStorage() async {
    try {
      _username = await _secureStorage.read(key: 'username') ?? '';
      _password = await _secureStorage.read(key: 'password') ?? '';
      notifyListeners();
    } on PlatformException {
      await _secureStorage.deleteAll();
    }
  }

  Future<void> saveToStorage() async {
    await _secureStorage.write(key: 'username', value: _username);
    await _secureStorage.write(key: 'password', value: _password);
  }

  Future<void> clearStorage() async {
    await _secureStorage.delete(key: 'username');
    await _secureStorage.delete(key: 'password');
  }

  Future<User?> login({bool force = false, bool updatePassword = false}) async {
    if (_user != null && !force) {
      return _user;
    }

    try {
      user = await atg.login(_username, _password);
      await saveToStorage();

      if (updatePassword) {
        // bool changedTemp = false;
        // final tempPassword =
        //     _password != 'temp1357!' ? 'temp1357!' : 'temp2468!';

        // try {
        //   await atg.changePassword(_username, _password, tempPassword);
        //   changedTemp = true;
        //   await atg.changePassword(_username, tempPassword, _password);
        // } catch (e) {
        //   if (changedTemp) {
        //     await atg.changePassword(_username, tempPassword, _password);
        //   }
        // }
      }

      return user;
    } on LoginFailedException catch (e) {
      if (e.reason == LoginFailedReason.invalidPassword) {
        _password = '';
        await saveToStorage();
      }
      user = null;
      failedReason = e.reason;
      rethrow;
    } catch (e) {
      user = null;
      failedReason = LoginFailedReason.unknown;
      rethrow;
    }
  }

  Future<void> logout() async {
    _username = '';
    _password = '';
    _user = null;
    await saveToStorage();
    notifyListeners();
  }
}
