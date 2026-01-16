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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalProvider>().fetchAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keep In Touch'),
        actions: [
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

          return Column(
            children: [
              StatusFilter(
                selectedFilter: animalProvider.selectedFilter,
                onFilterChanged: (filter) {
                  animalProvider.setFilter(filter);
                },
              ),
              Expanded(
                child: animalProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredAnimals.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No animals found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<AnimalProvider>().fetchAnimals();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }
}
