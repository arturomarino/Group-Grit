

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_grit/l10n/app_localizations.dart';
import 'package:group_grit/pages/Authentication/LoginPage.dart';
import 'package:group_grit/pages/Authentication/UsernamePage.dart';
import 'package:group_grit/pages/HomePage.dart';
import 'package:group_grit/utils/functions/AnalyticsEngine.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(cred);
    } catch (e) {
      print(e.toString());

      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 14.0,
      );
      return null;
    }
  }

  Future<void> signup({required String email, required String password, required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
    } on FirebaseAuthException catch (e) {
      //All possibile errors that can be thrown by FirebaseAuth
      print(e.code);
      String message = '';

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Email address is invalid';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error, check your internet connection';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      print(e);
    }
  }

  Future<void> signin({required String email, required String password, required BuildContext context}) async {
    final loc = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      //All possibile errors that can be thrown by FirebaseAuth
      print(e.code);
      String message = '';
      if (e.code == 'invalid-email') {
        message = loc.utilsFunctionsAuthServiceText7;
      } else if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        message = loc.utilsFunctionsAuthServiceText14;
      } else if (e.code == 'user-disabled') {
        message = loc.utilsFunctionsAuthServiceText8;
      } else if (e.code == 'user-not-found') {
        message = loc.utilsFunctionsAuthServiceText9;
      } else if (e.code == 'network-request-failed') {
        message = loc.utilsFunctionsAuthServiceText10;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      print(e);
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      final oAuthProvider = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      return await FirebaseAuth.instance.signInWithCredential(oAuthProvider);
    } catch (e) {
      print('Error sign in with Apple: $e');
      return null;
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
  }

  //REAUTHENTICATE USER
  Future<UserCredential?> reauthenticateWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      final oAuthProvider = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      return await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(oAuthProvider);
    } catch (e) {
      print('Error sign in with Apple: $e');
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 14.0,
      );
      return null;
    }
  }

  Future<UserCredential?> reauthenticateWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);
    } catch (e) {
      print(e.toString());

      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 14.0,
      );
      return null;
    }
  }
}
