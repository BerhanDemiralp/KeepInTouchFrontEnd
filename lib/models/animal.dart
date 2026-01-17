import 'package:flutter/material.dart';

class Animal {
  final int id;
  final String name;
  final int responsibleUserId;
  final String ownerName;
  final String ownerContactNumber;
  final String ownerContactEmail;
  final int formGenerationPeriod;
  final List<int> formIds;
  final String formStatus;
  final DateTime? lastFormSentDate;
  final DateTime? lastFormCreatedDate;

  Animal({
    required this.id,
    required this.name,
    required this.responsibleUserId,
    required this.ownerName,
    required this.ownerContactNumber,
    required this.ownerContactEmail,
    required this.formGenerationPeriod,
    required this.formIds,
    required this.formStatus,
    this.lastFormSentDate,
    this.lastFormCreatedDate,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as int,
      name: json['name'] as String,
      responsibleUserId: json['responsible_user_id'] as int,
      ownerName: json['owner_name'] as String,
      ownerContactNumber: json['owner_contact_number'] as String,
      ownerContactEmail: json['owner_contact_email'] as String,
      formGenerationPeriod: json['form_generation_period'] as int,
      formIds: (json['form_ids'] as List<dynamic>?)?.cast<int>() ?? [],
      formStatus: json['form_status'] as String? ?? 'created',
      lastFormSentDate: json['last_form_sent_date'] != null 
          ? DateTime.parse(json['last_form_sent_date'] as String) 
          : null,
      lastFormCreatedDate: json['last_form_created_date'] != null 
          ? DateTime.parse(json['last_form_created_date'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'responsible_user_id': responsibleUserId,
      'owner_name': ownerName,
      'owner_contact_number': ownerContactNumber,
      'owner_contact_email': ownerContactEmail,
      'form_generation_period': formGenerationPeriod,
      'form_ids': formIds,
      'form_status': formStatus,
      'last_form_sent_date': lastFormSentDate?.toIso8601String(),
      'last_form_created_date': lastFormCreatedDate?.toIso8601String(),
    };
  }

  String get statusText {
    return formStatus;
  }

  Color getColor() {
    switch (formStatus.toLowerCase()) {
      case 'controlled':
        return const Color(0xFF9C27B0);
      case 'filled':
        return const Color(0xFF4CAF50);
      case 'sent':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}