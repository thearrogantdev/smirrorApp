import 'package:flutter/material.dart';
import 'package:smirror_app/items/common_draggable_wrapper.dart';

class CommonCanvas<T> extends StatelessWidget {
  final List<T> items;
  final double gridSize;
  final bool snapEnabled;
  final bool canResize;

  // Mapping helpers to interpret your data model
  final double Function(T item) getX;
  final double Function(T item) getY;
  final double Function(T item) getWidth;
  final double Function(T item) getHeight;

  // Builder for the item's content
  final Widget Function(T item) builder;

  // Events
  final void Function(T item, Offset newPos, Size newSize) onUpdateItem;
  final void Function(Offset localPos) onLongPressCanvas;
  final void Function(T item) onLongPressItem;

  final GlobalKey _canvasKey = GlobalKey();

  CommonCanvas({
    super.key,
    required this.items,
    required this.gridSize,
    required this.snapEnabled,
    required this.canResize,
    required this.getX,
    required this.getY,
    required this.getWidth,
    required this.getHeight,
    required this.builder,
    required this.onUpdateItem,
    required this.onLongPressCanvas,
    required this.onLongPressItem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) {
        final box = context.findRenderObject() as RenderBox;
        onLongPressCanvas(box.globalToLocal(details.globalPosition));
      },
      child: Container(
        key: _canvasKey,
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: items.map((item) {
            return CanvasItemWrapper<T>(
              key: ValueKey(item.hashCode), // Or a unique ID from your model
              item: item,
              canvasKey: _canvasKey,
              gridSize: gridSize,
              snapEnabled: snapEnabled,
              canResize: canResize,
              position: Offset(getX(item), getY(item)),
              size: Size(getWidth(item), getHeight(item)),
              onUpdate: onUpdateItem,
              onLongPress: () => onLongPressItem(item),
              child: builder(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
