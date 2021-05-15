import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetsampule/homePage/home.dart';
import 'package:widgetsampule/inputPage/inputPageWidget.dart';

final _loginProvider=ChangeNotifierProvider.autoDispose(
        (ref)=> LoginWidget()
);

final _listFirebaseProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ListChangeFirebase(),
);

enum FirebaseAuthResultStatus {
  Successful,
  EmailAlreadyExists,
  WrongPassword,
  InvalidEmail,
  UserNotFound,
  UserDisabled,
  OperationNotAllowed,
  TooManyRequests,
  Undefined,
}

class FirebaseAuthExceptionHandler {

  static FirebaseAuthResultStatus handleException(FirebaseAuthException e) {
    FirebaseAuthResultStatus result;
    switch (e.code) {
      case 'invalid-email':
        result = FirebaseAuthResultStatus.InvalidEmail;
        break;

      case 'user-not-found':
        result = FirebaseAuthResultStatus.UserNotFound;
        break;

      case 'wrong-password':
        result = FirebaseAuthResultStatus.WrongPassword;
        break;

      case 'user-disabled':
        result = FirebaseAuthResultStatus.UserDisabled;
        break;

      case 'too-many-requests':
        result = FirebaseAuthResultStatus.TooManyRequests;
        break;

      case 'operation-not-allowed':
        result = FirebaseAuthResultStatus.OperationNotAllowed;
        break;

      case 'email-already-in-use':
        result = FirebaseAuthResultStatus.EmailAlreadyExists;
        break;

      default:
        result = FirebaseAuthResultStatus.Undefined;
        break;
    }
    return result;
  }

  static String exceptionMessage(FirebaseAuthResultStatus result) {
    String message = '';
    switch (result) {
      case FirebaseAuthResultStatus.InvalidEmail:
        message = 'メールアドレスが間違っています。';
        break;

      case FirebaseAuthResultStatus.WrongPassword:
        message = 'パスワードが間違っています。';
        break;

      case FirebaseAuthResultStatus.UserNotFound:
        message = 'このアカウントは存在しません。';
        break;

      case FirebaseAuthResultStatus.UserDisabled:
        message = 'このメールアドレスは無効になっています。';
        break;

      case FirebaseAuthResultStatus.TooManyRequests:
        message = '回線が混雑しています。もう一度試してみてください。';
        break;

      case FirebaseAuthResultStatus.OperationNotAllowed:
        message = 'メールアドレスとパスワードでのログインは有効になっていません。';
        break;

      case FirebaseAuthResultStatus.EmailAlreadyExists:
        message = 'このメールアドレスはすでに登録されています。';
        break;

      default:
        message = '予期せぬエラーが発生しました。';
        break;
    }
    return message;
  }
}


class LoginWidget extends ChangeNotifier{
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  final passwordCheckController=TextEditingController();
  bool _isLogin = false;
  var result;

  Future<FirebaseAuthResultStatus> signIn({String email, String password}) async {
    FirebaseAuthResultStatus result;
    try {
      final UserCredential userCredential =await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      if (userCredential.user == null) {
        // ユーザーが取得できなかったとき
        result = FirebaseAuthResultStatus.Undefined;
      } else {
        // ログイン成功時
        result = FirebaseAuthResultStatus.Successful;
      }
    } catch (error) {
      // エラー時
      result = FirebaseAuthExceptionHandler.handleException(error);
    }
    return result;
  }

  Future<void> login() async {
    final FirebaseAuthResultStatus result = await signIn(
      email: emailController.text,
      password: passwordController.text,
    );

    if (result == FirebaseAuthResultStatus.Successful){
       uid=  FirebaseAuth.instance.currentUser.uid;

    // ログイン成功時の処理
    } else {
    // ログイン失敗時の処理
    final errorMessage = FirebaseAuthExceptionHandler.exceptionMessage(result);
        print(errorMessage);
        throw(errorMessage);
    }
    }



  Future<void> signUp(form) async {
    if (!form.currentState.validate()) {
      return;
    }
    form.currentState.save();
    final auth = FirebaseAuth.instance;
    if (_isLogin) {
       result = await auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      print('signIn: '+result.user.uid);
    } else {
      result = await auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      print('signUp: '+result.user.uid);
    }
    notifyListeners();
  }

