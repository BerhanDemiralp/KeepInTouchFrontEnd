import 'package:flutter/foundation.dart';
import 'package:keep_in_touch/models/animal.dart';
import 'package:keep_in_touch/services/animal_service.dart';

class AnimalProvider extends ChangeNotifier {
  final AnimalService _animalService = AnimalService();
  
  List<Animal> _animals = [];
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Animal> get animals => _animals;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Animal> get filteredAnimals {
    var result = _animalService.filterAnimals(_animals, _selectedFilter);
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((animal) {
        return animal.name.toLowerCase().contains(query) ||
               animal.ownerName.toLowerCase().contains(query);
      }).toList();
    }
    
    return result;
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
    final animal = await _animalService.getAnimal(animalId);
    final index = _animals.indexWhere((a) => a.id == animalId);
    if (index != -1) {
      _animals[index] = animal;
    }
    notifyListeners();
    return animal;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<Animal> createAnimal(Map<String, dynamic> data) async {
    final newAnimal = await _animalService.createAnimal(data);
    _animals.insert(0, newAnimal);
    notifyListeners();
    return newAnimal;
  }

  Future<Animal> updateAnimal(int animalId, Map<String, dynamic> data) async {
    final updatedAnimal = await _animalService.updateAnimal(animalId, data);
    final index = _animals.indexWhere((a) => a.id == animalId);
    if (index != -1) {
      _animals[index] = updatedAnimal;
    }
    notifyListeners();
    return updatedAnimal;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}