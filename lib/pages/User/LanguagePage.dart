import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/i18n/t_data.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class LanguagePage extends StatefulWidget {
  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: GGColors.backgroundColor,
          title: Text(
            'Language',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Choose a Language',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: GGColors.buttonColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                          indent: GGSize.screenWidth(context) * 0.1,
                          color: GGColors.secondarytextColor.withOpacity(0.1),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: AppLocales.available.length,
                      itemBuilder: (context, index) {
                        final e = AppLocales.available[index];
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            currentLocale.value = e.locale;
                          },
                          child: ListTile(
                            trailing: Icon(Icons.check, color: currentLocale.value == e.locale ? GGColors.primaryColor : Colors.transparent),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            title: Text(e.englishName),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