  void emailCheck(){
    if(emailController.text.isEmpty){
      throw('メールアドレスを入力してください');
    }
    else if(!emailController.text.contains('@')){
      throw('有効なメールドレスを入力してください');
    }
    else if(passwordController.text.isEmpty){
      throw('パスワードを入力してください');
    }
    else{}
  }

  void passCheck() {
    if(passwordController.text.length<6){
      throw('パスワードは6文字以上にしてください');
    }
    if (passwordController.text != passwordCheckController.text || passwordController.text=='') {
      throw ('パスワードが一致しません');
    }
  }
}

class EmailSignUp extends StatelessWidget{
  EmailSignUp(this.eOrP);
   String eOrP='';
  @override
  Widget build(BuildContext context) {
    final _form = GlobalKey<FormState>();
    final _passwordFocusNode = FocusNode();
    return Consumer(
        builder: (context,watch,child){
          return Form(
            key: _form,
            child: (eOrP=='email') ? TextFormField(
              controller: watch(_loginProvider).emailController,
              decoration: InputDecoration(labelText: 'email'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ):(eOrP=='pass') ? TextFormField(
              controller: watch(_loginProvider).passwordController,
              decoration: InputDecoration(labelText: 'パスワードを入力してください'),
              obscureText: true,
              focusNode: _passwordFocusNode,
            ):(eOrP=='passCheck') ? TextFormField(
              controller: watch(_loginProvider).passwordCheckController,
              decoration: InputDecoration(labelText: 'パスワードを再入力してください'),
              obscureText: true,
            ): ElevatedButton(
                child: Text('作成'),
                onPressed: () async{
                 try {
                    watch(_loginProvider).emailCheck();
                    watch(_loginProvider).passCheck();
                   await watch(_loginProvider).signUp(_form);
                    Navigator.pop(context);
                  }
                catch (e) {
                    watch(_listFirebaseProvider).alertFunc(context, e);
                }
                }
            ),
          );
        }
        );
  }
}

class EmailSignIn extends StatelessWidget{
  EmailSignIn(this.eOrP);
  String eOrP='';
  @override
  Widget build(BuildContext context) {
    final _form = GlobalKey<FormState>();
    final _passwordFocusNode = FocusNode();
    return Consumer(
        builder: (context,watch,child){
          return Form(
            key: _form,
            child: (eOrP=='email') ? TextFormField(
              controller: watch(_loginProvider).emailController,
              decoration: InputDecoration(
                filled: true,
                  fillColor: Colors.white12,
                  labelText: 'email',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white70
                  ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey
                )
              ),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ):(eOrP=='pass') ? TextFormField(
              controller: watch(_loginProvider).passwordController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white12,
                  labelText: 'パスワードを入力してください',
                  labelStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.white70
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey
                      )
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey
                )
              )
              ),
              obscureText: true,
              focusNode: _passwordFocusNode,
            ): ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white38,
                  onPrimary: Colors.lightBlueAccent,
                  elevation: 12,
                ),
                onPressed: () async {
                  try {
                   await watch(_loginProvider).login();
                  }
                  catch (e) {
                    watch(_listFirebaseProvider).alertFunc(context, e);
                  }
                },
                child: Text('ログイン',
                style: TextStyle(
                  color: Colors.white
                ),),
            ),
          );
        }
    );
  }
}

class FacebookLoginState extends ChangeNotifier{
  static final facebookLogin = FacebookLogin();
  final _form = GlobalKey<FormState>();
  String _email;
  String _password;
  bool _isLogin = false;

  void facebookLogIn() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final credential = FacebookAuthProvider.credential(
            result.accessToken.token
        );
        final authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
        print(authResult.user.uid);
        uid=authResult.user.uid;
        break;
      case FacebookLoginStatus.error:
        print('error, ${result.errorMessage}');
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('cancelled');
        break;
    }
  }
  Future<void> trySubmit() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    final auth = FirebaseAuth.instance;
    if (_isLogin) {
      final result = await auth.signInWithEmailAndPassword(email: _email, password: _password);
      print(result.user.uid);
    } else {
      final result = await auth.createUserWithEmailAndPassword(email: _email, password: _password);
      print(result.user.uid);
    }
  }

}
