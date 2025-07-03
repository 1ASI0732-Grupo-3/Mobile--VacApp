import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_event.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_state.dart';
import 'package:vacapp/features/campaings/data/datasources/campaign_services.dart';
import 'package:vacapp/features/campaings/data/repositories/campaign_repository.dart';
import 'package:vacapp/features/campaings/data/models/campaings_dto.dart';
import 'package:vacapp/features/stables/data/datasources/stables_service.dart';
import 'package:vacapp/features/stables/data/repositories/stable_repository.dart';

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
  
  // Para las campañas
  late CampaignRepository _campaignRepository;
  List<CampaingsDto> _campaigns = [];
  CampaingsDto? _selectedCampaign;
  bool _isLoadingCampaigns = true;
  
  // Para los establos
  late StableRepository _stableRepository;
  Map<int, String> _stableNames = {}; // Mapa para almacenar nombres de establos por ID
  
  late BuildContext _mainContext;

  // Paleta de colores más moderna y menos verde
  static const Color primary = Color(0xFF2C3E50);
  static const Color accent = Color(0xFF3498DB);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _campaignRepository = CampaignRepository(CampaignServices());
    _stableRepository = StableRepository(StablesService());
    _loadCampaigns();
    _loadStables();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainContext = context;
  }

  Future<void> _loadCampaigns() async {
    try {
      final campaigns = await _campaignRepository.getAllCampaigns();
      if (mounted) {
        setState(() {
          _campaigns = campaigns;
          _isLoadingCampaigns = false;
          // Seleccionar la primera campaña por defecto (ya no "Sin trabajo")
          if (_campaigns.isNotEmpty) {
            _selectedCampaign = _campaigns.first;
          }
        });
      }
    } catch (e) {
      print('❌ Error loading campaigns: $e');
      if (mounted) {
        setState(() {
          _isLoadingCampaigns = false;
        });
      }
    }
  }

  Future<void> _loadStables() async {
    try {
      final stables = await _stableRepository.getStables();
      
      if (mounted) {
        setState(() {
          // Crear mapa de ID -> nombre para acceso rápido
          _stableNames = {
            for (var stable in stables) stable.id: stable.name
          };
        });
      }
    } catch (e) {
      print('❌ Error loading stables: $e');
      if (mounted) {
        setState(() {
          _stableNames = {};
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffOperationSuccess) {
          Navigator.of(context).pop(true);
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
        backgroundColor: lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Header moderno
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: primary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuevo Empleado',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          Text(
                            'Agregar personal al equipo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido del formulario
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                                    color: accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: accent,
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
                                prefixIcon: const Icon(Icons.person, color: accent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: accent, width: 2),
                                ),
                                filled: true,
                                fillColor: lightBackground,
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

                            // Sección de campaña mejorada
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título con icono
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.campaign,
                                        color: accent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Campaña Asignada',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Selecciona la campaña donde trabajará el empleado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_isLoadingCampaigns)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                      color: lightBackground,
                                    ),
                                    child: const Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Cargando campañas...'),
                                      ],
                                    ),
                                  )
                                else if (_campaigns.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.red.shade50,
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.red),
                                        SizedBox(width: 12),
                                        Text('No hay campañas disponibles'),
                                      ],
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      // Dropdown compacto
                                      Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 50,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(12),
                                          color: lightBackground,
                                        ),
                                        child: DropdownButtonFormField<CampaingsDto>(
                                          value: _selectedCampaign,
                                          isExpanded: true,
                                          menuMaxHeight: 200,
                                          isDense: true,
                                          hint: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            child: const Text(
                                              'Selecciona una campaña',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          selectedItemBuilder: (BuildContext context) {
                                            return _campaigns.map((campaign) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                child: Text(
                                                  'Campaña Seleccionada',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: primary,
                                                  ),
                                                ),
                                              );
                                            }).toList();
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: accent.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.campaign,
                                                color: accent,
                                                size: 20,
                                              ),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          dropdownColor: cardBackground,
                                          icon: Container(
                                            margin: const EdgeInsets.only(right: 12),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: accent,
                                              size: 24,
                                            ),
                                          ),
                                          items: _campaigns.map((campaign) {
                                            return DropdownMenuItem<CampaingsDto>(
                                              value: campaign,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                constraints: const BoxConstraints(
                                                  maxHeight: 50,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: accent.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Icon(
                                                        Icons.campaign,
                                                        color: accent,
                                                        size: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            campaign.name,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 13,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          if (campaign.description.isNotEmpty)
                                                            Text(
                                                              campaign.description,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(campaign.status),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (CampaingsDto? newValue) {
                                            setState(() {
                                              _selectedCampaign = newValue;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Debe seleccionar una campaña';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      
                                      // Tarjeta expandida de información de la campaña seleccionada
                                      if (_selectedCampaign != null) ...[
                                        const SizedBox(height: 12),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(0.05),
                                            border: Border.all(color: accent.withOpacity(0.2)),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Header de la campaña seleccionada
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: accent.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.campaign,
                                                      color: accent,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Campaña Seleccionada',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey.shade600,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          _selectedCampaign!.name,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: primary,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Estado de la campaña
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(_selectedCampaign!.status).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      _selectedCampaign!.status,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: _getStatusColor(_selectedCampaign!.status),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              // Descripción expandida
                                              if (_selectedCampaign!.description.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.grey.shade200),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.description,
                                                            size: 16,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            'Descripción',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey.shade600,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        _selectedCampaign!.description,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: primary,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              
                                              // Información adicional
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: Colors.grey.shade200),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.calendar_today,
                                                            size: 14,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            'Código: ${_selectedCampaign!.id}',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.grey.shade700,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: Colors.grey.shade200),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.business,
                                                            size: 14,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            'Establo: ${_stableNames[_selectedCampaign!.stableId] ?? 'Desconocido'}',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.grey.shade700,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Información del estado (solo informativo)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(color: Colors.blue.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.work,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Estado: En Campaña',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Por defecto',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
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
                                          backgroundColor: accent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 8,
                                          shadowColor: accent.withOpacity(0.3),
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
                                          side: BorderSide(color: primary.withOpacity(0.3)),
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
                          ],
                        ),
                      ),
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

  // Método para obtener el color según el estado de la campaña
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
      case 'active':
        return Colors.green;
      case 'inactiva':
      case 'inactive':
        return Colors.red;
      case 'pendiente':
      case 'pending':
        return Colors.orange;
      case 'completada':
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      
      // Validar que siempre haya una campaña seleccionada
      if (_selectedCampaign == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe seleccionar una campaña'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final campaignId = _selectedCampaign!.id;
      // Estado siempre es 2 ("En Campaña") para nuevo personal asignado a campañas
      final employeeStatusInt = 2;

      print('🔄 Enviando staff:');
      print('  - name: $name');
      print('  - employeeStatus: $employeeStatusInt (En Campaña)');
      print('  - campaignId: $campaignId (${_selectedCampaign!.name})');

      _mainContext.read<StaffBloc>().add(
        CreateStaff(
          name: name,
          employeeStatus: employeeStatusInt,
          campaignId: campaignId,
        ),
      );
    }
  }
}
