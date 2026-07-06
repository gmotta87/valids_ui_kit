import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/sizing.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_spinner.dart';

/// Which icon a toast shows, mirroring the DS `icon` option
/// (`check-circle | error | warning | lightbulb | loading`).
enum ValidsToastType { success, error, warning, info, loading }

class _ToastData {
  final String title;
  final String? description;
  final ValidsToastType type;

  const _ToastData({required this.title, this.description, required this.type});

  _ToastData copyWith({
    String? title,
    String? description,
    ValidsToastType? type,
  }) {
    return _ToastData(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }
}

class _ToastHandle {
  VoidCallback? dismiss;
  void Function(Duration?)? resetTimer;
}

/// Controls a shown toast: [update] it in place or [dismiss] it
/// (mirrors the DS `toast.update` / `toast.close` manager API).
class ValidsToastController {
  final ValueNotifier<_ToastData> _notifier;
  final _ToastHandle _handle;

  ValidsToastController._(this._notifier, this._handle);

  /// Updates the toast content in place (e.g. loading → success).
  void update({
    String? title,
    String? description,
    ValidsToastType? type,
    Duration? timeout,
  }) {
    _notifier.value = _notifier.value.copyWith(
      title: title,
      description: description,
      type: type,
    );
    _handle.resetTimer?.call(timeout);
  }

  void dismiss() => _handle.dismiss?.call();
}

/// Transient notification mirroring the design system's `ds-toast`.
///
/// DS anatomy: a `w-2xs` (288px) card pinned `top-lg`, centered horizontally
/// on narrow screens and right-aligned from the `md` breakpoint; `rounded-md`
/// on `bg` neutral-75 with a neutral-300 `border-sm`, `p-md` and `shadow-lg`.
/// Content is a centered row with `gap-x-xs`: optional icon (24px, inheriting
/// the default text color), a text column (title `ts-body-highlight-sm` when
/// there is a description, otherwise `ts-body-sm`; description `ts-body-sm`)
/// and a neutral ghost close button. Auto-dismisses after 10s by default.
///
/// Extras beyond the DS: [ValidsToastController] returned by [show] for
/// in-place updates, [showIcon] / [showCloseButton] toggles and a
/// per-toast [timeout]. `loading` toasts never auto-dismiss.
class ValidsToast {
  ValidsToast._();

  /// DS default toast timeout (`timeout = 10000` ms).
  static const Duration defaultTimeout = Duration(seconds: 10);

  static int _activeCount = 0;

  static ValidsToastController show(
    BuildContext context, {
    required String title,
    String? description,
    ValidsToastType type = ValidsToastType.info,
    bool showIcon = true,
    bool showCloseButton = true,
    Duration timeout = defaultTimeout,
  }) {
    final OverlayState overlay = Overlay.of(context);
    final int stackIndex = _activeCount;
    _activeCount++;

    final notifier = ValueNotifier<_ToastData>(
      _ToastData(title: title, description: description, type: type),
    );
    final handle = _ToastHandle();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ValidsToastWidget(
        data: notifier,
        handle: handle,
        showIcon: showIcon,
        showCloseButton: showCloseButton,
        timeout: timeout,
        stackIndex: stackIndex,
        onDismissed: () {
          entry.remove();
          notifier.dispose();
          _activeCount--;
        },
      ),
    );

    overlay.insert(entry);
    return ValidsToastController._(notifier, handle);
  }
}

class _ValidsToastWidget extends StatefulWidget {
  final ValueNotifier<_ToastData> data;
  final _ToastHandle handle;
  final bool showIcon;
  final bool showCloseButton;
  final Duration timeout;
  final int stackIndex;
  final VoidCallback onDismissed;

  const _ValidsToastWidget({
    required this.data,
    required this.handle,
    required this.showIcon,
    required this.showCloseButton,
    required this.timeout,
    required this.stackIndex,
    required this.onDismissed,
  });

  @override
  State<_ValidsToastWidget> createState() => _ValidsToastWidgetState();
}

