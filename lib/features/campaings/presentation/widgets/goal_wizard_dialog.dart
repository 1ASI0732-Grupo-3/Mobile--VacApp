import 'package:flutter/material.dart';
import 'package:vacapp/features/campaings/data/models/campaings_dto.dart';

class GoalWizardDialog extends StatefulWidget {
  final CampaingsDto campaign;
  final Function(Map<String, dynamic>) onGoalAdded;

  const GoalWizardDialog({
    super.key,
    required this.campaign,
    required this.onGoalAdded,
  });

  @override
  State<GoalWizardDialog> createState() => _GoalWizardDialogState();
}

class _GoalWizardDialogState extends State<GoalWizardDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Controladores para cada paso
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _metricController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _currentValueController = TextEditingController(text: '0');

  // Lista de pasos
  final List<String> _stepTitles = [
    'Descripción del Objetivo',
    'Métrica a Medir',
    'Valor Objetivo',
    'Valor Actual (Opcional)',
  ];

  final List<String> _stepSubtitles = [
    'Describe qué quieres lograr',
    'Define cómo vas a medir el progreso',
    'Establece la meta que quieres alcanzar',
    'Indica el progreso inicial (por defecto 0)',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _metricController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return _descriptionController.text.trim().isNotEmpty;
      case 1:
        return _metricController.text.trim().isNotEmpty;
      case 2:
        return _targetValueController.text.trim().isNotEmpty &&
               double.tryParse(_targetValueController.text.trim()) != null;
      case 3:
        return true; // Opcional, siempre válido
      default:
        return false;
    }
  }

  void _finishWizard() {
    if (!_isCurrentStepValid()) {
      return;
    }

    final goalData = {
      'description': _descriptionController.text.trim(),
      'metric': _metricController.text.trim(),
      'targetValue': double.parse(_targetValueController.text.trim()),
      'currentValue': double.tryParse(_currentValueController.text.trim()) ?? 0.0,
    };

    widget.onGoalAdded(goalData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
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
            // Header con progreso
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00695C).withOpacity(0.1),
                    const Color(0xFF00695C).withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Indicador de progreso
                  Row(
                    children: List.generate(_stepTitles.length, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index < _stepTitles.length - 1 ? 8 : 0,
                          ),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? const Color(0xFF00695C)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Título del paso actual
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00695C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flag_outlined,
                          size: 24,
                          color: Color(0xFF00695C),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paso ${_currentStep + 1} de ${_stepTitles.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _stepTitles[_currentStep],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _stepSubtitles[_currentStep],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Contenido del paso actual
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  height: 200,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDescriptionStep(),
                      _buildMetricStep(),
                      _buildTargetValueStep(),
                      _buildCurrentValueStep(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Botones de navegación
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Anterior'),
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
                  
                  if (_currentStep > 0) const SizedBox(width: 12),
                  
                  if (_currentStep == 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
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
                  
                  if (_currentStep == 0) const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCurrentStepValid()
                          ? (_currentStep == _stepTitles.length - 1
                              ? _finishWizard
                              : _nextStep)
                          : null,
                      icon: Icon(
                        _currentStep == _stepTitles.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(
                        _currentStep == _stepTitles.length - 1
                            ? 'Crear Objetivo'
                            : 'Siguiente',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildDescriptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campaña: ${widget.campaign.name}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción del objetivo',
            hintText: 'Ej: Vacunar 100 animales contra fiebre aftosa',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Describe claramente qué quieres lograr con esta campaña. Sé específico.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _metricController,
          decoration: const InputDecoration(
            labelText: 'Métrica',
            hintText: 'Ej: animales, litros, hectáreas, dosis, porcentaje',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.straighten),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Define la unidad de medida: animales, dosis, hectáreas, etc.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetValueStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _targetValueController,
          decoration: const InputDecoration(
            labelText: 'Valor objetivo',
            hintText: 'Ej: 100',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Meta que quieres alcanzar. Debe ser un número.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentValueStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _currentValueController,
          decoration: const InputDecoration(
            labelText: 'Valor actual (progreso inicial)',
            hintText: 'Por defecto 0',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.purple.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Progreso actual hacia el objetivo. Puedes dejarlo en 0 si estás empezando.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
