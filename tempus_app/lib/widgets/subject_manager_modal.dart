import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

class SubjectManagerModal extends StatefulWidget {
  const SubjectManagerModal({super.key});

  @override
  State<SubjectManagerModal> createState() => _SubjectManagerModalState();
}

class _SubjectManagerModalState extends State<SubjectManagerModal> {
  final TextEditingController _nameController = TextEditingController();
  late ApiService _apiService;

  final List<int> _availableColors = const [
    0xFFEF4444,
    0xFFF59E0B,
    0xFF10B981,
    0xFF3B82F6,
    0xFF8B5CF6,
    0xFFEC4899,
    0xFF14B8A6,
    0xFFF97316,
  ];

  int? _selectedColorValue;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedColorValue = _availableColors.first;
    _nameController.addListener(_updateButtonState);
    _updateButtonState();
    _apiService = Provider.of<ApiService>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final newText = _nameController.text.trim();
    final isEnabled = newText.isNotEmpty && _selectedColorValue != null;
    if (_isButtonEnabled != isEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  void _saveSubject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedColorValue == null) return;

    await _apiService.createCategory(name, _selectedColorValue!.toRadixString(16));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildColorButton(int colorValue) {
    final isSelected = _selectedColorValue == colorValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorValue = colorValue;
        });
        _updateButtonState();
      },
      child: Container(
        width: 71,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        decoration: ShapeDecoration(
          color: Color(colorValue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected
                ? const BorderSide(color: Colors.white, width: 3.0)
                : BorderSide.none,
          ),
          shadows: [
            BoxShadow(
              color: Color(colorValue).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check, color: Colors.white, size: 20),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 400 ? 393.0 : screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: modalWidth,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.00, 0.00),
            end: Alignment(1.00, 1.00),
            colors: [Color(0xF2171717), Color(0xF20A0A0A)],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gerenciar Matérias',
                    style: TextStyle(
                      color: Color(0xFFF4F4F4),
                      fontSize: 18,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Opacity(
                      opacity: 0.70,
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFD4D4D4),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 17,
                ),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0x19FFFEFE)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nova Matéria',
                      style: TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0x7F0A0A0A),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0x19FFFEFE),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Color(0xFFF4F4F4),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          hintText: 'Ex: Matemática...',
                          hintStyle: TextStyle(
                            color: Color(0xFF717182),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Cor',
                      style: TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableColors
                          .map(_buildColorButton)
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isButtonEnabled ? _saveSubject : null,
                      child: Opacity(
                        opacity: _isButtonEnabled ? 1.0 : 0.50,
                        child: Container(
                          width: double.infinity,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.00, 0.50),
                              end: Alignment(1.00, 0.50),
                              colors: [Color(0xFFAC46FF), Color(0xFF2B7FFF)],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Adicionar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
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
      ),
    );
  }
}
