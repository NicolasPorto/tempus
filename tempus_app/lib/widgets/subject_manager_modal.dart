import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class SubjectManagerModal extends StatefulWidget {
  const SubjectManagerModal({super.key});

  @override
  State<SubjectManagerModal> createState() => _SubjectManagerModalState();
}

class _SubjectManagerModalState extends State<SubjectManagerModal> {
  final TextEditingController _nameController = TextEditingController();
  late SupabaseService _supabaseService;

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
  bool _isLoadingSubjects = true;
  bool _isSaving = false;
  List<Category> _existingSubjects = [];

  @override
  void initState() {
    super.initState();
    _selectedColorValue = _availableColors.first;
    _nameController.addListener(_updateButtonState);
    _supabaseService = Provider.of<SupabaseService>(context, listen: false);
    _loadSubjects();
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final isEnabled = _nameController.text.trim().isNotEmpty &&
        _selectedColorValue != null;
    if (_isButtonEnabled != isEnabled) {
      setState(() => _isButtonEnabled = isEnabled);
    }
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoadingSubjects = true);
    try {
      final categories = await _supabaseService.listCategories();
      if (mounted) setState(() => _existingSubjects = categories);
    } catch (e) {
      debugPrint('Error loading subjects: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSubjects = false);
    }
  }

  Future<void> _saveSubject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedColorValue == null) return;

    setState(() => _isSaving = true);
    final hex =
        '#${(_selectedColorValue! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    try {
      await _supabaseService.createCategory(name, hex);
      _nameController.clear();
      setState(() {
        _selectedColorValue = _availableColors.first;
        _isSaving = false;
      });
      await _loadSubjects();
    } catch (e) {
      debugPrint('Error saving subject: $e');
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSubject(String id) async {
    setState(() => _existingSubjects.removeWhere((c) => c.id == id));
    try {
      await _supabaseService.deleteCategory(id);
    } catch (e) {
      debugPrint('Error deleting subject: $e');
      await _loadSubjects();
    }
  }

  Widget _buildColorButton(int colorValue) {
    final isSelected = _selectedColorValue == colorValue;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedColorValue = colorValue);
        _updateButtonState();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Color(colorValue),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: Colors.transparent, width: 2.5),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Color(colorValue).withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
              )
            : null,
      ),
    );
  }

  Widget _buildExistingSubjectsList() {
    if (_isLoadingSubjects) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TempusColors.accent,
            ),
          ),
        ),
      );
    }

    if (_existingSubjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Nenhuma matéria criada ainda',
            style: TextStyle(
              color: TempusColors.textSub,
              fontSize: 13,
              fontFamily: 'Arimo',
            ),
          ),
        ),
      );
    }

    return Column(
      children: _existingSubjects.map((cat) {
        final color = Category.convertToColorValue(cat.hexColor);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TempusColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TempusColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cat.name,
                  style: const TextStyle(
                    color: TempusColors.text,
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(cat),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: TempusColors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _confirmDelete(Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TempusColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TempusColors.border),
        ),
        title: const Text(
          'Remover matéria?',
          style: TextStyle(
            color: TempusColors.text,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${cat.name}" será removida permanentemente.',
          style: const TextStyle(
            color: TempusColors.textSub,
            fontFamily: 'Arimo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: TempusColors.textSub),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSubject(cat.id);
            },
            child: const Text(
              'Remover',
              style: TextStyle(
                color: TempusColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth > 400 ? 380.0 : screenWidth * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: modalWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: TempusColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TempusColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x50000000),
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gerenciar Matérias',
                    style: TextStyle(
                      color: TempusColors.text,
                      fontSize: 18,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: TempusColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TempusColors.border),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: TempusColors.textSub,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // New subject section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TempusColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TempusColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nova Matéria',
                      style: TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 11,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: TempusColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TempusColors.border),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: TempusColors.text,
                          fontSize: 14,
                          fontFamily: 'Arimo',
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          hintText: 'Ex: Matemática...',
                          hintStyle: TextStyle(
                            color: TempusColors.textMuted,
                            fontSize: 14,
                            fontFamily: 'Arimo',
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Cor',
                      style: TextStyle(
                        color: TempusColors.textSub,
                        fontSize: 11,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableColors.map(_buildColorButton).toList(),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: (_isButtonEnabled && !_isSaving) ? _saveSubject : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: (_isButtonEnabled && !_isSaving) ? 1.0 : 0.35,
                        child: Container(
                          width: double.infinity,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: TempusColors.gradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Adicionar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Matérias',
                style: TextStyle(
                  color: TempusColors.textSub,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              _buildExistingSubjectsList(),
            ],
          ),
        ),
      ),
    );
  }
}
