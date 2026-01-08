import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeEditorScreen extends StatefulWidget {
  const CodeEditorScreen({super.key});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedLanguage = 'Python';

  @override
  void initState() {
    super.initState();
    _blockPasteShortcuts();
  }

  void _blockPasteShortcuts() {
    HardwareKeyboard.instance.addHandler((event) {
      if (event is KeyDownEvent) {
        final isCtrlV = event.logicalKey == LogicalKeyboardKey.keyV &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed);

        if (isCtrlV) {
          return true; // BLOCK paste
        }
      }
      return false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArivuCode Editor'),
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          Expanded(child: _buildEditor()),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedLanguage,
        items: const [
          DropdownMenuItem(value: 'Python', child: Text('Python')),
          DropdownMenuItem(value: 'C', child: Text('C')),
          DropdownMenuItem(value: 'C++', child: Text('C++')),
          DropdownMenuItem(value: 'Java', child: Text('Java')),
          DropdownMenuItem(value: 'JavaScript', child: Text('JavaScript')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Language',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        contextMenuBuilder: (context, editableTextState) {
          // REMOVE paste menu completely
          return const SizedBox.shrink();
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText:
          'Write your code here...\n\nPaste is disabled to encourage original coding.',
        ),
      ),
    );
  }
}
