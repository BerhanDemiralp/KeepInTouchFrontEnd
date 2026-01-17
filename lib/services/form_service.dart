import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:keep_in_touch/config/api_config.dart';
import 'package:keep_in_touch/models/form_model.dart';
import 'package:keep_in_touch/services/api_service.dart';

class FormService {
  Future<List<FormModel>> getFormsByAnimal(int animalId) async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/forms/animal/$animalId'),
      headers: headers,
    );

    await ApiService.handleResponse(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => FormModel.fromJson(json)).toList();
  }

  Future<FormModel> getForm(int formId) async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/forms/$formId'),
      headers: headers,
    );

    await ApiService.handleResponse(response);
    return FormModel.fromJson(jsonDecode(response.body));
  }

  Future<FormModel> updateForm(int formId, Map<String, dynamic> data) async {
    final headers = await ApiService.getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/forms/$formId'),
      headers: headers,
      body: jsonEncode(data),
    );

    await ApiService.handleResponse(response);
    return FormModel.fromJson(jsonDecode(response.body));
  }

  Future<FormModel> nextState(int formId, FormModel currentForm) async {
    final nextForm = currentForm.nextState();
    return await updateForm(formId, {
      'form_status': nextForm.formStatus,
    });
  }

  Future<FormModel> previousState(int formId, FormModel currentForm) async {
    final prevForm = currentForm.previousState();
    return await updateForm(formId, {
      'form_status': prevForm.formStatus,
    });
  }

  Future<FormModel> createForm(int animalId) async {
    final headers = await ApiService.getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/animals/$animalId/create-form'),
      headers: headers,
    );

    await ApiService.handleResponse(response);
    return FormModel.fromJson(jsonDecode(response.body));
  }

  Future<void> generatePeriodicForms() async {
    final headers = await ApiService.getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/forms/generate-periodic'),
      headers: headers,
    );

    await ApiService.handleResponse(response);
  }
}