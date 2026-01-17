import 'package:flutter/foundation.dart';
import 'package:keep_in_touch/models/form_model.dart';
import 'package:keep_in_touch/providers/animal_provider.dart';
import 'package:keep_in_touch/services/form_service.dart';

class FormProvider extends ChangeNotifier {
  final FormService _formService = FormService();
  AnimalProvider? _animalProvider;

  void setAnimalProvider(AnimalProvider animalProvider) {
    _animalProvider = animalProvider;
  }

  List<FormModel> _forms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FormModel> get forms => _forms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<FormModel> get latestForms {
    if (_forms.isEmpty) return [];
    return _forms.take(3).toList();
  }

  List<FormModel> get olderForms {
    if (_forms.length <= 3) return [];
    return _forms.skip(3).toList();
  }

  Future<void> fetchFormsByAnimal(int animalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _forms = await _formService.getFormsByAnimal(animalId);
      _forms.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FormModel> nextState(int formId) async {
    final form = _forms.firstWhere((f) => f.id == formId);
    final nextForm = await _formService.nextState(formId, form);

    final index = _forms.indexWhere((f) => f.id == formId);
    if (index != -1) {
      _forms[index] = nextForm;
    }

    notifyListeners();
    return nextForm;
  }

  Future<FormModel> previousState(int formId) async {
    final form = _forms.firstWhere((f) => f.id == formId);
    final prevForm = await _formService.previousState(formId, form);

    final index = _forms.indexWhere((f) => f.id == formId);
    if (index != -1) {
      _forms[index] = prevForm;
    }

    notifyListeners();
    return prevForm;
  }

  Future<FormModel> createForm(int animalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newForm = await _formService.createForm(animalId);
      _forms.insert(0, newForm);
      _forms.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      // Refresh animal data to update status and dates
      if (_animalProvider != null) {
        await _animalProvider!.getAnimal(animalId);
      }
      
      _isLoading = false;
      notifyListeners();
      return newForm;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generatePeriodicForms() async {
    await _formService.generatePeriodicForms();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
