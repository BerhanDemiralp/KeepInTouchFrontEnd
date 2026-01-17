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
  bool _isEditing = false;

  late Future<Animal> _animalFuture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerContactController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animalId = ModalRoute.of(context)!.settings.arguments as int;
    _animalFuture = context.read<AnimalProvider>().getAnimal(animalId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormProvider>().setAnimalProvider(context.read<AnimalProvider>());
      context.read<FormProvider>().fetchFormsByAnimal(animalId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerNameController.dispose();
    _ownerContactController.dispose();
    _ownerEmailController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _startEditing(Animal animal) {
    _nameController.text = animal.name;
    _ownerNameController.text = animal.ownerName;
    _ownerContactController.text = animal.ownerContactNumber;
    _ownerEmailController.text = animal.ownerContactEmail;
    _periodController.text = animal.formGenerationPeriod.toString();
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveChanges(int animalId, Animal originalAnimal) async {
    try {
      final updatedAnimal = await context.read<AnimalProvider>().updateAnimal(
        animalId,
        {
          'name': _nameController.text,
          'owner_name': _ownerNameController.text,
          'owner_contact_number': _ownerContactController.text,
          'owner_contact_email': _ownerEmailController.text,
          'form_generation_period': int.parse(_periodController.text),
        },
      );
      
      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating animal: $e')),
        );
      }
    }
  }

  void _cancelEditing(Animal animal) {
    _nameController.text = animal.name;
    _ownerNameController.text = animal.ownerName;
    _ownerContactController.text = animal.ownerContactNumber;
    _ownerEmailController.text = animal.ownerContactEmail;
    _periodController.text = animal.formGenerationPeriod.toString();
    setState(() {
      _isEditing = false;
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
        title: Text(_isEditing ? 'Edit Animal' : 'Animal Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final animal = await context.read<AnimalProvider>().getAnimal(animalId);
                _startEditing(animal);
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: () async {
                await _saveChanges(animalId, Animal(
                  id: animalId,
                  name: _nameController.text,
                  responsibleUserId: 1,
                  ownerName: _ownerNameController.text,
                  ownerContactNumber: _ownerContactController.text,
                  ownerContactEmail: _ownerEmailController.text,
                  formGenerationPeriod: int.parse(_periodController.text),
                  formIds: [],
                  formStatus: 'created',
                ));
              },
              child: const Text(
                'Complete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () async {
                final animal = await context.read<AnimalProvider>().getAnimal(animalId);
                _cancelEditing(animal);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Consumer2<AnimalProvider, FormProvider>(
        builder: (context, animalProvider, formProvider, _) {
          return FutureBuilder<Animal>(
            future: _animalFuture,
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Animal Information'),
                    _buildInfoCard(_isEditing ? _buildEditableInfoRows() : [
                      _buildInfoRow('Name', animal.name),
                      _buildInfoRow('Form Period', '${animal.formGenerationPeriod} months'),
                      _buildInfoRow('Status', animal.statusText),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Owner Information'),
                    _buildInfoCard(_isEditing ? _buildEditableOwnerRows() : [
                      _buildInfoRow('Owner Name', animal.ownerName),
                      _buildInfoRow('Contact Number', animal.ownerContactNumber),
                      _buildInfoRow('Email', animal.ownerContactEmail),
                    ]),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Forms',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await context.read<FormProvider>().createForm(animalId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Form created successfully')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error creating form: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Form'),
                        ),
                      ],
                    ),
                    if (formProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (formProvider.forms.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                'No forms found',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await context.read<FormProvider>().createForm(animalId);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Form created successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error creating form: $e')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create First Form'),
                              ),
                            ],
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

  List<Widget> _buildEditableInfoRows() {
    return [
      _buildEditableRow('Name', _nameController, TextInputType.text),
      _buildEditableRow('Form Period (months)', _periodController, TextInputType.number),
    ];
  }

  List<Widget> _buildEditableOwnerRows() {
    return [
      _buildEditableRow('Owner Name', _ownerNameController, TextInputType.text),
      _buildEditableRow('Contact Number', _ownerContactController, TextInputType.phone),
      _buildEditableRow('Email', _ownerEmailController, TextInputType.emailAddress),
    ];
  }

  Widget _buildEditableRow(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
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
