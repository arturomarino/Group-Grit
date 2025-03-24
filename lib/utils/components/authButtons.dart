import 'package:flutter/material.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class AuthButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onPressed;

  const AuthButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: onPressed,
        child:Container(
            //height: Gsize.screenHeight(context)*0.062,
            ///width: Gsize.screenWidth(context)*0.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GGColors.TextFieldColor,
              border: Border.all(color: Colors.grey[300]!,width: 0.9),
            ),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Icon(icon, color: GGColors.primarytextColor,size: 20,),
                  ],
                ),
              
            ),
        ),
    );
  }
}