class _ValidsToastWidgetState extends State<_ValidsToastWidget>
    with SingleTickerProviderStateMixin {
  /// DS `md` breakpoint (768px): below it the viewport is top-centered,
  /// from it onwards it is pinned to the top-right corner.
  static const double _mdBreakpoint = 768;

  /// DS icons render at `size-lg` (24px) and inherit `currentColor`.
  static const double _iconSize = ValidsSpacing.lg;

  /// Vertical stride between simultaneously visible toasts. The DS measures
  /// each toast and stacks them `--gap: spacing-sm` apart; without measuring
  /// we approximate with a fixed stride.
  static const double _stackStride = 80;

  /// DS `shadow-lg` (two 10%-black layers).
  static const List<BoxShadow> _shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  // Slides in from above, like the DS top-anchored viewport.
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.4),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    widget.handle.dismiss = _dismiss;
    widget.handle.resetTimer = _resetTimer;
    _controller.forward();
    _startTimer(widget.timeout);
  }

  void _startTimer(Duration timeout) {
    _timer?.cancel();
    // Loading toasts wait for an explicit update/dismiss (DS `timeout: 0`).
    if (widget.data.value.type == ValidsToastType.loading) return;
    _timer = Timer(timeout, _dismiss);
  }

  void _resetTimer(Duration? timeout) => _startTimer(timeout ?? widget.timeout);

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  /// DS icon mapping (`check-circle`, `error`, `warning`, `lightbulb`,
  /// `loading` → neutral small spinner). Icons inherit the default text
  /// color — the DS toast is neutral regardless of the icon.
  Widget _leading(ValidsToastType type) {
    if (type == ValidsToastType.loading) {
      return const ValidsSpinner(
        kind: ValidsSpinnerKind.neutral,
        size: ValidsSpinnerSize.sm,
      );
    }
    final IconData icon;
    switch (type) {
      case ValidsToastType.success:
        icon = Icons.check_circle_outline;
        break;
      case ValidsToastType.error:
        icon = Icons.error_outline;
        break;
      case ValidsToastType.warning:
        icon = Icons.warning_amber_rounded;
        break;
      case ValidsToastType.info:
      case ValidsToastType.loading:
        icon = Icons.lightbulb_outline;
        break;
    }
    return Icon(icon, size: _iconSize, color: ValidsColors.textDefault);
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final EdgeInsets viewPadding = MediaQuery.paddingOf(context);
    final bool wide = screen.width >= _mdBreakpoint;
    // ds-toast-viewport is w-2xs (288px); keep a p-md gutter on tiny screens.
    final double width = math.min(
      ValidsSizing.xs2,
      screen.width - 2 * ValidsSpacing.md,
    );

    return Positioned(
      // top-lg below the safe area, stacking subsequent toasts downwards.
      top: ValidsSpacing.lg +
          viewPadding.top +
          widget.stackIndex * _stackStride,
      // md+: right-lg; below md: horizontally centered.
      left: wide ? null : (screen.width - width) / 2,
      right: wide ? ValidsSpacing.lg : null,
      width: width,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            color: Colors.transparent,
            child: ValueListenableBuilder<_ToastData>(
              valueListenable: widget.data,
              builder: (context, data, _) {
                return Container(
                  padding: const EdgeInsets.all(ValidsSpacing.md),
                  decoration: BoxDecoration(
                    color: ValidsColors.backgroundSofter, // neutral-75
                    borderRadius: ValidsRadius.mdRadius,
                    border: Border.all(
                      color: ValidsColors.borderSoft, // neutral-300
                      width: ValidsBorderWidth.sm,
                    ),
                    boxShadow: _shadowLg,
                  ),
                  // toast-content: row, items-center, gap-x-xs.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.showIcon) ...[
                        _leading(data.type),
                        const SizedBox(width: ValidsSpacing.xs),
                      ],
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: (data.description != null
                                      ? ValidsTypography.bodyHighlightSm
                                      : ValidsTypography.bodySm)
                                  .copyWith(color: ValidsColors.textDefault),
                            ),
                            if (data.description != null)
                              Text(
                                data.description!,
                                style: ValidsTypography.bodySm.copyWith(
                                  color: ValidsColors.textDefault,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.showCloseButton) ...[
                        const SizedBox(width: ValidsSpacing.xs),
                        _ToastCloseButton(onTap: _dismiss),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The DS `ds-toast-close`: neutral ghost icon button (`text-soft` X,
/// `rounded-sm`, hover `bg-bold/10`).
class _ToastCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ToastCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ValidsRadius.smRadius,
      hoverColor: ValidsColors.backgroundBold.withValues(alpha: 0.10),
      child: Semantics(
        label: 'Fechar notificação',
        button: true,
        child: const Icon(
          Icons.close,
          size: _ValidsToastWidgetState._iconSize,
          color: ValidsColors.textSoft,
        ),
      ),
    );
  }
}
