import 'package:flutter/material.dart';
import 'package:keep_in_touch/providers/animal_provider.dart';
import 'package:keep_in_touch/providers/auth_provider.dart';
import 'package:keep_in_touch/widgets/animal_card.dart';
import 'package:keep_in_touch/widgets/status_filter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnimalProvider>().fetchAnimals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateAnimalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ownerNameController = TextEditingController();
    final ownerContactController = TextEditingController();
    final ownerEmailController = TextEditingController();
    final periodController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Animal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Animal Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter animal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter owner name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ownerContactController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ownerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: periodController,
                  decoration: const InputDecoration(
                    labelText: 'Form Generation Period (months)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter period';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final auth = context.read<AuthProvider>();
                await context.read<AnimalProvider>().createAnimal({
                  'name': nameController.text,
                  'responsible_user_id': auth.user?.id ?? 1,
                  'owner_name': ownerNameController.text,
                  'owner_contact_number': ownerContactController.text,
                  'owner_contact_email': ownerEmailController.text,
                  'form_generation_period': int.parse(periodController.text),
                });
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Animal created successfully'),
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by animal name or owner name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AnimalProvider>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          context.read<AnimalProvider>().setSearchQuery(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? null : const Text('Keep In Touch'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    context.read<AnimalProvider>().clearSearch();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              );
            },
          ),
        ],
      ),
      body: Consumer<AnimalProvider>(
        builder: (context, animalProvider, child) {
          final filteredAnimals = animalProvider.filteredAnimals;

          return Stack(
            children: [
              Column(
                children: [
                  if (_isSearching) _buildSearchBar(),
                  StatusFilter(
                    selectedFilter: animalProvider.selectedFilter,
                    onFilterChanged: (filter) {
                      animalProvider.setFilter(filter);
                    },
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => animalProvider.fetchAnimals(),
                      child:
                          (animalProvider.isLoading ||
                                  animalProvider.animals.isEmpty) &&
                              animalProvider.errorMessage == null
                          ? const Center(child: CircularProgressIndicator())
                          : animalProvider.errorMessage != null
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.4,
                                    ),
                                    const Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      animalProvider.errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        animalProvider.fetchAnimals();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : filteredAnimals.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.4,
                                    ),
                                    const Icon(
                                      Icons.pets_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      animalProvider.searchQuery.isNotEmpty
                                          ? 'No animals found for "${animalProvider.searchQuery}"'
                                          : 'No animals found',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (animalProvider.searchQuery.isEmpty)
                                      const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: filteredAnimals.length,
                              itemBuilder: (context, index) {
                                final animal = filteredAnimals[index];
                                return AnimalCard(
                                  animal: animal,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/animal-detail',
                                      arguments: animal.id,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'refresh',
                      onPressed: () {
                        animalProvider.fetchAnimals();
                      },
                      child: const Icon(Icons.refresh),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 180,
                      child: FloatingActionButton.extended(
                        heroTag: 'create',
                        onPressed: () => _showCreateAnimalDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Animal'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
