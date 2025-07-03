import 'package:vacapp/features/staff/data/models/staff_dto.dart';

abstract class StaffEvent {
  const StaffEvent();
}

class LoadStaffs extends StaffEvent {}

class CreateStaff extends StaffEvent {
  final String name;
  final int employeeStatus;
  final int campaignId;

  const CreateStaff({
    required this.name,
    required this.employeeStatus,
    required this.campaignId,
  });
}

class UpdateStaff extends StaffEvent {
  final int id;
  final StaffDto staff;

  const UpdateStaff({
    required this.id,
    required this.staff,
  });
}

class DeleteStaff extends StaffEvent {
  final int id;

  const DeleteStaff({required this.id});
}

class LoadStaffById extends StaffEvent {
  final int id;

  const LoadStaffById({required this.id});
}

class LoadStaffsByCampaign extends StaffEvent {
  final int campaignId;

  const LoadStaffsByCampaign({required this.campaignId});
}

class LoadStaffsByEmployeeStatus extends StaffEvent {
  final int employeeStatus;

  const LoadStaffsByEmployeeStatus({required this.employeeStatus});
}

class SearchStaffByName extends StaffEvent {
  final String name;

  const SearchStaffByName({required this.name});
}
