import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;
  final AnimationController controller;
  final BuildContext context;
  final int upperBound;
  final Function() onCancel;

  ProgressDialog(
      {super.key,
      required this.message,
      required this.controller,
      required this.context,
      required this.upperBound,
      required this.onCancel}) {
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
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
