import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/widgets/animated_text_field.dart';
import '../features/auth/presentation/widgets/gradient_button.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';

class EditPlantScreen extends StatefulWidget {
  final Plant plant;

  const EditPlantScreen({
    super.key,
    required this.plant,
  });

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _wateringIntervalController;
  late TextEditingController _lightController;
  late TextEditingController _humidityController;
  late TextEditingController _careTipsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _typeController = TextEditingController(text: widget.plant.type);
    _wateringIntervalController =
        TextEditingController(text: widget.plant.wateringInterval.toString());
    _lightController = TextEditingController(text: widget.plant.light ?? '');
    _humidityController = TextEditingController(text: widget.plant.humidity ?? '');
    _careTipsController = TextEditingController(text: widget.plant.careTips ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _wateringIntervalController.dispose();
    _lightController.dispose();
    _humidityController.dispose();
    _careTipsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final interval = int.tryParse(_wateringIntervalController.text.trim());
      if (interval == null || interval < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watering interval must be at least 1 day'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      context.read<PlantsBloc>().add(
            PlantUpdated(
              id: widget.plant.id,
              name: _nameController.text.trim(),
              type: _typeController.text.trim(),
              wateringInterval: interval,
              light: _lightController.text.trim().isEmpty
                  ? null
                  : _lightController.text.trim(),
              humidity: _humidityController.text.trim().isEmpty
                  ? null
                  : _humidityController.text.trim(),
              careTips: _careTipsController.text.trim().isEmpty
                  ? null
                  : _careTipsController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantsBloc, PlantsState>(
      listenWhen: (previous, current) {
        return _isLoading && (current is PlantsLoaded || current is PlantsError);
      },
      listener: (context, state) {
        if (state is PlantsLoaded) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Plant updated successfully!'),
                backgroundColor: Color(0xFF4CAF50),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (state is PlantsError) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Edit Plant',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plant Name
                AnimatedTextField(
                  controller: _nameController,
                  label: 'Plant Name',
                  icon: Icons.label_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter plant name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Plant Type
                AnimatedTextField(
                  controller: _typeController,
                  label: 'Plant Type',
                  icon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter plant type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Watering Interval (days)
                AnimatedTextField(
                  controller: _wateringIntervalController,
                  label: 'Watering Interval (days)',
                  icon: Icons.water_drop,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter watering interval';
                    }
                    final interval = int.tryParse(value.trim());
                    if (interval == null || interval < 1) {
                      return 'Interval must be at least 1 day';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Light
                AnimatedTextField(
                  controller: _lightController,
                  label: 'Light Requirements (e.g., Bright, Medium, Low)',
                  icon: Icons.wb_sunny_outlined,
                ),
                const SizedBox(height: 16),
                // Humidity
                AnimatedTextField(
                  controller: _humidityController,
                  label: 'Humidity (e.g., High, Medium, Low)',
                  icon: Icons.opacity_outlined,
                ),
                const SizedBox(height: 16),
                // Care Tips
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _careTipsController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Care Tips',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.tips_and_updates_outlined,
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Save button
                GradientButton(
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                  text: 'Save Changes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

