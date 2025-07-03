import 'package:vacapp/features/staff/data/models/staff_dto.dart';

abstract class StaffState {
  const StaffState();
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<StaffDto> staffs;

  const StaffLoaded({required this.staffs});
}

class StaffDetailLoaded extends StaffState {
  final StaffDto staff;

  const StaffDetailLoaded({required this.staff});
}

class StaffOperationSuccess extends StaffState {
  final String message;

  const StaffOperationSuccess({required this.message});
}

class StaffError extends StaffState {
  final String message;

  const StaffError({required this.message});
}

class StaffCreating extends StaffState {}

class StaffUpdating extends StaffState {}

class StaffDeleting extends StaffState {}
