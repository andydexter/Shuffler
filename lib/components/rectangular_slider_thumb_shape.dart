import 'package:flutter/material.dart';

class RectangularSliderThumbShape extends SliderComponentShape {

  final Size enabledThumbSize;
  final Size? disabledThumbSize;
  final double elevation;
  final double pressedElevation;
  final Color borderColor;

  const RectangularSliderThumbShape({this.enabledThumbSize = const Size(10.0,25.0), this.disabledThumbSize, this.elevation = 3.0, this.pressedElevation = 6.0, this.borderColor = Colors.black});

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> widthTween = Tween<double>(
      begin: disabledThumbSize?.width ?? enabledThumbSize.width,
      end: enabledThumbSize.width,
    );
    final Tween<double> heightTween = Tween<double>(
      begin: disabledThumbSize?.height ?? enabledThumbSize.height,
      end: enabledThumbSize.height,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(enableAnimation)!;
    final double width = widthTween.evaluate(enableAnimation);
    final double height = heightTween.evaluate(enableAnimation);

    final Tween<double> elevationTween =
        Tween<double>(begin: elevation, end: pressedElevation);

    final double evaluatedElevation =
        elevationTween.evaluate(activationAnimation);
    final Path path = Path()
      ..addRect(
        Rect.fromCenter(center: center, width: width, height: height),
      );

    bool paintShadows = true;
    assert(() {
      if (debugDisableShadows) {
        //debugDrawShadow(canvas, path, evaluatedElevation);
        paintShadows = false;
      }
      return true;
    }());

    if (paintShadows) {
      canvas.drawShadow(path, Colors.black, evaluatedElevation, false);
    }

    RRect rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        Radius.elliptical(width/5, height/5));
  
    canvas.drawRRect(rrect, Paint()..color = color);
    canvas.drawRRect(rrect, Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..isAntiAlias = true);
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return isEnabled ? enabledThumbSize : disabledThumbSize ?? enabledThumbSize;
  }
}

