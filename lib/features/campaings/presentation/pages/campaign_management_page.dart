import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/campaings/data/datasources/campaign_services.dart';
import 'package:vacapp/features/campaings/data/repositories/campaign_repository.dart';
import 'package:vacapp/features/campaings/presentation/bloc/campaign_bloc.dart';
import 'package:vacapp/features/campaings/presentation/bloc/campaign_event.dart';
import 'package:vacapp/features/campaings/presentation/bloc/campaign_state.dart';
import 'package:vacapp/features/campaings/presentation/pages/create_campaign_page.dart';
import 'package:vacapp/features/campaings/presentation/widgets/campaign_card.dart';
import 'package:vacapp/core/widgets/island_notification.dart';

class CampaignManagementPage extends StatefulWidget {
  const CampaignManagementPage({super.key});

  @override
  State<CampaignManagementPage> createState() => _CampaignManagementPageState();
}

class _CampaignManagementPageState extends State<CampaignManagementPage> {
  late final CampaignBloc _campaignBloc;

  @override
  void initState() {
    super.initState();
    _campaignBloc = CampaignBloc(CampaignRepository(CampaignServices()));
    _campaignBloc.add(LoadAllCampaigns());
  }

  @override
  void dispose() {
    _campaignBloc.close();
    super.dispose();
  }

  void _goToCreateCampaign() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _campaignBloc,
          child: const CreateCampaignPage(),
        ),
      ),
    );

    if (result == true) {
      _campaignBloc.add(RefreshCampaigns());
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightGreen = Color(0xFFE8F5E8);

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
          child: BlocProvider(
            create: (_) => _campaignBloc,
            child: BlocListener<CampaignBloc, CampaignState>(
              listener: (context, state) {
                if (state is CampaignCreated) {
                  IslandNotification.showSuccess(
                    context,
                    message: 'Campaña creada exitosamente',
                  );
                } else if (state is CampaignUpdated) {
                  IslandNotification.showSuccess(
                    context,
                    message: 'Estado actualizado exitosamente',
                  );
                } else if (state is CampaignDeleted) {
                  IslandNotification.showSuccess(
                    context,
                    message: state.message,
                  );
                } else if (state is CampaignError) {
                  print('❌ [DEBUG] Error en CampaignBloc: ${state.message}');
                  IslandNotification.showError(
                    context,
                    message: 'Error: ${state.message}',
                  );
                }
              },
              child: BlocBuilder<CampaignBloc, CampaignState>(
                builder: (context, state) {
                  if (state is CampaignLoading) {
                    return _buildLoadingState();
                  } else if (state is CampaignEmpty) {
                    return _buildEmptyState();
                  } else if (state is CampaignLoaded) {
                    return _buildLoadedState(state.campaigns);
                  } else if (state is CampaignError) {
                    return _buildErrorState(state.message);
                  }
                  
                  return _buildLoadingState();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando campañas...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    const primary = Color(0xFF00695C);
    const lightGreen = Color(0xFFE8F5E8);

    return Column(
      children: [
        // Header con botón de regresar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Gestión de Campañas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Contenido del estado vacío
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          lightGreen.withOpacity(0.3),
                          lightGreen.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.campaign_outlined,
                        size: 64,
                        color: primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'No hay campañas creadas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Comienza creando tu primera campaña\npara gestionar actividades',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 280),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _goToCreateCampaign,
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Crear mi primera campaña',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState(campaigns) {
    const primary = Color(0xFF00695C);
    
    return RefreshIndicator(
      onRefresh: () async {
        _campaignBloc.add(RefreshCampaigns());
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: campaigns.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Header con botón de regresar y título
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Gestión de Campañas',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón para crear nueva campaña
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _goToCreateCampaign,
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Crear Nueva Campaña',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final campaign = campaigns[index - 1];
          return CampaignCard(
            campaign: campaign,
            onDelete: (campaign) {
              _showDeleteDialog(campaign);
            },
            onStatusChange: (campaign, status) {
              _campaignBloc.add(UpdateCampaignStatus(campaign.id, status));
              // Refresh counts after status change
              _campaignBloc.add(LoadCampaignGoalsCount(campaign.id));
              _campaignBloc.add(LoadCampaignChannelsCount(campaign.id));
            },
            onAddGoal: (campaign, goalData) {
              // El diálogo moderno ya está integrado en CampaignCard
              // Los datos del goal se procesan directamente en el BLoC
              _campaignBloc.add(AddGoalToCampaign(campaign.id, goalData));
            },
            onAddChannel: (campaign, channelData) {
              // La lógica del diálogo ya está integrada en CampaignCard
              // Los datos del channel se procesan directamente en el BLoC
              _campaignBloc.add(AddChannelToCampaign(campaign.id, channelData));
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    const primary = Color(0xFF00695C);
    
    return Column(
      children: [
        // Header con botón de regresar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Gestión de Campañas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Contenido del estado de error
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _campaignBloc.add(RefreshCampaigns());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(campaign) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con ícono de advertencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              const Text(
                'Eliminar Campaña',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Mensaje de confirmación
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: '¿Estás seguro de que deseas eliminar la campaña '),
                    TextSpan(
                      text: '"${campaign.name}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Información adicional
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta acción no se puede deshacer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 28),
                        Expanded(
                          child: Text(
                            'Se eliminarán todos los objetivos y canales asociados',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _campaignBloc.add(DeleteCampaign(campaign.id));
                      },
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

    
}
