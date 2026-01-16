import 'package:flutter/material.dart';
import 'package:keep_in_touch/models/animal.dart';
import 'package:keep_in_touch/providers/form_provider.dart';
import 'package:keep_in_touch/providers/animal_provider.dart';
import 'package:keep_in_touch/widgets/form_card.dart';
import 'package:provider/provider.dart';

class AnimalDetailScreen extends StatefulWidget {
  const AnimalDetailScreen({super.key});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  bool _isExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animalId = ModalRoute.of(context)!.settings.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormProvider>().fetchFormsByAnimal(animalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AnimalProvider>().fetchAnimals();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Animal Details'),
      ),
      body: FutureBuilder<Animal>(
        future: context.read<AnimalProvider>().getAnimal(animalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final animal = snapshot.data!;
          return Consumer<FormProvider>(
            builder: (context, formProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _buildSectionHeader('Animal Information'),
                    _buildInfoCard([
                      _buildInfoRow('Name', animal.name),
                      _buildInfoRow('Form Period', '${animal.formGenerationPeriod} months'),
                      _buildInfoRow('Status', animal.statusText),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Owner Information'),
                    _buildInfoCard([
                      _buildInfoRow('Owner Name', animal.ownerName),
                      _buildInfoRow('Contact Number', animal.ownerContactNumber),
                      _buildInfoRow('Email', animal.ownerContactEmail),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Forms'),
                    if (formProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (formProvider.forms.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No forms found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      _buildFormsList(formProvider),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFormsList(FormProvider formProvider) {
    final latestForms = formProvider.latestForms;
    final olderForms = formProvider.olderForms;

    return Column(
      children: [
        ...latestForms.map((form) => FormCard(form: form)),
        if (olderForms.isNotEmpty)
          ExpansionTile(
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            title: Text('Show ${olderForms.length} older forms'),
            children: olderForms.map((form) => FormCard(form: form)).toList(),
          ),
      ],
    );
  }
}