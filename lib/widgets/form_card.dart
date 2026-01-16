import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_in_touch/models/form_model.dart';
import 'package:keep_in_touch/providers/form_provider.dart';
import 'package:keep_in_touch/widgets/form_state_indicator.dart';
import 'package:provider/provider.dart';

class FormCard extends StatelessWidget {
  final FormModel form;

  const FormCard({
    super.key,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showStateDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Form #${form.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: form.getColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      form.getStateText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FormStateIndicator(form: form),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${DateFormat('yyyy-MM-dd').format(form.createdDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Tap to change state',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStateDialog(BuildContext context) {
    final currentState = form.getState();
    final nextState = form.nextState().getState();
    final prevState = form.previousState().getState();
    final nextForm = form.nextState();
    final prevForm = form.previousState();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Form #${form.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: form.getColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentState.toStatusString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (currentState != FormStateEnum.initial)
              SizedBox(
                width: double.infinity,
                child: _buildStateButton(
                  context,
                  Icons.arrow_back,
                  prevState.toStatusString(),
                  prevForm.getColor(),
                  () => _handlePrevious(context),
                ),
              ),
            if (currentState != FormStateEnum.controlled)
              SizedBox(
                width: double.infinity,
                child: _buildStateButton(
                  context,
                  Icons.arrow_forward,
                  nextState.toStatusString(),
                  nextForm.getColor(),
                  () => _handleNext(context),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStateButton(
    BuildContext context,
    IconData icon,
    String stateName,
    Color buttonColor,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(stateName, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Future<void> _handleNext(BuildContext context) async {
    try {
      await context.read<FormProvider>().nextState(form.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
    }
  }

  Future<void> _handlePrevious(BuildContext context) async {
    try {
      await context.read<FormProvider>().previousState(form.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
    }
  }
}