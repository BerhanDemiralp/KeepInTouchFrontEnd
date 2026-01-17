import 'package:flutter/material.dart';
import 'package:keep_in_touch/utils/constants.dart';

enum FormStateEnum {
  initial(0),
  sent(1),
  filled(2),
  controlled(3);

  final int value;

  const FormStateEnum(this.value);

  static FormStateEnum fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'controlled':
        return FormStateEnum.controlled;
      case 'filled':
        return FormStateEnum.filled;
      case 'sent':
        return FormStateEnum.sent;
      default:
        return FormStateEnum.initial;
    }
  }

  String toStatusString() {
    switch (this) {
      case FormStateEnum.controlled:
        return 'controlled';
      case FormStateEnum.filled:
        return 'filled';
      case FormStateEnum.sent:
        return 'sent';
      default:
        return 'created';
    }
  }
}

class FormModel {
  final int id;
  final int animalId;
  final String formStatus;
  final DateTime createdDate;
  final String? assignedDate;
  final String? filledDate;
  final String? controlledDate;
  final String? controlDueDate;

  FormModel({
    required this.id,
    required this.animalId,
    required this.formStatus,
    required this.createdDate,
    this.assignedDate,
    this.filledDate,
    this.controlledDate,
    this.controlDueDate,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'] as int,
      animalId: json['animal_id'] as int,
      formStatus: json['form_status'] as String? ?? 'created',
      createdDate: DateTime.parse(json['created_date'] as String),
      assignedDate: json['assigned_date'] as String?,
      filledDate: json['filled_date'] as String?,
      controlledDate: json['controlled_date'] as String?,
      controlDueDate: json['control_due_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'form_status': formStatus,
      'created_date': createdDate.toIso8601String(),
      'assigned_date': assignedDate,
      'filled_date': filledDate,
      'controlled_date': controlledDate,
      'control_due_date': controlDueDate,
    };
  }

  FormStateEnum getState() {
    return FormStateEnum.fromString(formStatus);
  }

  Color getColor() {
    final state = getState();
    switch (state) {
      case FormStateEnum.initial:
        return AppColors.gray;
      case FormStateEnum.sent:
        return AppColors.blue;
      case FormStateEnum.filled:
        return AppColors.green;
      case FormStateEnum.controlled:
        return AppColors.purple;
    }
  }

  String getStateText() {
    return formStatus;
  }

  FormModel copyWith({
    String? formStatus,
  }) {
    return FormModel(
      id: id,
      animalId: animalId,
      formStatus: formStatus ?? this.formStatus,
      createdDate: createdDate,
      assignedDate: assignedDate,
      filledDate: filledDate,
      controlledDate: controlledDate,
      controlDueDate: controlDueDate,
    );
  }

  FormModel nextState() {
    final current = getState();
    if (current == FormStateEnum.initial) {
      return copyWith(formStatus: 'sent');
    } else if (current == FormStateEnum.sent) {
      return copyWith(formStatus: 'filled');
    } else if (current == FormStateEnum.filled) {
      return copyWith(formStatus: 'controlled');
    }
    return this;
  }

  FormModel previousState() {
    final current = getState();
    if (current == FormStateEnum.controlled) {
      return copyWith(formStatus: 'filled');
    } else if (current == FormStateEnum.filled) {
      return copyWith(formStatus: 'sent');
    } else if (current == FormStateEnum.sent) {
      return copyWith(formStatus: 'created');
    }
    return this;
  }
}