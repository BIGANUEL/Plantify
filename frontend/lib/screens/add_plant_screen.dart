import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/widgets/plantify_header.dart';
import '../core/widgets/plantify_text_field.dart';
import '../core/widgets/plantify_button.dart';
import '../core/widgets/plantify_card.dart';
import '../core/constants/app_colors.dart';
import '../features/plants/presentation/bloc/plants_bloc.dart';
import '../features/plants/presentation/bloc/plants_event.dart';
import '../features/plants/presentation/bloc/plants_state.dart';
import '../core/utils/date_formatter.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: AppColors.statusRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a next watering date'),
            backgroundColor: AppColors.statusRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      context.read<PlantsBloc>().add(
            PlantCreated(
              name: _nameController.text.trim(),
              type: _typeController.text.trim(),
              nextWateringDate: _selectedDate!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantsBloc, PlantsState>(
      listenWhen: (previous, current) {
        // Listen to state changes when we're loading
        if (!_isLoading) return false;
        // Listen for any state change from Loading to Loaded or Error
        return (previous is PlantsLoading && current is PlantsLoaded) ||
               (current is PlantsError);
      },
      listener: (context, state) {
        if (state is PlantsLoaded) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Plant added successfully!'),
                backgroundColor: AppColors.primaryGreen,
                duration: const Duration(seconds: 2),
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.statusRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        body: Column(
          children: [
            // Header
            PlantifyHeader(
              title: 'Add New Plant',
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.backgroundWhite,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image upload section
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                            child: _selectedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        size: 40,
                                        color: AppColors.primaryGreen,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Plant Name field
                      PlantifyTextField(
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
                      // Plant Type field
                      PlantifyTextField(
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
                      // Next Watering Date field
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: PlantifyCard(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.getTextLightColor(context),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Watering Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.getTextLightColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedDate == null
                                          ? 'Select date'
                                          : DateFormatter.formatDate(_selectedDate!),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedDate == null
                                            ? AppColors.getTextLightColor(context)
                                            : AppColors.getTextColor(context),
                                        fontWeight: _selectedDate == null
                                            ? FontWeight.normal
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.getTextLightColor(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      PlantifyButton(
                        onPressed: _isLoading ? null : _submit,
                        isLoading: _isLoading,
                        text: 'Add Plant',
                        icon: Icons.add_rounded,
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
