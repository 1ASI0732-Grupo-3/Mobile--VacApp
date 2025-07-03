import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/staff/data/models/staff_dto.dart';
import 'package:vacapp/features/staff/data/repositories/staff_repository.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_event.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository _staffRepository;

  StaffBloc(this._staffRepository) : super(StaffInitial()) {
    on<LoadStaffs>(_onLoadStaffs);
    on<CreateStaff>(_onCreateStaff);
    on<UpdateStaff>(_onUpdateStaff);
    on<DeleteStaff>(_onDeleteStaff);
    on<LoadStaffById>(_onLoadStaffById);
    on<LoadStaffsByCampaign>(_onLoadStaffsByCampaign);
    on<LoadStaffsByEmployeeStatus>(_onLoadStaffsByEmployeeStatus);
    on<SearchStaffByName>(_onSearchStaffByName);
  }

  Future<void> _onLoadStaffs(LoadStaffs event, Emitter<StaffState> emit) async {
    try {
      emit(StaffLoading());
      final staffs = await _staffRepository.getAllStaffs();
      emit(StaffLoaded(staffs: staffs));
    } catch (e) {
      emit(StaffError(message: 'Error al cargar staffs: $e'));
    }
  }

  Future<void> _onCreateStaff(CreateStaff event, Emitter<StaffState> emit) async {
    try {
      emit(StaffCreating());
      
      final newStaff = StaffDto(
        id: 0, // El backend asignará el ID
        name: event.name,
        employeeStatus: event.employeeStatus,
        campaignId: event.campaignId,
      );

      await _staffRepository.createStaff(newStaff);
      emit(StaffOperationSuccess(message: 'Staff creado exitosamente'));
      
      // Recargar la lista
      add(LoadStaffs());
    } catch (e) {
      emit(StaffError(message: 'Error al crear staff: $e'));
    }
  }

  Future<void> _onUpdateStaff(UpdateStaff event, Emitter<StaffState> emit) async {
    try {
      emit(StaffUpdating());
      await _staffRepository.updateStaff(event.id, event.staff);
      emit(StaffOperationSuccess(message: 'Staff actualizado exitosamente'));
      
      // Recargar la lista
      add(LoadStaffs());
    } catch (e) {
      emit(StaffError(message: 'Error al actualizar staff: $e'));
    }
  }

  Future<void> _onDeleteStaff(DeleteStaff event, Emitter<StaffState> emit) async {
    try {
      emit(StaffDeleting());
      await _staffRepository.deleteStaff(event.id);
      emit(StaffOperationSuccess(message: 'Staff eliminado exitosamente'));
      
      // Recargar la lista
      add(LoadStaffs());
    } catch (e) {
      emit(StaffError(message: 'Error al eliminar staff: $e'));
    }
  }

  Future<void> _onLoadStaffById(LoadStaffById event, Emitter<StaffState> emit) async {
    try {
      emit(StaffLoading());
      final staff = await _staffRepository.getStaffById(event.id);
      emit(StaffDetailLoaded(staff: staff));
    } catch (e) {
      emit(StaffError(message: 'Error al cargar staff: $e'));
    }
  }

  Future<void> _onLoadStaffsByCampaign(LoadStaffsByCampaign event, Emitter<StaffState> emit) async {
    try {
      emit(StaffLoading());
      final staffs = await _staffRepository.getStaffByCampaignId(event.campaignId);
      emit(StaffLoaded(staffs: staffs));
    } catch (e) {
      emit(StaffError(message: 'Error al cargar staffs por campaña: $e'));
    }
  }

  Future<void> _onLoadStaffsByEmployeeStatus(LoadStaffsByEmployeeStatus event, Emitter<StaffState> emit) async {
    try {
      emit(StaffLoading());
      final staffs = await _staffRepository.getStaffByEmployeeStatus(event.employeeStatus);
      emit(StaffLoaded(staffs: staffs));
    } catch (e) {
      emit(StaffError(message: 'Error al cargar staffs por estado: $e'));
    }
  }

  Future<void> _onSearchStaffByName(SearchStaffByName event, Emitter<StaffState> emit) async {
    try {
      emit(StaffLoading());
      final staffs = await _staffRepository.getStaffByName(event.name);
      emit(StaffLoaded(staffs: staffs));
    } catch (e) {
      emit(StaffError(message: 'Error al buscar staff: $e'));
    }
  }
}
