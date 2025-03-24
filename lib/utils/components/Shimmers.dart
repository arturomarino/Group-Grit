import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:shimmer/shimmer.dart';

class MyGroupShimmer extends StatelessWidget {
  const MyGroupShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: Duration(milliseconds: 1200),
      baseColor: Colors.grey[200]!, // Colore di base (grigio chiaro)
      highlightColor: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: GGSize.screenWidth(context) * 0.153,
              height: GGSize.screenHeight(context) * 0.07,
              decoration: BoxDecoration(
                color: GGColors.buttonColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: GGSize.screenWidth(context) * 0.3,
                    height: 15,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: GGColors.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: GGSize.screenWidth(context) * 0.35,
                    height: 13,
                    decoration: BoxDecoration(
                      color: GGColors.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Container(
                width: GGSize.screenWidth(context) * 0.15,
                height: GGSize.screenHeight(context) * 0.04,
                decoration: BoxDecoration(
                  color: GGColors.buttonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MembersShimmer extends StatelessWidget {
  const MembersShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: Duration(milliseconds: 1200),
      baseColor: Colors.grey[200]!, // Colore di base (grigio chiaro)
      highlightColor: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: GGSize.screenWidth(context) * 0.12,
              height: GGSize.screenWidth(context) * 0.12,
              decoration: BoxDecoration(
                color: GGColors.buttonColor,
                shape: BoxShape.circle,
              ),
              child: Center(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: GGSize.screenWidth(context) * 0.3,
                    height: 15,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: GGColors.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: GGSize.screenWidth(context) * 0.35,
                    height: 13,
                    decoration: BoxDecoration(
                      color: GGColors.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: GGSize.screenWidth(context),
      decoration: BoxDecoration(
        color: GGColors.buttonColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        period: Duration(milliseconds: 1200),
        baseColor: Colors.grey[200]!, // Colore di base (grigio chiaro)
        highlightColor: Colors.white,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: GGSize.screenWidth(context) * 0.14,
                height: GGSize.screenWidth(context) * 0.14,
                decoration: BoxDecoration(
                  color: GGColors.buttonColor,
                  shape: BoxShape.circle,
                ),
                child: Center(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: GGSize.screenWidth(context) * 0.3,
                      height: 17,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: GGColors.buttonColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: GGSize.screenWidth(context) * 0.1,
                          height: 20,
                          decoration: BoxDecoration(
                            color: GGColors.buttonColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          width: GGSize.screenWidth(context) * 0.3,
                          height: 20,
                          decoration: BoxDecoration(
                            color: GGColors.buttonColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          width: GGSize.screenWidth(context) * 0.08,
                          height: 20,
                          decoration: BoxDecoration(
                            color: GGColors.buttonColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: GGSize.screenWidth(context) * 0.12,
                  height: GGSize.screenWidth(context) * 0.12,
                  decoration: BoxDecoration(color: GGColors.buttonColor, borderRadius: BorderRadius.circular(15)),
                  child: Center(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
