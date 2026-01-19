import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/code_templates.dart';
import '../../widgets/enhanced_code_editor.dart';
import '../../widgets/custom_button.dart';

class CodeEditorScreen extends StatefulWidget {
  final String? challengeId;
  final String? initialCode;
  final String? initialLanguage;

  const CodeEditorScreen({
    super.key,
    this.challengeId,
    this.initialCode,
    this.initialLanguage,
  });

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late String _selectedLanguage;
  late String _code;
  double _fontSize = AppConstants.codeFontSizeDefault;
  bool _showLineNumbers = true;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage ?? 'Python';
    _code = widget.initialCode ?? CodeTemplates.getEmptyTemplate(_selectedLanguage);
    _blockPasteShortcuts();
  }

  void _blockPasteShortcuts() {
    HardwareKeyboard.instance.addHandler((event) {
      if (event is KeyDownEvent) {
        final isCtrlV = event.logicalKey == LogicalKeyboardKey.keyV &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed);

        if (isCtrlV) {
          _showPasteBlockedMessage();
          return true; // BLOCK paste
        }
      }
      return false;
    });
  }

  void _showPasteBlockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.block, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Paste is disabled to encourage original coding'),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onLanguageChanged(String? newLanguage) {
    if (newLanguage == null) return;

    // Show confirmation dialog if code exists
    if (_code.trim().isNotEmpty && _code != CodeTemplates.getEmptyTemplate(_selectedLanguage)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Language?'),
          content: const Text(
            'Changing the language will reset your code. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedLanguage = newLanguage;
                  _code = CodeTemplates.getEmptyTemplate(newLanguage);
                });
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _selectedLanguage = newLanguage;
        _code = CodeTemplates.getEmptyTemplate(newLanguage);
      });
    }
  }

  void _loadTemplate() {
    setState(() {
      _code = CodeTemplates.getTemplate(_selectedLanguage);
    });
  }

  void _clearCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Code?'),
        content: const Text('This will delete all your code. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _code = CodeTemplates.getEmptyTemplate(_selectedLanguage);
              });
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _runCode() {
    // TODO: Implement code execution
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code execution coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _submitCode() {
    // TODO: Implement code submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code submission coming soon!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: [
            Text(CodeTemplates.getIcon(_selectedLanguage)),
            const SizedBox(width: 8),
            const Text('Code Editor'),
          ],
        ),
        actions: [
          // Font size controls
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _fontSize > AppConstants.codeFontSizeMin
                ? () {
                    setState(() {
                      _fontSize -= AppConstants.codeFontSizeStep;
                    });
                  }
                : null,
            tooltip: 'Decrease font size',
          ),
          Text(
            '${_fontSize.toInt()}',
            style: const TextStyle(fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _fontSize < AppConstants.codeFontSizeMax
                ? () {
                    setState(() {
                      _fontSize += AppConstants.codeFontSizeStep;
                    });
                  }
                : null,
            tooltip: 'Increase font size',
          ),
          
          // Line numbers toggle
          IconButton(
            icon: Icon(_showLineNumbers ? Icons.format_list_numbered : Icons.format_list_numbered_outlined),
            onPressed: () {
              setState(() {
                _showLineNumbers = !_showLineNumbers;
              });
            },
            tooltip: 'Toggle line numbers',
          ),
          
          // More options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'template':
                  _loadTemplate();
                  break;
                case 'clear':
                  _clearCode();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 20),
                    SizedBox(width: 12),
                    Text('Load Template'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Clear Code', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector and info bar
          _buildToolbar(),
          
          // Code editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: EnhancedCodeEditor(
                language: _selectedLanguage,
                initialCode: _code,
                onCodeChanged: (newCode) {
                  _code = newCode;
                },
                showLineNumbers: _showLineNumbers,
                fontSize: _fontSize,
              ),
            ),
          ),
          
          // Action buttons
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Language selector
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: AppConstants.supportedLanguages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Row(
                        children: [
                          Text(CodeTemplates.getIcon(language)),
                          const SizedBox(width: 8),
                          Text(language),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onLanguageChanged,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Code stats
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStatChip(
                  Icons.code,
                  '${_code.split('\n').length} lines',
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.text_fields,
                  '${_code.length} chars',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Run Code',
              icon: Icons.play_arrow,
              onPressed: _runCode,
              variant: ButtonVariant.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Submit',
              icon: Icons.check,
              onPressed: _submitCode,
              variant: ButtonVariant.gradient,
            ),
          ),
        ],
      ),
    );
  }
}
