import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_theme.dart';

/// Grows a control's hit area to [AppSizes.minTouchTarget] without changing a
/// single painted pixel.
///
/// The design draws several controls under Android's 48dp minimum — the
/// detail screen's play pill at ~38, the overlay call to action at ~39, a
/// top-bar button at 38. Re-padding them would mean inventing values the
/// design does not carry (hard rule 7), so the drawn box is left exactly as
/// it is and only the target around it grows. This is the same mechanism
/// Material's own buttons use for `MaterialTapTargetSize.padded`.
///
/// The control keeps its own gesture handler: a tap that lands in the margin
/// is forwarded to the centre of the child, so an ink splash stays on the
/// drawn shape instead of spreading across the larger box.
///
/// It does take room in a layout — a pill in a column makes that column
/// taller. What it never does is move the thing it wraps.
///
/// Put any explicit [Semantics] *outside* this widget, so the node a screen
/// reader reports is the same size as the area a finger can hit.
class TouchTarget extends SingleChildRenderObjectWidget {
  const TouchTarget({
    super.key,
    required Widget super.child,
    this.minimum = AppSizes.minTouchTarget,
  });

  /// The smallest this control may be, on either axis.
  final double minimum;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderTouchTarget(minimum);

  @override
  void updateRenderObject(BuildContext context, RenderTouchTarget renderObject) {
    renderObject.minimum = minimum;
  }
}

/// The box behind [TouchTarget]: lays the child out untouched, takes at least
/// [minimum] on each axis, and forwards a hit in the margin to the centre.
class RenderTouchTarget extends RenderShiftedBox {
  RenderTouchTarget(this._minimum, {RenderBox? child}) : super(child);

  double _minimum;

  double get minimum => _minimum;
  set minimum(double value) {
    if (_minimum == value) {
      return;
    }
    _minimum = value;
    markNeedsLayout();
  }

  Size _grown(Size childSize, BoxConstraints constraints) => constraints.constrain(
        Size(
          math.max(childSize.width, minimum),
          math.max(childSize.height, minimum),
        ),
      );

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), minimum);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(super.computeMaxIntrinsicWidth(height), minimum);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), minimum);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(super.computeMaxIntrinsicHeight(width), minimum);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) {
      return constraints.constrain(Size(minimum, minimum));
    }
    return _grown(child.getDryLayout(constraints), constraints);
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.constrain(Size(minimum, minimum));
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = _grown(child.size, constraints);
    (child.parentData! as BoxParentData).offset =
        Alignment.center.alongOffset(size - child.size as Offset);
  }

  /// A hit anywhere in the grown box counts, and lands on the centre of the
  /// child — which is where the control's own recogniser is listening.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }
    final RenderBox? child = this.child;
    if (child == null || !size.contains(position)) {
      return false;
    }
    final Offset centre =
        child.size.center((child.parentData! as BoxParentData).offset);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(centre),
      position: centre,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == centre);
        return child.hitTest(result, position: centre);
      },
    );
  }
}
