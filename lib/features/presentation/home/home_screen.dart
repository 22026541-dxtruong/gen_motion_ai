import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: context.isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create amazing AI-powered content',
            style: TextStyle(
              fontSize: context.isMobile ? 14 : 16,
              color: AppTheme.textSecondary,
            ),
          ),
          
          SizedBox(height: context.isMobile ? 24 : 32),
          
          // Quick actions - Responsive grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = context.isMobile ? 1 : (context.isTablet ? 2 : 3);
              final childAspectRatio = context.isMobile ? 1.8 : 1.5;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                children: const [
                  _QuickActionCard(
                    title: 'Text to Image',
                    subtitle: 'Generate from prompt',
                    icon: Icons.image_outlined,
                    gradient: [AppTheme.primaryColor, AppTheme.accentPurple],
                  ),
                  _QuickActionCard(
                    title: 'Image to Image',
                    subtitle: 'Transform images',
                    icon: Icons.transform_outlined,
                    gradient: [AppTheme.accentPurple, AppTheme.accentPink],
                  ),
                  _QuickActionCard(
                    title: 'Image to Video',
                    subtitle: 'Animate your images',
                    icon: Icons.videocam_outlined,
                    gradient: [AppTheme.accentPink, AppTheme.primaryColor],
                  ),
                ],
              );
            },
          ),
          
          SizedBox(height: context.isMobile ? 32 : 40),
          
          // Recent generations header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Generations',
                style: TextStyle(
                  fontSize: context.isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View all'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent generations grid - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = context.isMobile 
                ? 2 
                : (context.isTablet ? 3 : 4);
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: context.isMobile ? 12 : 16,
                  crossAxisSpacing: context.isMobile ? 12 : 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return const _GenerationCard();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(context.isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(context.isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon, 
                  color: Colors.white, 
                  size: context.isMobile ? 20 : 24,
                ),
              ),
              SizedBox(height: context.isMobile ? 12 : 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: context.isMobile ? 12 : 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenerationCard extends StatelessWidget {
  const _GenerationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: context.isMobile ? 36 : 48,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.isMobile ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A beautiful landscape...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.isMobile ? 6 : 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.isMobile ? 6 : 8,
                        vertical: context.isMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Image',
                        style: TextStyle(
                          fontSize: context.isMobile ? 10 : 11,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.more_vert,
                      size: context.isMobile ? 14 : 16,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
