import 'package:vacapp/features/staff/data/datasources/staff_service.dart';
import 'package:vacapp/features/staff/data/models/staff_dto.dart';

class StaffRepository {
  final StaffService _staffService;
  StaffRepository(this._staffService);

  Future<List<StaffDto>> getAllStaffs() async {
    try {
      final staffs = await _staffService.fetchStaffs();
      return staffs;
    } catch (e) {
      return [];
    }
    }
  
  Future<StaffDto> createStaff(StaffDto staff) async {
    final createdStaff = await _staffService.createStaff(staff);
    // Opcional: puedes volver a sincronizar la lista de staff si lo deseas
    await getAllStaffs();
    return createdStaff;
  }

  Future<void> updateStaff(int id, StaffDto staff) async {
    await _staffService.updateStaff(id, staff);
    await getAllStaffs();
  }

  Future<void> deleteStaff(int id) async {
    await _staffService.deleteStaff(id);
    await getAllStaffs();
  }

  Future<StaffDto> getStaffById(int id) async {
    return await _staffService.fetchStaffById(id);
  }

  Future<List<StaffDto>> getStaffByCampaignId(int campaignId) async {
    try {
      final staffs = await _staffService.fetchStaffByCampaignId(campaignId);
      return staffs;
    } catch (e) {
      return [];
    }
  }

  Future<List<StaffDto>> getStaffByEmployeeStatus(int employeeStatus) async {
    try {
      final staffs = await _staffService.fetchStaffByEmployeeStatus(employeeStatus);
      return staffs;
    } catch (e) {
      return [];
    }
  }

  Future<List<StaffDto>> getStaffByName(String name) async {
    try {
      final staff = await _staffService.fetchStaffByName(name);
      return staff;
    } catch (e) {
      throw Exception('Error fetching staff by name: $e');
    }
  }


}