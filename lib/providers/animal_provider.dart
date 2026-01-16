import 'package:flutter/foundation.dart';
import 'package:keep_in_touch/models/animal.dart';
import 'package:keep_in_touch/services/animal_service.dart';

class AnimalProvider extends ChangeNotifier {
  final AnimalService _animalService = AnimalService();
  
  List<Animal> _animals = [];
  String _selectedFilter = 'all';
  bool _isLoading = false;
  String? _errorMessage;

  List<Animal> get animals => _animals;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Animal> get filteredAnimals {
    return _animalService.filterAnimals(_animals, _selectedFilter);
  }

  Future<void> fetchAnimals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _animals = await _animalService.getAnimals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Animal> getAnimal(int animalId) async {
    return await _animalService.getAnimal(animalId);
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}