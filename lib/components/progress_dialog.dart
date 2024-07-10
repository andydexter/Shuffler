import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;
  final AnimationController controller;
  final BuildContext context;
  final int upperBound;

  ProgressDialog(
      {super.key, required this.message, required this.controller, required this.context, required this.upperBound}) {
    controller.addListener(() {
      if (controller.isDismissed) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message),
      content: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: controller.value,
              ),
            ),
            const SizedBox(width: 10),
            Text('${(controller.value * upperBound).toInt()} / $upperBound'),
          ],
        ),
      ),
    );
  }
}
