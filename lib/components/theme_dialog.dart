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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shuffler/main.dart';

class ThemeDialog extends StatefulWidget {
  final Color seedColor;
  final Brightness brightness;
  final Function(ColorScheme) setColorScheme;
  const ThemeDialog({required this.seedColor, required this.brightness, required this.setColorScheme, super.key});
  @override
  State<ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  late Color seedColor;
  late Brightness brightness;

  @override
  void initState() {
    super.initState();
    seedColor = widget.seedColor;
    brightness = widget.brightness;
  }

  @override
  Widget build(BuildContext context) {
    final originalSeedColor = widget.seedColor;
    final originalBrightness = widget.brightness;
    return SimpleDialog(
      title: const Text("Select Color Seed"),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ColorPicker(
                enableAlpha: false,
                hexInputBar: true,
                pickerColor: seedColor,
                onColorChanged: (value) => seedColor = value,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Dark Mode: "),
                  const SizedBox(width: 5),
                  Switch(
                      value: brightness == Brightness.dark,
                      onChanged: (bool value) => setState(() {
                            brightness = value ? Brightness.dark : Brightness.light;
                          })),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    child: const Text("Cancel"),
                    onPressed: () {
                      setState(() {
                        widget.setColorScheme(
                            ColorScheme.fromSeed(seedColor: originalSeedColor, brightness: originalBrightness));
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  SimpleDialogOption(
                    child: const Text("Preview"),
                    onPressed: () {
                      widget.setColorScheme(ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness));
                    },
                  ),
                  SimpleDialogOption(
                    child: const Text("Submit"),
                    onPressed: () {
                      setPreferenceColor(seedColor);
                      setPreferenceBrightness(brightness);
                      setState(() {
                        widget.setColorScheme(ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness));
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
