import 'package:flutter/material.dart';

class CanvasItemWrapper<T> extends StatefulWidget {
  final T item;
  final Widget child;
  final GlobalKey canvasKey;
  final Offset position;
  final Size size;
  final double gridSize;
  final bool snapEnabled;
  final bool canResize; // New toggle
  final void Function(T item, Offset newPos, Size newSize) onUpdate;
  final VoidCallback? onLongPress;

  const CanvasItemWrapper({
    super.key,
    required this.item,
    required this.child,
    required this.canvasKey,
    required this.position,
    required this.size,
    required this.onUpdate,
    required this.snapEnabled,
    this.gridSize = 10.0,
    this.canResize = true, // Default to true for ViewConfig
    this.onLongPress,
  });

  @override
  State<CanvasItemWrapper<T>> createState() => _CanvasItemWrapperState<T>();
}

class _CanvasItemWrapperState<T> extends State<CanvasItemWrapper<T>> {
  late Offset _tempPosition;
  late Size _tempSize;
  bool _isResizing = false;
  Offset _pointerOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _tempPosition = widget.position;
    _tempSize = widget.size;
  }

  // Handle external updates (e.g. from Bloc)
  @override
  void didUpdateWidget(CanvasItemWrapper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isResizing) {
      _tempPosition = widget.position;
      _tempSize = widget.size;
    }
  }

  double _snap(double value) => widget.snapEnabled
      ? (value / widget.gridSize).round() * widget.gridSize
      : value;

  void _onPanStart(DragStartDetails details) {
    if (_isResizing) return;
    final box =
        widget.canvasKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);
    _pointerOffset = local - _tempPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isResizing) return;
    final box =
        widget.canvasKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);

    setState(() {
      double newX = _snap(local.dx - _pointerOffset.dx);
      double newY = _snap(local.dy - _pointerOffset.dy);

      final parentSize = box.size;
      final maxX = parentSize.width - _tempSize.width;
      final maxY = parentSize.height - _tempSize.height;

      newX = newX.clamp(0.0, maxX < 0.0 ? 0.0 : maxX);
      newY = newY.clamp(0.0, maxY < 0.0 ? 0.0 : maxY);

      _tempPosition = Offset(newX, newY);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isResizing) return;
    widget.onUpdate(widget.item, _tempPosition, _tempSize);
  }

  void _onResizeStart() => setState(() => _isResizing = true);

  void _onResize(
    DragUpdateDetails details, {
    required bool fromRight,
    required bool fromBottom,
  }) {
    final delta = details.delta;

    setState(() {
      final box =
          widget.canvasKey.currentContext!.findRenderObject() as RenderBox;
      final parentSize = box.size;

      final maxWidth = parentSize.width - _tempPosition.dx;
      final maxHeight = parentSize.height - _tempPosition.dy;

      final double width = fromRight
          ? (_tempSize.width + delta.dx)
              .clamp(40.0, maxWidth < 40.0 ? 40.0 : maxWidth)
              .toDouble()
          : _tempSize.width;

      final double height = fromBottom
          ? (_tempSize.height + delta.dy)
              .clamp(40.0, maxHeight < 40.0 ? 40.0 : maxHeight)
              .toDouble()
          : _tempSize.height;

      _tempSize = Size(width, height);
    });
  }

  void _onResizeEnd() {
    setState(() => _isResizing = false);
    widget.onUpdate(widget.item, _tempPosition, _tempSize);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _tempPosition.dx,
      top: _tempPosition.dy,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onLongPress: widget.onLongPress,
        child: Stack(
          children: [
            SizedBox(
              width: _tempSize.width,
              height: _tempSize.height,
              child: widget.child,
            ),
            if (widget.canResize)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => _onResizeStart(),
                  onPanUpdate: (d) =>
                      _onResize(d, fromRight: true, fromBottom: true),
                  onPanEnd: (_) => _onResizeEnd(),
                  child: const _ResizeTriangle(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResizeTriangle extends StatelessWidget {
  const _ResizeTriangle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(16, 16), painter: _TrianglePainter());
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height - 10)
      ..lineTo(size.width - 10, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
