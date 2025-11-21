import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/language_provider.dart';

/// Profile tab - User profile and settings
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.logout();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfile = ref.watch(userProfileProvider);

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Profile content
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Profile header card with user info
              userProfile.when(
                data: (user) => _buildProfileHeader(context, user),
                loading: () => _buildProfileHeaderSkeleton(context),
                error: (error, stackTrace) => _buildProfileHeaderError(context),
              ),

              const SizedBox(height: 32),

              // Profile sections
              _buildSection(
                context,
                title: 'Account',
                items: [
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),
                  _buildLanguageTile(context, ref),
                ],
              ),

              const SizedBox(height: 24),

              _buildSection(
                context,
                title: 'Preferences',
                items: [
                  _buildListTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // TODO: Toggle dark mode
                      },
                    ),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.text_fields,
                    title: 'Font Size',
                    subtitle: 'Medium',
                    onTap: () {
                      // TODO: Show font size picker
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSection(
                context,
                title: 'About',
                items: [
                  _buildListTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {
                      // TODO: Show terms of service
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => _handleLogout(context, ref),
                    icon: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(
                      authState.isLoading ? 'Logging out...' : 'Logout',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red, width: 2),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  /// Build profile header with all user information
  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile picture
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: user.profileImageUrl != null
                    ? CircleAvatar(
                        radius: 56,
                        backgroundImage: CachedNetworkImageProvider(
                          user.profileImageUrl,
                        ),
                      )
                    : CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Full name
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Username
              Text(
                '@${user.username}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),

              // User info details
              Column(
                children: [
                  _buildProfileInfoRow(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileInfoRow(
                    context,
                    icon: Icons.verified_user_outlined,
                    label: 'Provider',
                    value: user.provider,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileInfoRow(
                    context,
                    icon: user.isActive
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    label: 'Status',
                    value: user.isActive ? 'Active' : 'Inactive',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a row showing profile info
  Widget _buildProfileInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build profile header skeleton (loading state)
  Widget _buildProfileHeaderSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build profile header error state
  Widget _buildProfileHeaderError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.person,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to load profile',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Build language selection tile with current language display
  Widget _buildLanguageTile(BuildContext context, WidgetRef ref) {
    final selectedLanguageState = ref.watch(selectedLanguageNotifierProvider);
    final languagesAsync = ref.watch(availableLanguagesProvider);

    // Get the display name of currently selected language
    final languageDisplayName = languagesAsync.when(
      data: (languages) {
        final selected = languages.where((l) => l.code == selectedLanguageState.code).firstOrNull;
        return selected?.name ?? selectedLanguageState.code.toUpperCase();
      },
      loading: () => selectedLanguageState.code.toUpperCase(),
      error: (_, __) => selectedLanguageState.code.toUpperCase(),
    );

    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primary),
      title: const Text('Language'),
      subtitle: Text(languageDisplayName),
      trailing: selectedLanguageState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: selectedLanguageState.isLoading
          ? null
          : () => _showLanguageBottomSheet(context, ref),
    );
  }

  /// Show language selection bottom sheet
  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LanguageBottomSheet(),
    );
  }
}

/// Bottom sheet widget for language selection
class _LanguageBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagesAsync = ref.watch(availableLanguagesProvider);
    final selectedLanguageState = ref.watch(selectedLanguageNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.language, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred language for content',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const Divider(height: 24),

          // Language list
          languagesAsync.when(
            data: (languages) => Column(
              children: languages.map((language) {
                final isSelected = language.code == selectedLanguageState.code;
                return ListTile(
                  leading: Text(
                    language.direction == 'RTL' ? '🌐' : '🌍',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    language.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(language.nativeName),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await ref
                        .read(selectedLanguageNotifierProvider.notifier)
                        .setLanguage(language.code);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to ${language.name}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Failed to load languages'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(availableLanguagesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
