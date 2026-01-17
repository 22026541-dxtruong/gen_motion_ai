import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  int _selectedMode = 0;
  final _promptController = TextEditingController();
  final _negativePromptController = TextEditingController();
  
  String _selectedModel = 'KLING 1.5';
  String _aspectRatio = '16:9';
  double _creativityLevel = 0.5;
  int _numberOfImages = 1;

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
        // Mode selector at top on mobile
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Text', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.text_fields, size: 18),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Image', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.transform, size: 18),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('Video', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.videocam, size: 18),
                  ),
                ],
                selected: {_selectedMode},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() => _selectedMode = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryColor;
                    }
                    return AppTheme.surfaceColor;
                  }),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Prompt
                _buildPromptSection(isMobile: true),
                const SizedBox(height: 16),
                
                // Preview on mobile
                _buildMobilePreview(),
                const SizedBox(height: 16),
                
                // Settings
                _buildSettingsSection(isMobile: true),
                const SizedBox(height: 24),
                
                // Generate button
                _buildGenerateButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePreview() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'Preview',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left panel - Settings
        Expanded(
          flex: 2,
          child: _buildDesktopSettingsPanel(),
        ),
        
        // Right panel - Preview
        Expanded(
          flex: 3,
          child: _buildDesktopPreviewPanel(),
        ),
      ],
    );
  }

  Widget _buildDesktopSettingsPanel() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode selector
            const Text(
              'Generation Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Text to Image'),
                  icon: Icon(Icons.text_fields),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Image to Image'),
                  icon: Icon(Icons.transform),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Image to Video'),
                  icon: Icon(Icons.videocam),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => _selectedMode = newSelection.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.primaryColor;
                  }
                  return AppTheme.surfaceColor;
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildPromptSection(isMobile: false),
            const SizedBox(height: 24),
            _buildSettingsSection(isMobile: false),
            const SizedBox(height: 32),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopPreviewPanel() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Preview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppTheme.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your generated image will appear here',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
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
        
        const SizedBox(height: 12),
        
        ExpansionTile(
          title: Text(
            'Negative Prompt',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          tilePadding: EdgeInsets.zero,
          children: [
            TextField(
              controller: _negativePromptController,
              maxLines: 3,
              style: TextStyle(fontSize: isMobile ? 13 : 14),
              decoration: InputDecoration(
                hintText: 'What to avoid...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Model
        Text(
          'Model',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          onChanged: (value) {
            setState(() => _selectedModel = value!);
          },
        ),
        
        SizedBox(height: isMobile ? 16 : 24),
        
        // Aspect ratio
        Text(
          'Aspect Ratio',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1:1', '16:9', '9:16', '4:3', '3:4'].map((ratio) {
            final isSelected = _aspectRatio == ratio;
            return ChoiceChip(
              label: Text(
                ratio,
                style: TextStyle(fontSize: isMobile ? 12 : 13),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _aspectRatio = ratio);
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
            );
          }).toList(),
        ),
        
        SizedBox(height: isMobile ? 16 : 24),
        
        // Creativity level
        Text(
          'Creativity Level',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _creativityLevel,
          onChanged: (value) {
            setState(() => _creativityLevel = value);
          },
          min: 0,
          max: 1,
          divisions: 10,
          label: (_creativityLevel * 10).round().toString(),
          activeColor: AppTheme.primaryColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Conservative',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'Creative',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        
        SizedBox(height: isMobile ? 16 : 24),
        
        // Number of images
        Text(
          'Number of Images',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 4].map((count) {
            final isSelected = _numberOfImages == count;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _numberOfImages = count);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.surfaceColor,
                    side: BorderSide(
                      color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 10 : 12,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(fontSize: isMobile ? 13 : 14),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: context.isMobile ? 14 : 16,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              Text(
                'Generate',
                style: TextStyle(fontSize: context.isMobile ? 14 : 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 14, color: AppTheme.accentGreen),
            const SizedBox(width: 4),
            Text(
              '10 credits per generation',
              style: TextStyle(
                fontSize: context.isMobile ? 11 : 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }
}
