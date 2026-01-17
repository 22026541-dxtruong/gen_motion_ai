import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  int _selectedMode = 0; // 0: Text-to-Image, 1: Image-to-Image, 2: Image-to-Video
  final _promptController = TextEditingController();
  final _negativePromptController = TextEditingController();
  
  String _selectedModel = 'KLING 1.5';
  String _aspectRatio = '16:9';
  double _creativityLevel = 0.5;
  int _numberOfImages = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel - Settings
        Expanded(
          flex: 2,
          child: _buildSettingsPanel(),
        ),
        
        // Right panel - Preview/Canvas
        Expanded(
          flex: 3,
          child: _buildPreviewPanel(),
        ),
      ],
    );
  }

  Widget _buildSettingsPanel() {
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
            
            // Prompt input
            const Text(
              'Prompt',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe what you want to create...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Negative prompt
            ExpansionTile(
              title: const Text(
                'Negative Prompt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              tilePadding: EdgeInsets.zero,
              children: [
                TextField(
                  controller: _negativePromptController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'What to avoid...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Model selection
            const Text(
              'Model',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedModel,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            
            const SizedBox(height: 24),
            
            // Aspect ratio
            const Text(
              'Aspect Ratio',
              style: TextStyle(
                fontSize: 14,
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
                  label: Text(ratio),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _aspectRatio = ratio);
                  },
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surfaceColor,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Creativity level
            const Text(
              'Creativity Level',
              style: TextStyle(
                fontSize: 14,
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
              children: const [
                Text('Conservative', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text('Creative', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Number of images
            const Text(
              'Number of Images',
              style: TextStyle(
                fontSize: 14,
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
                        backgroundColor: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        ),
                      ),
                      child: Text('$count'),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Generate button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 20),
                  SizedBox(width: 8),
                  Text('Generate'),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.bolt, size: 14, color: AppTheme.accentGreen),
                  SizedBox(width: 4),
                  Text(
                    '10 credits per generation',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
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

  Widget _buildPreviewPanel() {
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

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }
}
