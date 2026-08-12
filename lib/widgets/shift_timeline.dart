import 'package:flutter/material.dart';
import 'package:labtrack_pro/theme/app_theme.dart';

class ShiftData {
  final String shiftLabel;
  final String timeRange;
  final String activity;
  final num points;
  final bool isActive;

  const ShiftData({
    required this.shiftLabel,
    required this.timeRange,
    required this.activity,
    required this.points,
    this.isActive = false,
  });
}

class ShiftTimeline extends StatelessWidget {
  final List<ShiftData> shifts;

  const ShiftTimeline({super.key, required this.shifts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(shifts.length, (index) {
        final shift = shifts[index];
        final isLast = index == shifts.length - 1;
        return _ShiftTimelineItem(
          shift: shift,
          isLast: isLast,
        );
      }),
    );
  }
}

class _ShiftTimelineItem extends StatelessWidget {
  final ShiftData shift;
  final bool isLast;

  const _ShiftTimelineItem({
    required this.shift,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Dot
                _PulseDot(isActive: shift.isActive),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppTheme.outlineVariant,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shift.shiftLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: shift.isActive
                                    ? AppTheme.primary
                                    : AppTheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Text(
                        '${shift.points} Points',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: shift.isActive
                                  ? AppTheme.primary
                                  : AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shift.activity,
                    style: shift.isActive
                        ? Theme.of(context).textTheme.headlineSmall
                        : Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final bool isActive;

  const _PulseDot({required this.isActive});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.background, width: 2),
        ),
      );
    }

    return _AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring
              Transform.scale(
                scale: _animation.value,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withValues(
                        alpha: 0.5 * (1 - (_animation.value - 1) / 0.4),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Solid dot
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.background, width: 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimatedBuilder({
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
