import 'package:flutter/material.dart';

import '../../games/arcade_game.dart';
import '../../theme/app_theme.dart';

/// The D-pad glyphs, as the design draws them.
const Map<GameInput, String> _arrows = <GameInput, String>{
  GameInput.up: '▲',
  GameInput.down: '▼',
  GameInput.left: '◀',
  GameInput.right: '▶',
};

/// The controls under the field: a 3x3 D-pad and the round action button.
///
/// The D-pad disappears when the player turns it off in settings; the action
/// button stays, because it is the only way to start a run without one.
class PlayControls extends StatelessWidget {
  const PlayControls({
    super.key,
    required this.showDpad,
    required this.actionLabel,
    required this.onDirection,
    required this.onAction,
  });

  final bool showDpad;
  final String actionLabel;
  final ValueChanged<GameInput> onDirection;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (showDpad) ...<Widget>[
          _Dpad(onDirection: onDirection),
          const SizedBox(width: AppSpacing.s26),
        ],
        _ActionButton(label: actionLabel, onTap: onAction),
      ],
    );
  }
}

class _Dpad extends StatelessWidget {
  const _Dpad({required this.onDirection});

  final ValueChanged<GameInput> onDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _DpadRow(
          children: <Widget>[
            const _DpadBlank(),
            _DpadKey(input: GameInput.up, onDirection: onDirection),
            const _DpadBlank(),
          ],
        ),
        const SizedBox(height: AppSpacing.s5),
        _DpadRow(
          children: <Widget>[
            _DpadKey(input: GameInput.left, onDirection: onDirection),
            const _DpadCentre(),
            _DpadKey(input: GameInput.right, onDirection: onDirection),
          ],
        ),
        const SizedBox(height: AppSpacing.s5),
        _DpadRow(
          children: <Widget>[
            const _DpadBlank(),
            _DpadKey(input: GameInput.down, onDirection: onDirection),
            const _DpadBlank(),
          ],
        ),
      ],
    );
  }
}

/// Three cells and the two gutters between them.
class _DpadRow extends StatelessWidget {
  const _DpadRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        children[0],
        const SizedBox(width: AppSpacing.s5),
        children[1],
        const SizedBox(width: AppSpacing.s5),
        children[2],
      ],
    );
  }
}

class _DpadBlank extends StatelessWidget {
  const _DpadBlank();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: AppSizes.dpadKey);
}

/// The dead centre of the pad. Drawn, but it takes no input.
class _DpadCentre extends StatelessWidget {
  const _DpadCentre();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: AppSizes.dpadKey,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfacePressed,
          borderRadius: AppBorderRadius.control,
        ),
      ),
    );
  }
}

/// One arrow key. At 54px it already clears the platform's touch minimum.
class _DpadKey extends StatefulWidget {
  const _DpadKey({required this.input, required this.onDirection});

  final GameInput input;
  final ValueChanged<GameInput> onDirection;

  @override
  State<_DpadKey> createState() => _DpadKeyState();
}

class _DpadKeyState extends State<_DpadKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (TapDownDetails _) => _setPressed(true),
      onTapUp: (TapUpDetails _) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () => widget.onDirection(widget.input),
      child: Semantics(
        button: true,
        label: widget.input.name,
        child: SizedBox.square(
          dimension: AppSizes.dpadKey,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _pressed
                  ? AppColors.positiveTintPressed
                  : AppColors.surfaceRaised,
              borderRadius: AppBorderRadius.control,
              border: Border.all(
                color: AppColors.borderStrong,
                width: AppBorderWidths.hairline,
              ),
            ),
            child: Center(
              child: Text(_arrows[widget.input]!, style: AppTextStyles.dpadGlyph),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.actionButton,
        height: AppSizes.actionButton,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.actionButton,
          boxShadow: AppShadows.actionButton,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.pixelLabel.copyWith(color: AppColors.onAccent),
        ),
      ),
    );
  }
}
