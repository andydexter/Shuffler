///
///     Copyright (C) 2024  Andreas Nicolaou
///
///     This program is free software: you can redistribute it and/or modify
///     it under the terms of the GNU General Public License as published by
///     the Free Software Foundation, either version 3 of the License, or
///     (at your option) any later version.
///
///     This program is distributed in the hope that it will be useful,
///     but WITHOUT ANY WARRANTY; without even the implied warranty of
///     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
///     GNU General Public License for more details.
///
///     You should have received a copy of the GNU General Public License
///     along with this program. You can find it at project root.
///     If not, see <https://www.gnu.org/licenses/>.
///
///     Author E-mail address: andydexter123@gmail.com
///

library;

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
