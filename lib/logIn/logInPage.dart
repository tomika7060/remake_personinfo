import 'package:flutter/material.dart';
import 'package:widgetsampule/logIn/loginWidget.dart';
import 'package:widgetsampule/logIn/signUp.dart';


class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FacebookLoginState face=FacebookLoginState();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Colors.blue[300],
              Colors.blue[400],
              Colors.blue[500],
            ]
          )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login',
              style: TextStyle(
                fontFamily: 'Caveat',
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.w900
              )
              ),
              SizedBox(height: 30,),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white38,
                    onPrimary: Colors.lightBlueAccent,
                    elevation: 10,
                  ),
                  onPressed: face.facebookLogIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.facebook,
                      color: Colors.white,),
                      Text('   Facebookでログイン',
                      style: TextStyle(
                        color: Colors.white
                      ),),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Text('———— Or Login with Email ————',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 20,
                color: Colors.white,
              ),),
              SizedBox(height: 15,),
              SizedBox(
                width: 300,
                  height: 50,
                  child: EmailSignIn('email')
              ),
              SizedBox(height: 5,),
              SizedBox(
                width: 300,
                  height: 50,
                  child: EmailSignIn('pass')
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 300,
                  child: EmailSignIn('button')
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white38,
                    onPrimary: Colors.lightBlueAccent,
                    elevation: 10,
                  ),
                  onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>
                            AccountCreate())
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline,
                      color: Colors.white,
                      ),
                      Text('    アカウントを作成',
                      style: TextStyle(
                        color: Colors.white
                      ),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}