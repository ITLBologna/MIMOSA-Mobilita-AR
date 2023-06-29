import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size, Offset? offset);

class WidgetSizeRenderObject extends RenderProxyBox {

  final OnWidgetSizeChange onSizeChange;
  final BuildContext buildContext;
  Size? currentSize;

  WidgetSizeRenderObject(this.onSizeChange, this.buildContext);

  @override
  void performLayout() {
    super.performLayout();

    try {
      final Size? newSize = child?.size;

      if (newSize != null && currentSize != newSize) {
        currentSize = newSize;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSizeChange(newSize, buildContext.globalPaintBounds);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

class WidgetSizeOffsetWrapper extends SingleChildRenderObjectWidget {

  final OnWidgetSizeChange onSizeChange;

  const WidgetSizeOffsetWrapper({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return WidgetSizeRenderObject(onSizeChange, context);
  }
}

extension GlobalPaintBounds on BuildContext {
  Offset? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return Offset(translation.x, translation.y);
    } else {
      return null;
    }
  }
}