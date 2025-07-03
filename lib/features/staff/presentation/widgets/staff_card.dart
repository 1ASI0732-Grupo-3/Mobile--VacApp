import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/staff/data/models/staff_dto.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_event.dart';
import 'package:vacapp/features/staff/presentation/pages/update_staff_page.dart';
import 'package:vacapp/features/staff/presentation/pages/delete_staff_page.dart';

class StaffCard extends StatelessWidget {
  final StaffDto staff;

  const StaffCard({
    super.key,
    required this.staff,
  });

  // Colores consistentes con la app
  static const Color primary = Color(0xFF00695C);
  static const Color lightGreen = Color(0xFFE8F5E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: lightGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showStaffDetails(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con avatar y nombre
                Row(
                  children: [
                    // Avatar con iniciales
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, primary.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(staff.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name.isNotEmpty ? staff.name : 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(staff.employeeStatus),
                                size: 16,
                                color: _getStatusColor(staff.employeeStatus),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(staff.employeeStatus),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(staff.employeeStatus),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Menú de acciones
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade600,
                      ),
                      onSelected: (value) => _handleMenuAction(context, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: primary),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Información adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // ID del staff
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.badge,
                              size: 16,
                              color: primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ID: ${staff.id}',
                              style: TextStyle(
                                fontSize: 12,
                                color: primary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ID de campaña
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.campaign,
                              size: 16,
                              color: primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Campaña: ${staff.campaignId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: primary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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

  void _showStaffDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Personal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${staff.name}'),
            Text('ID: ${staff.id}'),
            Text('Estado: ${_getStatusText(staff.employeeStatus)}'),
            Text('Campaña: ${staff.campaignId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<StaffBloc>(),
              child: UpdateStaffPage(staff: staff),
            ),
          ),
        );
        
        // Recargar la lista si se editó el empleado exitosamente
        if (result == true) {
          context.read<StaffBloc>().add(LoadStaffs());
        }
        break;
      case 'delete':
        final result = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => BlocProvider.value(
            value: context.read<StaffBloc>(),
            child: DeleteStaffDialog(staff: staff),
          ),
        );
        
        // Recargar la lista si se eliminó el empleado exitosamente
        if (result == true) {
          context.read<StaffBloc>().add(LoadStaffs());
        }
        break;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0: // Disponible
        return Icons.check_circle;
      case 1: // En Campaña
        return Icons.work;
      case 2: // Vacaciones
        return Icons.beach_access;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: // Disponible
        return Colors.green;
      case 1: // En Campaña
        return Colors.blue;
      case 2: // Vacaciones
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    // Crear un StaffDto temporal para usar el método helper
    final tempStaff = StaffDto(
      id: 0,
      name: '',
      employeeStatus: status,
      campaignId: 0,
    );
    return tempStaff.employeeStatusString;
  }
}
