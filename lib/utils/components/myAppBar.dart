import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FrostedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget leading;
  final List<Widget> actions;
  final double blurStrengthX;
  final double blurStrengthY;

  //constructor
  FrostedAppBar({
    required this.actions,
    required this.blurStrengthX,
    required this.blurStrengthY ,
    required this.leading,
    required this.title,
  });

  @override
  _FrostedAppBarState createState() => _FrostedAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(90);
}

class _FrostedAppBarState extends State<FrostedAppBar> {
  @override
  Widget build(BuildContext context) {
    var scrSize = MediaQuery.of(context).size;
    return  ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurStrengthX,
            sigmaY: widget.blurStrengthY,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              //color: widget.color,
              alignment: Alignment.bottomCenter,
              width: scrSize.width,
              height: kToolbarHeight+MediaQuery.of(context).padding.top*0.7,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      width: 56,
                      color: Colors.transparent,
                      child: Icon(CupertinoIcons.back,size: 30,color: Colors.black,),
                    ),
                  ),
                  Expanded(
                    child: widget.title,
                  ),
                  Row(
                    children: widget.actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      
    );
  }
}
