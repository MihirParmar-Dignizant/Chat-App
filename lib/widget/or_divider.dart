import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class OrDivider extends StatelessWidget {
  final String? text; // nullable and no default

  const OrDivider({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final hasText = text != null && text!.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            margin: EdgeInsets.only(right: hasText ? 10 : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.grey.withAlpha(0),
                  AppColor.grey.withAlpha(150),
                ],
                stops: const [0.25, 1.0],
              ),
            ),
          ),
        ),

        if (hasText)
          Text(
            text!,
            style: TextStyle(
              color: AppColor.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

        Expanded(
          child: Container(
            height: 2,
            margin: EdgeInsets.only(left: hasText ? 10 : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.grey.withAlpha(150),
                  AppColor.grey.withAlpha(0),
                ],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
