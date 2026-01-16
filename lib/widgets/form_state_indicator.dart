import 'package:flutter/material.dart';
import 'package:keep_in_touch/models/form_model.dart';

class FormStateIndicator extends StatelessWidget {
  final FormModel form;

  const FormStateIndicator({
    super.key,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    final state = form.getState();

    return Row(
      children: [
        _buildDot(FormStateEnum.initial, const Color(0xFF9E9E9E), state),
        _buildLine(FormStateEnum.initial, const Color(0xFF9E9E9E), state),
        _buildDot(FormStateEnum.sent, const Color(0xFF2196F3), state),
        _buildLine(FormStateEnum.sent, const Color(0xFF2196F3), state),
        _buildDot(FormStateEnum.filled, const Color(0xFF4CAF50), state),
        _buildLine(FormStateEnum.filled, const Color(0xFF4CAF50), state),
        _buildDot(FormStateEnum.controlled, const Color(0xFF9C27B0), state),
      ],
    );
  }

  Widget _buildDot(FormStateEnum dotState, Color dotColor, FormStateEnum currentState) {
    final isActive = currentState.index >= dotState.index;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? dotColor : const Color(0xFF9E9E9E).withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLine(FormStateEnum lineState, Color lineColor, FormStateEnum currentState) {
    final isActive = currentState.index > lineState.index;
    return Container(
      width: 24,
      height: 2,
      color: isActive ? lineColor : const Color(0xFF9E9E9E).withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}