import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/code_templates.dart';
import '../../core/models/execution_result_model.dart';
import '../../core/models/submission_model.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/enhanced_code_editor.dart';
import '../../widgets/custom_button.dart';
import '../../services/sentinel_service.dart';

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

class _CodeEditorScreenState extends State<CodeEditorScreen> with WidgetsBindingObserver {
  late String _selectedLanguage;
  late String _code;
  double _fontSize = AppConstants.codeFontSizeDefault;
  bool _showLineNumbers = true;
  bool _isTerminalExpanded = false;
  late SentinelService _sentinel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedLanguage = widget.initialLanguage ?? 'Python';
    _code = widget.initialCode ?? CodeTemplates.getEmptyTemplate(_selectedLanguage);
    _sentinel = SentinelService();
    _sentinel.startMonitoring();
    _blockPasteShortcuts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sentinel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _sentinel.reportActivity(SentinelActivityType.windowSwitch);
      _showSentinelWarning('Sentinel detected you left the app. Integrity score decreased.');
    }
  }

  void _showSentinelWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _blockPasteShortcuts() {
    HardwareKeyboard.instance.addHandler((event) {
      if (event is KeyDownEvent) {
        final isCtrlV = event.logicalKey == LogicalKeyboardKey.keyV &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed);

        if (isCtrlV) {
          _sentinel.reportActivity(SentinelActivityType.pasteAttempt);
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

  Future<void> _runCode() async {
    final provider = context.read<ChallengeProvider>();
    final challenge = provider.currentChallenge;
    
    if (challenge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No challenge active')),
      );
      return;
    }

    try {
      final result = await provider.executeCode(
        code: _code,
        language: _selectedLanguage,
        testCases: challenge.testCases,
      );

      if (mounted) {
        _showExecutionResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Execution failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitCode() async {
    final provider = context.read<ChallengeProvider>();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    final challenge = provider.currentChallenge;

    if (user == null || challenge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit')),
      );
      return;
    }

    try {
      // Calculate mock time taken (in reality would track actual time)
      final timeTaken = 300; // 5 minutes mock

      final submission = await provider.submitCode(
        userId: user.id,
        challengeId: challenge.id,
        code: _code,
        language: _selectedLanguage,
        timeTaken: timeTaken,
      );

      if (submission != null && mounted) {
        if (submission.isPassed) {
          // Calculate points and update user
          final points = await userProvider.completeChallenge(
            basePoints: challenge.points,
            timeLimit: challenge.timeLimit,
            timeTaken: timeTaken,
            language: _selectedLanguage,
            isFirstSolve: challenge.solvedCount == 0,
          );
          
          _showSubmissionResult(submission, pointsEarned: points);
        } else {
          _showSubmissionResult(submission);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showExecutionResult(ExecutionResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundMedium,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    result.isSuccess ? Icons.check_circle : Icons.error,
                    color: result.isSuccess ? AppColors.success : AppColors.error,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    result.statusMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: result.testResults.length,
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) {
                  final test = result.testResults[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: test.passed ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              test.passed ? Icons.check : Icons.close,
                              color: test.passed ? AppColors.success : AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Test Case ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${test.executionTimeMs}ms',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        if (!test.passed) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Input: ${test.input}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Expected: ${test.expectedOutput}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Actual: ${test.actualOutput}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmissionResult(Submission submission, {int pointsEarned = 0}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMedium,
        title: Row(
          children: [
            Icon(
              submission.isPassed ? Icons.emoji_events : Icons.info,
              color: submission.isPassed ? AppColors.warning : AppColors.error,
            ),
            const SizedBox(width: 12),
            Text(submission.isPassed ? 'Accepted!' : 'Not Accepted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              submission.isPassed
                  ? 'Congratulations! You solved the challenge.'
                  : 'Keep trying! You passed ${submission.passedTests}/${submission.totalTests} tests.',
            ),
            if (submission.isPassed && pointsEarned > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      '+$pointsEarned Points',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildStatRow('Status', submission.status.toUpperCase()),
            _buildStatRow('Time', '${submission.executionTime}ms'),
            _buildStatRow('Language', submission.language),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (submission.isPassed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengeProvider>();

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ListenableBuilder(
            listenable: _sentinel,
            builder: (context, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _sentinel.status == SentinelStatus.secure 
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _sentinel.status == SentinelStatus.secure ? Icons.shield : Icons.warning,
                    size: 16,
                    color: _sentinel.status == SentinelStatus.secure ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sentinel: ${_sentinel.status.name.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _sentinel.status == SentinelStatus.secure ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Integrity: ${(_sentinel.integrityScore * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _fontSize > AppConstants.codeFontSizeMin
                ? () => setState(() => _fontSize -= AppConstants.codeFontSizeStep)
                : null,
          ),
          Text('${_fontSize.toInt()}'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _fontSize < AppConstants.codeFontSizeMax
                ? () => setState(() => _fontSize += AppConstants.codeFontSizeStep)
                : null,
          ),
          IconButton(
            icon: Icon(_showLineNumbers ? Icons.format_list_numbered : Icons.format_list_numbered_outlined),
            onPressed: () => setState(() => _showLineNumbers = !_showLineNumbers),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'template') _loadTemplate();
              if (value == 'clear') _clearCode();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [Icon(Icons.code, size: 20), SizedBox(width: 12), Text('Load Template')],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [Icon(Icons.delete_outline, size: 20, color: AppColors.error), SizedBox(width: 12), Text('Clear Code')],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          if (provider.isExecuting)
             const LinearProgressIndicator(color: AppColors.primary),
             
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: EnhancedCodeEditor(
                language: _selectedLanguage,
                initialCode: _code,
                onCodeChanged: (newCode) => _code = newCode,
                showLineNumbers: _showLineNumbers,
                fontSize: _fontSize,
              ),
            ),
          ),
          _buildActionBar(provider.isExecuting),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
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
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStatChip(Icons.code, '${_code.split('\n').length} lines'),
                const SizedBox(width: 8),
                _buildStatChip(Icons.text_fields, '${_code.length} chars'),
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
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isExecuting) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Run Code',
              icon: Icons.play_arrow,
              onPressed: isExecuting ? null : _runCode,
              variant: ButtonVariant.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Submit',
              icon: Icons.check,
              onPressed: isExecuting ? null : _submitCode,
              variant: ButtonVariant.gradient,
            ),
          ),
        ],
      ),
    );
  }
}
