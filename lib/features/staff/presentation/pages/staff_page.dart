import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_event.dart';
import 'package:vacapp/features/staff/presentation/bloc/staff_state.dart';
import 'package:vacapp/features/staff/presentation/widgets/staff_card.dart';
import 'package:vacapp/features/staff/presentation/pages/create_staff_page.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffView();
  }
}

class StaffView extends StatelessWidget {
  const StaffView({super.key});

  // Colores consistentes con la app
  static const Color primary = Color(0xFF00695C);
  static const Color lightGreen = Color(0xFFE8F5E8);

  @override
  Widget build(BuildContext context) {
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
        child: CustomScrollView(
          slivers: [
            // App Bar personalizada
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: primary,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Gestión de Personal',
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
                      Icons.people,
                      size: 60,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
              actions: [
                BlocBuilder<StaffBloc, StaffState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        context.read<StaffBloc>().add(LoadStaffs());
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Contenido principal
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: BlocConsumer<StaffBloc, StaffState>(
                listener: (context, state) {
                  if (state is StaffError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  if (state is StaffOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StaffLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                    );
                  }

                  if (state is StaffLoaded) {
                    if (state.staffs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
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
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay personal registrado',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Agrega el primer miembro del personal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StaffCard(staff: state.staffs[index]),
                          );
                        },
                        childCount: state.staffs.length,
                      ),
                    );
                  }

                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Estado desconocido'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<StaffBloc>(),
                child: const CreateStaffPage(),
              ),
            ),
          );
          
          // Recargar la lista si se creó un empleado exitosamente
          if (result == true) {
            context.read<StaffBloc>().add(LoadStaffs());
          }
        },
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
