import 'package:flutter/material.dart';

class RegisterStepProgress extends StatelessWidget {
  const RegisterStepProgress({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(2, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 0 ? 10 : 0),
            height: 6,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? colors.primary
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
