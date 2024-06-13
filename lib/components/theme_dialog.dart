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
