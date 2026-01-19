import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Enhanced code editor widget with syntax highlighting and line numbers
class EnhancedCodeEditor extends StatefulWidget {
  final String language;
  final String initialCode;
  final ValueChanged<String>? onCodeChanged;
  final bool showLineNumbers;
  final double fontSize;

  const EnhancedCodeEditor({
    super.key,
    required this.language,
    this.initialCode = '',
    this.onCodeChanged,
    this.showLineNumbers = true,
    this.fontSize = AppConstants.codeFontSizeDefault,
  });

  @override
  State<EnhancedCodeEditor> createState() => _EnhancedCodeEditorState();
}

class _EnhancedCodeEditorState extends State<EnhancedCodeEditor> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late ScrollController _lineNumberScrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _scrollController = ScrollController();
    _lineNumberScrollController = ScrollController();

    // Sync scroll controllers
    _scrollController.addListener(_syncScroll);
    
    _controller.addListener(() {
      widget.onCodeChanged?.call(_controller.text);
      setState(() {}); // Rebuild to update line numbers
    });
  }

  void _syncScroll() {
    if (_lineNumberScrollController.hasClients) {
      _lineNumberScrollController.jumpTo(_scrollController.offset);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }

  int get _lineCount {
    if (_controller.text.isEmpty) return 1;
    return '\n'.allMatches(_controller.text).length + 1;
  }

  String get _languageMode {
    return switch (widget.language.toLowerCase()) {
      'python' => 'python',
      'c' => 'c',
      'c++' => 'cpp',
      'java' => 'java',
      'javascript' => 'javascript',
      _ => 'plaintext',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLineNumbers) _buildLineNumbers(),
            Expanded(child: _buildCodeEditor()),
          ],
        ),
      ),
    );
  }

  Widget _buildLineNumbers() {
    return Container(
      width: 50,
      color: AppColors.surface,
      child: SingleChildScrollView(
        controller: _lineNumberScrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              _lineCount,
              (index) => SizedBox(
                height: widget.fontSize * 1.5,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: widget.fontSize,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeEditor() {
    return Stack(
      children: [
        // Syntax highlighted code (read-only overlay)
        if (_controller.text.isNotEmpty)
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: HighlightView(
                  _controller.text,
                  language: _languageMode,
                  theme: _buildCustomTheme(),
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: widget.fontSize,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        
        // Transparent text field for input
        TextField(
          controller: _controller,
          scrollController: _scrollController,
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.fontSize,
            color: Colors.transparent, // Make text transparent
            height: 1.5,
          ),
          cursorColor: AppColors.primary,
          cursorWidth: 2,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            hintText: 'Write your code here...',
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
            ),
          ),
          contextMenuBuilder: (context, editableTextState) {
            // Block paste from context menu
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Map<String, TextStyle> _buildCustomTheme() {
    // Custom theme matching app colors
    return {
      'root': TextStyle(
        backgroundColor: Colors.transparent,
        color: AppColors.textPrimary,
      ),
      'keyword': const TextStyle(color: AppColors.syntaxKeyword),
      'built_in': const TextStyle(color: AppColors.syntaxFunction),
      'type': const TextStyle(color: AppColors.syntaxClass),
      'literal': const TextStyle(color: AppColors.syntaxNumber),
      'number': const TextStyle(color: AppColors.syntaxNumber),
      'string': const TextStyle(color: AppColors.syntaxString),
      'comment': const TextStyle(color: AppColors.syntaxComment),
      'function': const TextStyle(color: AppColors.syntaxFunction),
      'class': const TextStyle(color: AppColors.syntaxClass),
      'variable': const TextStyle(color: AppColors.syntaxVariable),
      'operator': const TextStyle(color: AppColors.syntaxOperator),
    };
  }
}
