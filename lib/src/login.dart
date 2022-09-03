// ignore_for_file: unused_element

/*
result.data['dsUser']![0]

0:
"usrId" -> "BP-DREAMNURI08"
1:
"usrNm" -> "윤영심"
2:
"usrPw" -> ""
3:
"crtfNo" -> ""
4:
"empNo" -> "2019030239"
5:
"rsofDcd" -> ""
6:
"rsofNm" -> ""
7:
"dprtCd" -> "50294098"
8:
"dprtNm" -> "디앤오강서사옥운영센터"
9:
"wkDprtCd" -> "50294098"
10:
"wkDprtNm" -> "디앤오강서사옥운영센터"
11:
"wkDispCd" -> "F0445"
12:
"wkDprtLvl" -> "60"
13:
"centTcd" -> "OP"
14:
"dprtLvl" -> "60"
15:
"wbsCd" -> "F0445"
16:
"cstCentCd" -> ""
17:
"dispCd" -> "F0445"
18:
"vndrNo" -> "5706"
19:
"vndrNm" -> "(주)드림누리"
20:
"bsrn" -> "3568800857"

*/
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yag/src/routes.dart';

import 'atg.dart';
import 'models/login_model.dart';

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    super.key,
    this.restorationId,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  final String? restorationId;
  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> with RestorationMixin {
  final RestorableBool _obscureText = RestorableBool(true);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_obscureText, 'obscure_text');
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      restorationId: 'password_text_field',
      obscureText: _obscureText.value,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      initialValue: loginModel.password,
      decoration: InputDecoration(
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText.value = !_obscureText.value;
            });
          },
          hoverColor: Colors.transparent,
          icon: Icon(
              _obscureText.value ? Icons.visibility : Icons.visibility_off,
              semanticLabel: _obscureText.value ? '보기' : '감추기'),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  // FormData formData = FormData();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _usernameFieldKey =
      GlobalKey<FormFieldState<String>>();

  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  late FocusNode _username, _password;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    _username = FocusNode();
    _password = FocusNode();
    // _readFromSecureStorage();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
        ),
        body: SafeArea(
            child: Form(
                key: _formKey,
                child: Scrollbar(
                    child: SingleChildScrollView(
                  restorationId: 'login_scroll_view',
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    sizedBoxSpace,
                    // if (isBusy) const CircularProgressIndicator(),
                    // 로그인 아이디 필드
                    TextFormField(
                      autofocus: true,
                      restorationId: 'username_field',
                      textInputAction: TextInputAction.next,
                      //textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.name,
                      focusNode: _username,
                      key: _usernameFieldKey,

                      decoration: const InputDecoration(
                          filled: true,
                          labelText: '로그인 아이디',
                          hintText: '로그인 아이디를 입력하세요.'
                          //hintText: ''
                          // icon: const Icon(Icons.person),
                          ),
                      initialValue: loginModel.username,
                      // onChanged: (value) {
                      //   loginModel.username = value;
                      // },
                      validator: _validateName,
                    ),

                    sizedBoxSpace,
                    _PasswordField(
                      restorationId: 'password_field',
                      //textInputAction: TextInputAction.next,
                      focusNode: _password,
                      fieldKey: _passwordFieldKey,

                      //helperText: '헬퍼 텍스트',
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요.',
                      // onFieldSubmitted: (value) {
                      //   setState(() {
                      //     log('form submitted');
                      //     loginModel.password = value;
                      //   });
                      // },
                      // onSaved: (newValue) {
                      //   log('on saved $newValue');
                      // },
                      validator: _validatePassword,

                      // //textCapitalization: TextCapitalization.none,
                      // //keyboardType: TextInputType.text,
                      // decoration: const InputDecoration(
                      //   filled: true,
                      //   labelText: '비밀번호',
                      //   // icon: const Icon(Icons.key),
                      // ),
                      // initialValue: loginModel.password,
                      // onChanged: (value) {
                      //   loginModel.password = value;
                      // },
                    ),
                    sizedBoxSpace,
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmitted,
                        label: const Text('로그인'),
                        icon: const Icon(Icons.login),
                      ),
                    ),
                    sizedBoxSpace,
                    Text(
                      '모든 책임은 사용자 본인의 몫',
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(color: Colors.redAccent),
                    )
                  ]),
                )))));
  }

  Future<void> _handleSubmitted() async {
    log("1");
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _showInSnackBar('입력 오류를 수정하세요.');
      return;
    }
    log("22");
    // setState(() {
    //   isBusy = true;
    // });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    log("3");
    try {
      // log('delaying...');
      // await Future.delayed(const Duration(seconds: 3));
      // log('delaying done...');

      // log('username: ${loginModel.username}, password: ${loginModel.password}');
      var username = _usernameFieldKey.currentState!.value!;
      var password = _passwordFieldKey.currentState!.value!;
      // log('new?: $username, $password');

      loginModel.username = username;
      loginModel.password = password;

      try {
        await loginModel.login(force: true);
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, homeRoute);
      } on LoginFailedException catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();

        switch (e.reason) {
          case LoginFailedReason.invalidUsernameOrPassword:
            _showDialog('로그인 아이디 또는 비밀번호를 다시 확인하세요.');
            break;
          case LoginFailedReason.accountDisabled:
            _showDialog('사용이 정지된 로그인 아이디입니다.');
            break;
          case LoginFailedReason.invalidPassword:
            _showDialog(
              '비밀번호가 틀립니다. 비밀번호 오류횟수가 5번을 초과하면 계정이 잠겨버립니다!',
              //func: () => _password.requestFocus()
            );
            break;
          case LoginFailedReason.badPasswordCount:
            _showDialog('비밀번호 오류횟수가 5번을 초과하였습니다.');
            break;
          default:
            _showDialog('알 수 없는 이유로 인해 로그인하지 못했습니다.');
            break;
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        rethrow;
      }
    } finally {
      // Navigator.of(context, rootNavigator: true).pop('dialog');
      // setState(() {
      //   isBusy = false;
      // });
    }

    // var atg = AtG();
    // try {
    //   var user = await atg.login(loginModel.username, loginModel.password);
    //   inspect(user);
    //   await loginModel.saveToStorage();
    //   if (mounted) {
    //     Navigator.pushReplacementNamed(context, homeRoute);
    //   }
    // } on LoginFailedException catch (e) {
    //   _showDialog('login failed: ${e.reason}');
    //   return;
    // }
  }

  String? _validateName(String? value) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return '로그인 아이디를 입력하세요.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력하세요.';
    }
    return null;
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _showDialog(String message, {Function? func}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                if (func != null) {
                  func();
                }
              }),
        ],
      ),
    );
  }
}
