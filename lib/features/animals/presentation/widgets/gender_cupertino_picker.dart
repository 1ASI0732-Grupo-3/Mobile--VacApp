import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vacapp/core/themes/color_palette.dart';

class GenderCupertinoPicker extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  static const List<String> genders = ['Seleccionar género', 'Macho', 'Hembra'];

  const GenderCupertinoPicker({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  void _showPicker(BuildContext context) {
    final initialIndex = selectedGender != null
        ? genders.indexOf(selectedGender!)
        : 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header moderno con gradiente
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorPalette.primaryColor,
                    ColorPalette.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wc_rounded, 
                      color: Colors.white, 
                      size: 20
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          'Género del animal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de géneros
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: initialIndex),
                itemExtent: 55,
                onSelectedItemChanged: (index) {
                  onChanged(index == 0 ? null : genders[index]);
                },
                children: genders.map((gender) {
                  final index = genders.indexOf(gender);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: index == 0 
                          ? Colors.grey.shade50 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == 0 
                            ? Colors.grey.shade300 
                            : ColorPalette.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: index == 0 ? [] : [
                        BoxShadow(
                          color: ColorPalette.primaryColor.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icono del género
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: index == 0 
                                ? Colors.grey.shade200 
                                : ColorPalette.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            index == 0 
                                ? Icons.help_outline_rounded 
                                : index == 1 
                                  ? Icons.male 
                                  : Icons.female,
                            color: index == 0 
                                ? Colors.grey.shade500 
                                : ColorPalette.primaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Texto del género
                        Expanded(
                          child: Text(
                            gender,
                            style: TextStyle(
                              fontSize: 14,
                              color: index == 0 
                                  ? Colors.grey.shade600 
                                  : Colors.black87,
                              fontWeight: index == 0 
                                  ? FontWeight.w400 
                                  : FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Footer con botón de cerrar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade200,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Cerrar',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedGender ?? genders[0];

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedGender != null && selectedGender != genders[0] 
                ? ColorPalette.primaryColor.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorPalette.primaryColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Icono del género
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selectedGender != null && selectedGender != genders[0]
                            ? [
                                ColorPalette.primaryColor.withValues(alpha: 0.2),
                                ColorPalette.primaryColor.withValues(alpha: 0.1),
                              ]
                            : [Colors.grey.shade200, Colors.grey.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      selectedGender == 'Macho'
                          ? Icons.male
                          : selectedGender == 'Hembra'
                              ? Icons.female
                              : Icons.help_outline_rounded,
                      color: selectedGender != null && selectedGender != genders[0] 
                          ? ColorPalette.primaryColor
                          : Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Información del género
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: displayText == genders[0] 
                                ? Colors.grey.shade600 
                                : Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (selectedGender != null && selectedGender != genders[0])
                          Text(
                            'Animal ${selectedGender?.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Flecha indicadora
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
