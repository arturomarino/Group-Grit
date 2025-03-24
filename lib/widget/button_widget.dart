import 'package:flutter/material.dart';
import 'package:group_grit/utils/constants/colors.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: GGColors.primaryColor,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: Text(text, style: TextStyle(fontSize:17, color: Colors.white)),
        onPressed: onClicked,
      );
}
