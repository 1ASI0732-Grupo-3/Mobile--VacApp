import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_event.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_state.dart';
import 'package:vacapp/features/staff/data/models/staff_dto.dart';

class CreateStaffPage extends StatelessWidget {
  const CreateStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateStaffView();
  }
}

class CreateStaffView extends StatefulWidget {
  const CreateStaffView({super.key});

  @override
  State<CreateStaffView> createState() => _CreateStaffViewState();
}

class _CreateStaffViewState extends State<CreateStaffView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _campaignIdController = TextEditingController();
  
  String _selectedStatus = 'Disponible'; // Por defecto disponible

  static const Color primary = Color(0xFF00695C);
  static const Color lightGreen = Color(0xFFE8F5E8);

  @override
  void dispose() {
    _nameController.dispose();
    _campaignIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffOperationSuccess) {
          Navigator.of(context).pop(true); // Retorna true para indicar éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is StaffError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
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
          child: CustomScrollView(
            slivers: [
              // App Bar personalizada
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Agregar Personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primary.withOpacity(0.8)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_add,
                        size: 60,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido del formulario
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Tarjeta principal del formulario
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título de la sección
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Información del Personal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Campo de nombre
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre completo',
                                  hintText: 'Ingrese el nombre del empleado',
                                  prefixIcon: const Icon(Icons.person, color: primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: primary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: lightGreen.withOpacity(0.1),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El nombre es obligatorio';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'El nombre debe tener al menos 2 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Campo de ID de campaña
                              TextFormField(
                                controller: _campaignIdController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'ID de Campaña',
                                  hintText: 'Ingrese el ID de la campaña',
                                  prefixIcon: const Icon(Icons.campaign, color: primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: primary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: lightGreen.withOpacity(0.1),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El ID de campaña es obligatorio';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Debe ser un número válido';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Selector de estado
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: lightGreen.withOpacity(0.1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.work, color: primary, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Estado del Empleado',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedStatus,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        items: StaffDto.availableStatuses.map((String status) {
                                          return DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedStatus = newValue;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botones de acción
                    BlocBuilder<StaffBloc, StaffState>(
                      builder: (context, state) {
                        final isLoading = state is StaffCreating;
                        
                        return Column(
                          children: [
                            // Botón principal
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: primary.withOpacity(0.3),
                                ),
                                child: isLoading
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Creando...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Crear Personal',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Botón secundario
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primary,
                                  side: BorderSide(color: primary.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40), // Espacio adicional para el scroll
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final campaignId = int.parse(_campaignIdController.text.trim());
      final employeeStatusInt = StaffDto.employeeStatusFromString(_selectedStatus);
      
      context.read<StaffBloc>().add(
        CreateStaff(
          name: name,
          employeeStatus: employeeStatusInt,
          campaignId: campaignId,
        ),
      );
    }
  }
}
