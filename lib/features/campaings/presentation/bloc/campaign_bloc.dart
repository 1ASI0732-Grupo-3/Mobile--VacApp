import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/campaings/data/repositories/campaign_repository.dart';
import 'package:vacapp/features/campaings/presentation/bloc/campaign_event.dart';
import 'package:vacapp/features/campaings/presentation/bloc/campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CampaignRepository _repository;

  CampaignBloc(this._repository) : super(CampaignInitial()) {
    on<LoadAllCampaigns>(_onLoadAllCampaigns);
    on<LoadCampaignById>(_onLoadCampaignById);
    on<LoadCampaignsByStable>(_onLoadCampaignsByStable);
    on<CreateCampaign>(_onCreateCampaign);
    on<UpdateCampaignStatus>(_onUpdateCampaignStatus);
    on<DeleteCampaign>(_onDeleteCampaign);
    on<AddGoalToCampaign>(_onAddGoalToCampaign);
    on<AddChannelToCampaign>(_onAddChannelToCampaign);
    on<LoadCampaignGoals>(_onLoadCampaignGoals);
    on<LoadCampaignChannels>(_onLoadCampaignChannels);
    on<LoadAllCampaignsWithDetails>(_onLoadAllCampaignsWithDetails);
    on<RefreshCampaigns>(_onRefreshCampaigns);
    on<ResetCampaignState>(_onResetCampaignState);
  }

  Future<void> _onLoadAllCampaigns(
    LoadAllCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaigns = await _repository.getAllCampaigns();
      if (campaigns.isEmpty) {
        emit(const CampaignEmpty('No hay campañas registradas'));
      } else {
        emit(CampaignLoaded(campaigns));
      }
    } catch (e) {
      emit(CampaignError('Error al cargar campañas: $e'));
    }
  }

  Future<void> _onLoadCampaignById(
    LoadCampaignById event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaign = await _repository.getCampaignById(event.id);
      emit(CampaignSingleLoaded(campaign));
    } catch (e) {
      emit(CampaignError('Error al cargar campaña: $e'));
    }
  }

  Future<void> _onLoadCampaignsByStable(
    LoadCampaignsByStable event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaigns = await _repository.getCampaignsByStableId(event.stableId);
      if (campaigns.isEmpty) {
        emit(const CampaignEmpty('No hay campañas para este establo'));
      } else {
        emit(CampaignLoaded(campaigns));
      }
    } catch (e) {
      emit(CampaignError('Error al cargar campañas del establo: $e'));
    }
  }

  Future<void> _onCreateCampaign(
    CreateCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaign = await _repository.createCampaign(event.campaignData);
      emit(CampaignCreated(campaign));
      
      // Recargar todas las campañas después de crear
      add(LoadAllCampaigns());
    } catch (e) {
      emit(CampaignError('Error al crear campaña: $e'));
    }
  }

  Future<void> _onUpdateCampaignStatus(
    UpdateCampaignStatus event,
    Emitter<CampaignState> emit,
  ) async {
    print('🔍 [DEBUG] BLoC: Iniciando actualización de estado para campaña ID: ${event.id} a estado: ${event.status}');
    emit(CampaignLoading());
    try {
      final campaign = await _repository.updateCampaignStatus(event.id, event.status);
      print('✅ [DEBUG] BLoC: Estado actualizado exitosamente. Emitiendo CampaignUpdated');
      emit(CampaignUpdated(campaign));
      
      // Recargar todas las campañas después de actualizar
      print('🔍 [DEBUG] BLoC: Recargando todas las campañas después de actualizar estado');
      add(LoadAllCampaigns());
    } catch (e) {
      print('❌ [DEBUG] BLoC error en updateCampaignStatus: $e');
      emit(CampaignError('Error al actualizar estado: $e'));
    }
  }

  Future<void> _onDeleteCampaign(
    DeleteCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _repository.deleteCampaign(event.id);
      emit(const CampaignDeleted('Campaña eliminada exitosamente'));
      
      // Recargar todas las campañas después de eliminar
      add(LoadAllCampaigns());
    } catch (e) {
      emit(CampaignError('Error al eliminar campaña: $e'));
    }
  }

  Future<void> _onAddGoalToCampaign(
    AddGoalToCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    print('🔍 [DEBUG] BLoC: Iniciando agregar goal para campaña ID: ${event.campaignId}');
    print('🔍 [DEBUG] BLoC: Goal data: ${event.goalData}');
    emit(CampaignLoading());
    try {
      final campaign = await _repository.addGoalToCampaign(event.campaignId, event.goalData);
      print('✅ [DEBUG] BLoC: Goal agregado exitosamente. Emitiendo CampaignUpdated');
      emit(CampaignUpdated(campaign));
      
      // Recargar todas las campañas después de agregar goal
      print('🔍 [DEBUG] BLoC: Recargando todas las campañas después de agregar goal');
      add(LoadAllCampaigns());
    } catch (e) {
      print('❌ [DEBUG] BLoC error en addGoalToCampaign: $e');
      emit(CampaignError('Error al agregar objetivo: $e'));
    }
  }

  Future<void> _onAddChannelToCampaign(
    AddChannelToCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    print('🔍 [DEBUG] BLoC: Iniciando agregar channel para campaña ID: ${event.campaignId}');
    print('🔍 [DEBUG] BLoC: Channel data: ${event.channelData}');
    emit(CampaignLoading());
    try {
      final campaign = await _repository.addChannelToCampaign(event.campaignId, event.channelData);
      print('✅ [DEBUG] BLoC: Channel agregado exitosamente. Emitiendo CampaignUpdated');
      emit(CampaignUpdated(campaign));
      
      // Recargar todas las campañas después de agregar channel
      print('🔍 [DEBUG] BLoC: Recargando todas las campañas después de agregar channel');
      add(LoadAllCampaigns());
    } catch (e) {
      print('❌ [DEBUG] BLoC error en addChannelToCampaign: $e');
      emit(CampaignError('Error al agregar canal: $e'));
    }
  }

  Future<void> _onLoadCampaignGoals(
    LoadCampaignGoals event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final goals = await _repository.getCampaignGoals(event.campaignId);
      emit(CampaignGoalsLoaded(goals));
    } catch (e) {
      emit(CampaignError('Error al cargar objetivos: $e'));
    }
  }

  Future<void> _onLoadCampaignChannels(
    LoadCampaignChannels event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final channels = await _repository.getCampaignChannels(event.campaignId);
      emit(CampaignChannelsLoaded(channels));
    } catch (e) {
      emit(CampaignError('Error al cargar canales: $e'));
    }
  }

  Future<void> _onLoadAllCampaignsWithDetails(
    LoadAllCampaignsWithDetails event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      // Cargar todas las campañas
      final campaigns = await _repository.getAllCampaigns();
      
      if (campaigns.isEmpty) {
        emit(const CampaignEmpty('No hay campañas registradas'));
        return;
      }

      // Cargar goals y channels para cada campaña
      Map<int, List<Map<String, dynamic>>> campaignGoals = {};
      Map<int, List<Map<String, dynamic>>> campaignChannels = {};

      for (final campaign in campaigns) {
        try {
          // Cargar goals
          final goals = await _repository.getCampaignGoals(campaign.id);
          campaignGoals[campaign.id] = goals;
        } catch (e) {
          print('⚠️ Error cargando goals para campaña ${campaign.id}: $e');
          campaignGoals[campaign.id] = [];
        }

        try {
          // Cargar channels
          final channels = await _repository.getCampaignChannels(campaign.id);
          campaignChannels[campaign.id] = channels;
        } catch (e) {
          print('⚠️ Error cargando channels para campaña ${campaign.id}: $e');
          campaignChannels[campaign.id] = [];
        }
      }

      emit(CampaignWithDetailsLoaded(
        campaigns: campaigns,
        campaignGoals: campaignGoals,
        campaignChannels: campaignChannels,
      ));
    } catch (e) {
      emit(CampaignError('Error al cargar campañas con detalles: $e'));
    }
  }
    }
  }

  Future<void> _onRefreshCampaigns(
    RefreshCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    add(LoadAllCampaigns());
  }

  Future<void> _onResetCampaignState(
    ResetCampaignState event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignInitial());
  }
}
