import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetsampule/inputPage/inputPageWidget.dart';

final _loginProvider=ChangeNotifierProvider.autoDispose(
        (ref)=> LoginWidget()
);

final _imageProvider=ChangeNotifierProvider.autoDispose(
      (ref) => ImageFunc(),
);

class LoginWidget extends ChangeNotifier{
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  final passwordCheckController=TextEditingController();
  bool _isLogin = false;
  var result;

  Future<void> trySubmit(form) async {
    if (!form.currentState.validate()) {
      return;
    }
    form.currentState.save();
    final auth = FirebaseAuth.instance;
    if (_isLogin) {
       result = await auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);

      print(result.user.uid);
    } else {
      result = await auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      print(result.user.uid);
    }
    print('通過');
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
                onPressed: () {
                 try {
                    watch(_loginProvider).emailCheck();
                    watch(_loginProvider).passCheck();
                    watch(_loginProvider).trySubmit(_form);
                    Navigator.pop(context);
                  }
                catch (e) {
                    watch(_imageProvider).alertFunc(context, e);
                }
                }
            ),
          );
        }
        );
  }
}
