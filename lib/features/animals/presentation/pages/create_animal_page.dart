import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vacapp/features/animals/data/models/animal_dto.dart';
import 'package:vacapp/features/animals/data/repositories/animal_repository.dart';
import 'package:vacapp/features/animals/domain/usescase/create_animal.dart';
import 'package:vacapp/core/themes/color_palette.dart';
import 'package:vacapp/features/animals/presentation/widgets/StableDropdown.dart';
import 'package:vacapp/features/animals/presentation/widgets/gender_cupertino_picker.dart';
import 'package:vacapp/features/animals/presentation/widgets/breed_cupertino_picker.dart';
import 'package:vacapp/features/animals/presentation/widgets/location_cupertino_picker.dart';

class CreateAnimalPage extends StatefulWidget {
  final AnimalRepository repository;
  const CreateAnimalPage({super.key, required this.repository});

  @override
  State<CreateAnimalPage> createState() => _CreateAnimalPageState();
}

class _CreateAnimalPageState extends State<CreateAnimalPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  String? _selectedGender;
  String? _selectedBreed;
  String? _selectedLocation;
  int? _selectedStableId;
  DateTime? _birthDate;
  File? _localImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showImageOptions() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Seleccionar imagen'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Tomar foto'),
            onPressed: () async {
              Navigator.pop(context);
              final result = await ImagePicker().pickImage(source: ImageSource.camera);
              if (result != null) setState(() => _localImage = File(result.path));
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Elegir de galería'),
            onPressed: () async {
              Navigator.pop(context);
              final result = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (result != null) setState(() => _localImage = File(result.path));
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: ColorPalette.primaryColor,
            onPrimary: Colors.white,
            surface: ColorPalette.secondaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }


Future<void> _saveAnimal() async {
  if (!_formKey.currentState!.validate()) {
    _showErrorDialog('Por favor completa todos los campos obligatorios.');
    return;
  }
  if (_birthDate == null) {
    _showErrorDialog('Selecciona la fecha de nacimiento.');
    return;
  }
  if (_selectedStableId == null || _selectedStableId == 0) {
    _showErrorDialog('Selecciona un establo disponible.');
    return;
  }
  if (_selectedGender == null ||
      (_selectedGender != 'Male' && _selectedGender != 'Female')) {
    _showErrorDialog('Selecciona un género válido: Male o Female.');
    return;
  }
  if (_selectedBreed == null || _selectedBreed!.isEmpty || _selectedBreed == 'Seleccionar raza') {
    _showErrorDialog('Selecciona una raza válida.');
    return;
  }
  if (_selectedLocation == null || _selectedLocation!.isEmpty || _selectedLocation == 'Seleccionar ubicación') {
    _showErrorDialog('Selecciona una ubicación válida.');
    return;
  }

  setState(() => _isLoading = true);

  try {
    String bovineImgString = '';
    if (_localImage != null) {
      final bytes = await _localImage!.readAsBytes();
      bovineImgString = base64Encode(bytes);
    }

    final animal = AnimalDto(
      id: 0,
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      birthDate: _birthDate!.toIso8601String(),
      breed: _selectedBreed ?? '',
      location: _selectedLocation ?? '',
      bovineImg: bovineImgString, // Envía la imagen como base64
      stableId: _selectedStableId!,
    );

    await CreateAnimal(widget.repository).call(animal, _localImage!);
    Navigator.pop(context, true);
      } catch (e, stack) {
        // Solo imprime el error en consola
        debugPrint('Error al guardar animal: $e\n$stack');
        _showErrorDialog('Ocurrió un error al guardar el animal. Intenta nuevamente.');
      } finally {
        setState(() => _isLoading = false);
      }
  }


  void _showErrorDialog(String message) {
    const primary = Color(0xFF00695C);
    const warningColor = Color(0xFFFF9800);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Error',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: primary.withOpacity(0.1),
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Entendido',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores institucionales modernos
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    const accent = Color(0xFF4CAF50);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F9FA),
              lightGreen.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header moderno
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: lightGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        // Botón de retroceso
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primary.withOpacity(0.15),
                                primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Título con icono
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Registrar Nuevo Bovino',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Badge decorativo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withOpacity(0.8),
                                accent.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pets_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Nuevo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Contenido principal con scroll
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Sección de imagen con diseño moderno
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      lightGreen.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.08),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: lightGreen.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Header de la sección
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primary.withOpacity(0.15),
                                                accent.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Fotografía del Bovino',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: primary,
                                                ),
                                              ),
                                              Text(
                                                'Toca para seleccionar o tomar una foto',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Área de imagen mejorada
                                    GestureDetector(
                                      onTap: _showImageOptions,
                                      child: Container(
                                        height: 180,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          gradient: _localImage != null
                                              ? null
                                              : LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    lightGreen.withOpacity(0.3),
                                                    accent.withOpacity(0.1),
                                                  ],
                                                ),
                                          border: Border.all(
                                            color: _localImage != null 
                                                ? primary 
                                                : primary.withOpacity(0.3),
                                            width: _localImage != null ? 3 : 2,
                                          ),
                                          shape: BoxShape.circle,
                                          image: _localImage != null
                                              ? DecorationImage(
                                                  image: FileImage(_localImage!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primary.withOpacity(0.1),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: _localImage == null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo_rounded,
                                                    size: 50,
                                                    color: primary.withOpacity(0.6),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Agregar foto',
                                                    style: TextStyle(
                                                      color: primary.withOpacity(0.6),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : null,
                                      ),
                                    ),
                                    
                                    if (_localImage != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: accent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: accent.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: accent,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Imagen seleccionada',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Información básica del bovino
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      lightGreen.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.08),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: lightGreen.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header del formulario
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  primary.withOpacity(0.1),
                                                  primary.withOpacity(0.05),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.info_outline_rounded,
                                              color: primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Información del Bovino',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: primary,
                                                  ),
                                                ),
                                                Text(
                                                  'Completa los datos básicos',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // Campo Nombre (solo)
                                      _buildModernSection('Nombre', _nameController, 'Ej: Lola', Icons.pets_outlined),
                                      const SizedBox(height: 20),
                                      
                                      // Campo Fecha de Nacimiento (solo)
                                      _buildDateSection(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Sección de género y establo
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      lightGreen.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.08),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: lightGreen.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  accent.withOpacity(0.15),
                                                  accent.withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.settings_outlined,
                                              color: primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Clasificación',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: primary,
                                                  ),
                                                ),
                                                Text(
                                                  'Género y asignación de establo',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // Selector de género
                                      _buildModernSectionTitle('Género'),
                                      const SizedBox(height: 8),
                                      GenderCupertinoPicker(
                                        selectedGender: _selectedGender,
                                        onChanged: (val) => setState(() => _selectedGender = val),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Selector de raza
                                      _buildModernSectionTitle('Raza'),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: lightGreen.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: primary.withValues(alpha: 0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: BreedCupertinoPicker(
                                          selectedBreed: _selectedBreed,
                                          onChanged: (breed) {
                                            setState(() {
                                              _selectedBreed = breed;
                                            });
                                          },
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Selector de ubicación
                                      _buildModernSectionTitle('Ubicación'),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: lightGreen.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: primary.withValues(alpha: 0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: LocationCupertinoPicker(
                                          selectedLocation: _selectedLocation,
                                          onChanged: (location) {
                                            setState(() {
                                              _selectedLocation = location;
                                            });
                                          },
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Selector de establo
                                      _buildModernSectionTitle('Establo'),
                                      const SizedBox(height: 8),
                                      StableDropdown(
                                        selectedStableId: _selectedStableId,
                                        onChanged: (val) => setState(() => _selectedStableId = val),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Botón de guardar moderno
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 32),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveAnimal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 8,
                                    shadowColor: primary.withOpacity(0.3),
                                  ),
                                  child: _isLoading
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Guardando...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.save_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Registrar Bovino',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSection(String title, TextEditingController controller, String hint, IconData icon) {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionTitle(title),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionTitle('Fecha de Nacimiento'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: TextFormField(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Selecciona fecha',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: primary,
                      size: 18,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                controller: TextEditingController(
                  text: _birthDate != null 
                      ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                      : '',
                ),
                validator: (_) => _birthDate == null ? 'Campo requerido' : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSectionTitle(String title) {
    const primary = Color(0xFF00695C);
    
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primary,
        letterSpacing: 0.5,
      ),
    );
  }

}