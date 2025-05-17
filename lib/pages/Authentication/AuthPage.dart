import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:group_grit/pages/Authentication/LoginPage.dart';
import 'package:group_grit/pages/HomePage.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if(snapshot.hasError){
            print('❌ Error from \'AuthPage\': ${snapshot.error}');
            Fluttertoast.showToast(
              msg: '${snapshot.error}',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.black,
              fontSize: 14.0,
            );
          }
          if (snapshot.hasData) {
            print('🏡 Stay/Move to HomePage');
            return HomePage();
          } else {
            print('⬅️ Stay/Move to LoginPage');
            return LoginPage();
          }
        },)
    );
  }
}