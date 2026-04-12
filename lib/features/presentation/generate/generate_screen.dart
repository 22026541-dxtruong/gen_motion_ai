import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/theme/app_theme.dart';
import 'package:gen_motion_ai/core/utils/responsive.dart';
import 'package:gen_motion_ai/features/presentation/jobs/jobs_provider.dart';
import 'package:go_router/go_router.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  int _selectedMode = 0;
  final _promptController = TextEditingController();
  final _negativePromptController = TextEditingController();

  String _selectedModel = 'KLING 1.5';
  String _aspectRatio = '16:9';
  double _creativityLevel = 0.5;
  bool _isLoading = false;
  bool _showNegativePrompt = false;

  final _modes = [
    {'label': 'Text to Image', 'icon': Icons.text_fields, 'short': 'Text'},
    {'label': 'Image to Image', 'icon': Icons.transform, 'short': 'Image'},
    {'label': 'Image to Video', 'icon': Icons.videocam, 'short': 'Video'},
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }

  Future<void> _submitGenerateRequest() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Please enter a prompt'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobsNotifier = ref.read(jobsProvider.notifier);

      final job = await jobsNotifier.createVideoJob(
        inputAssetId: 'default',
        prompt: _promptController.text,
        negativePrompt: _negativePromptController.text.isEmpty
            ? null
            : _negativePromptController.text,
        modelName: _selectedModel,
        aspectRatio: _aspectRatio,
        turboEnabled: false,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _promptController.clear();
        _negativePromptController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Job created: ${job.effectiveId.substring(0, 8)}...')),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'View Queue',
              textColor: Colors.white,
              onPressed: () => context.go('/queue'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bring your imagination to life',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                _buildModeSelector(isMobile: true),
                const SizedBox(height: 20),
                _buildPromptSection(isMobile: true),
                const SizedBox(height: 16),
                _buildSettingsSection(isMobile: true),
                const SizedBox(height: 24),
                _buildGenerateButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left panel - Settings
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppTheme.borderColor)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bring your imagination to life',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildModeSelector(isMobile: false),
                  const SizedBox(height: 24),
                  _buildPromptSection(isMobile: false),
                  const SizedBox(height: 24),
                  _buildSettingsSection(isMobile: false),
                  const SizedBox(height: 32),
                  _buildGenerateButton(),
                ],
              ),
            ),
          ),
        ),
        // Right panel - Preview
        Expanded(flex: 3, child: _buildDesktopPreviewPanel()),
      ],
    );
  }

  Widget _buildDesktopPreviewPanel() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Text('Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surfaceColor,
                    AppTheme.cardColor,
                  ],
                ),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 36,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your creation will appear here',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in a prompt and click Generate',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SHARED COMPONENTS ====================
  Widget _buildModeSelector({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_modes.length, (i) {
            final isSelected = _selectedMode == i;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _modes.length - 1 ? 8 : 0),
                child: InkWell(
                  onTap: () => setState(() => _selectedMode = i),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.15)
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _modes[i]['icon'] as IconData,
                          size: 20,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMobile
                              ? _modes[i]['short'] as String
                              : _modes[i]['label'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPromptSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Prompt',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _promptController,
          maxLines: isMobile ? 3 : 4,
          style: TextStyle(fontSize: isMobile ? 13 : 14),
          decoration: InputDecoration(
            hintText: 'Describe what you want to create...',
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _showNegativePrompt = !_showNegativePrompt),
          child: Row(
            children: [
              Icon(
                _showNegativePrompt ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Negative Prompt',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_showNegativePrompt) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _negativePromptController,
            maxLines: 2,
            style: TextStyle(fontSize: isMobile ? 13 : 14),
            decoration: InputDecoration(
              hintText: 'What to avoid...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Model
        _sectionLabel('Model', isMobile),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedModel,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
          ),
          items: ['KLING 1.5', 'KLING 1.0', 'KLING Pro']
              .map((model) => DropdownMenuItem(
                    value: model,
                    child: Text(model),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedModel = value!),
        ),

        SizedBox(height: isMobile ? 16 : 24),

        // Aspect ratio
        _sectionLabel('Aspect Ratio', isMobile),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1:1', '16:9', '9:16', '4:3', '3:4'].map((ratio) {
            final isSelected = _aspectRatio == ratio;
            return ChoiceChip(
              label: Text(ratio, style: TextStyle(fontSize: isMobile ? 12 : 13)),
              selected: isSelected,
              onSelected: (selected) => setState(() => _aspectRatio = ratio),
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            );
          }).toList(),
        ),

        SizedBox(height: isMobile ? 16 : 24),

        // Creativity level
        _sectionLabel('Creativity Level', isMobile),
        const SizedBox(height: 4),
        Slider(
          value: _creativityLevel,
          onChanged: (value) => setState(() => _creativityLevel = value),
          min: 0,
          max: 1,
          divisions: 10,
          activeColor: AppTheme.primaryColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Conservative',
                style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppTheme.textSecondary)),
            Text('Creative',
                style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, bool isMobile) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isMobile ? 13 : 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: context.isMobile ? 48 : 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitGenerateRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Generating...', style: TextStyle(fontSize: 15)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20),
                      SizedBox(width: 8),
                      Text('Generate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Est. time: ~2-5 minutes • Cost: 10 credits',
          style: TextStyle(
            fontSize: context.isMobile ? 11 : 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
