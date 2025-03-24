import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class GroupButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  const GroupButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            height: GGSize.screenHeight(context) * 0.15,
            width: GGSize.screenWidth(context) * 0.28,
            decoration: BoxDecoration(
              color: GGColors.buttonColor,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: GGSize.screenWidth(context) * 0.07),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: GGColors.primaryColor),
                  SizedBox(height: 10),
                  Text(
                    text,
                    style: TextStyle(
                      color: GGColors.primarytextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        onPressed: () {onPressed();},);
  }
}
