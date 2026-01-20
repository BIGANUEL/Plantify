import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../core/widgets/plantify_card.dart';
import '../core/widgets/plantify_button.dart';
import '../core/widgets/plantify_text_field.dart';
import '../core/constants/app_colors.dart';

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
  late TextEditingController _careTipsController;
  
  late int _wateringInterval;
  String? _light;
  String? _humidity;
  bool _isLoading = false;

  final List<String> _lightOptions = [
    'Low',
    'Medium',
    'Bright',
    'Direct Sunlight',
  ];

  final List<String> _humidityOptions = [
    'Low',
    'Medium',
    'High',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _typeController = TextEditingController(text: widget.plant.type);
    _careTipsController = TextEditingController(text: widget.plant.careTips ?? '');
    _wateringInterval = widget.plant.wateringInterval;
    _light = widget.plant.light;
    _humidity = widget.plant.humidity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _careTipsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<PlantsBloc>().add(
        PlantUpdated(
          id: widget.plant.id,
          name: _nameController.text.trim(),
          type: _typeController.text.trim(),
          wateringInterval: _wateringInterval,
          light: _light,
          humidity: _humidity,
          careTips: _careTipsController.text.trim().isEmpty ? null : _careTipsController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: BlocListener<PlantsBloc, PlantsState>(
        listener: (context, state) {
          if (state is PlantsLoaded) {
            // Plant updated successfully, navigate back
            if (_isLoading) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Plant updated successfully!'),
                    ],
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          } else if (state is PlantsError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(state.message),
                    ),
                  ],
                ),
                backgroundColor: AppColors.statusRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Plant',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Plant Name
                        PlantifyTextField(
                          controller: _nameController,
                          label: 'Plant Name',
                          icon: Icons.eco_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter plant name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Plant Type
                        PlantifyTextField(
                          controller: _typeController,
                          label: 'Plant Type',
                          icon: Icons.local_florist_rounded,
                          hintText: 'e.g., Monstera, Pothos, Snake Plant',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter plant type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Watering Interval
                        PlantifyCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.water_drop_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Watering Interval',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Every $_wateringInterval days',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.getTextColor(context),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: _wateringInterval > 1
                                            ? () {
                                                setState(() {
                                                  _wateringInterval--;
                                                });
                                              }
                                            : null,
                                        color: AppColors.primaryGreen,
                                      ),
                                      Container(
                                        width: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$_wateringInterval',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          setState(() {
                                            _wateringInterval++;
                                          });
                                        },
                                        color: AppColors.primaryGreen,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Light Requirement
                        PlantifyCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.wb_sunny_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Light Requirement',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _light,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.getCardBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                hint: Text(
                                  'Select light requirement',
                                  style: TextStyle(
                                    color: AppColors.getTextLightColor(context),
                                  ),
                                ),
                                items: _lightOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: AppColors.getTextColor(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _light = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Humidity Requirement
                        PlantifyCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.opacity_rounded,
                                    color: AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Humidity Requirement',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _humidity,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.getCardBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                hint: Text(
                                  'Select humidity requirement',
                                  style: TextStyle(
                                    color: AppColors.getTextLightColor(context),
                                  ),
                                ),
                                items: _humidityOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: AppColors.getTextColor(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _humidity = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Care Tips (Optional)
                        PlantifyTextField(
                          controller: _careTipsController,
                          label: 'Care Tips (Optional)',
                          icon: Icons.tips_and_updates_rounded,
                          hintText: 'Add any special care instructions',
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          validator: null,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        PlantifyButton(
                          text: 'Update Plant',
                          icon: Icons.save_rounded,
                          onPressed: _isLoading ? null : _submitForm,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
