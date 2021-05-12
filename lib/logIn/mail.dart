import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AcountCreate extends StatefulWidget {
  @override
  _AcountCreateState createState() => _AcountCreateState();
}

class _AcountCreateState extends State<AcountCreate> {
  @override
  Widget build(BuildContext context) {
    final _passwordFocusNode = FocusNode();
    final _form = GlobalKey<FormState>();
    String _email;
    String _password;
    String _passwordCheck;
    bool _isLogin = false;

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

    return Scaffold(
      appBar: AppBar(
        title: Text('ログインページ'),
      ),
      body: Form(
        key: _form,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'email'),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please provide a value.';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              onSaved: (value) {
                _email = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'パスワードを入力してください'),
              obscureText: true,
              focusNode: _passwordFocusNode,
              validator: (value) {
                if (value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                return null;
              },
              onSaved: (value) {
                _password = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'パスワードを再入力してください'),
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                return null;
              },
              onSaved: (value) {
                _passwordCheck = value;
              },
            ),
            ElevatedButton(
              child: Text('作成'),
              onPressed: (){
                (_password==_passwordCheck) ?
                   trySubmit():
                    print('パスワードが一致しません');
                Navigator.pop(context);
              }
            ),
          ],
        ),
      ),
    );
  }
}

class MailAuth extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}