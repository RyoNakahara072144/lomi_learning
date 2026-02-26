import 'package:flutter/material.dart';

class LearningSupportFab extends StatefulWidget {
  const LearningSupportFab({super.key});

  @override
  State<LearningSupportFab> createState() => _LearningSupportFabState();
}

class _LearningSupportFabState extends State<LearningSupportFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  static const _options = [
    (icon: Icons.assignment_outlined, label: '課題提出'),
    (icon: Icons.quiz_outlined, label: '理解度チェック'),
    (icon: Icons.smart_toy_outlined, label: 'AIに質問'),
    (icon: Icons.headset_mic_outlined, label: '講師に質問'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onOptionTap(String label) {
    _toggle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label を開きます'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Options
        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final delay = index * 0.1;
              final delayedValue =
                  ((_expandAnimation.value - delay) / (1 - delay))
                      .clamp(0.0, 1.0);

              return Transform.scale(
                scale: delayedValue,
                alignment: Alignment.bottomRight,
                child: Opacity(
                  opacity: delayedValue,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icon button
                  FloatingActionButton.small(
                    heroTag: option.label,
                    onPressed: () => _onOptionTap(option.label),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2563EB),
                    elevation: 4,
                    child: Icon(option.icon),
                  ),
                ],
              ),
            ),
          );
        }).toList().reversed.toList(),

        const SizedBox(height: 4),

        // Main FAB
        FloatingActionButton.extended(
          heroTag: 'main_fab',
          onPressed: _toggle,
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 6,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add),
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _isExpanded ? '閉じる' : '学習サポート',
              key: ValueKey(_isExpanded),
            ),
          ),
        ),
      ],
    );
  }
}