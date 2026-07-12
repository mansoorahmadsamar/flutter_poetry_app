import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/standard_app_bar.dart';
import '../../auth/widgets/guest_locked_tab.dart';
import 'creator/models/claim_status.dart';
import 'creator/providers/creator_providers.dart';
import 'creator/screens/creator_dashboard_screen.dart';
import 'creator/widgets/become_poet_card.dart';
import 'creator/widgets/claim_status_banner.dart';
// kPoetModeEnabled lives in become_poet_card.dart and gates the entire
// poet-mode surface (claim flow + dashboard) for the v1.0 release.
import 'profile/providers/app_content_providers.dart';
import 'profile/screens/app_content_detail_screen.dart';

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

    // Guest users get a friendly locked screen with a sign-in CTA instead
    // of the personalized profile UI (which would fail on user-only
    // providers anyway). Required for App Store Guideline 5.1.1(v) — the
    // tab must remain visible and reachable, just not fail loudly.
    if (authState.isGuest) {
      return const GuestLockedTab(
        title: 'Profile',
        message:
            'Sign in to manage your account, claim a poet identity, and tune your reading preferences.',
        icon: Icons.person_outline,
      );
    }

    final userProfile = ref.watch(userProfileProvider);
    final ownedPoetAsync = ref.watch(ownedPoetProvider);

    // If the user has a verified owned poet, render the creator dashboard
    // in place of the standard profile/settings UI. The dashboard owns
    // its own scrolling shell. Gated for v1.0 — see kPoetModeEnabled.
    final ownedPoet = ownedPoetAsync.valueOrNull;
    if (kPoetModeEnabled &&
        ownedPoet != null &&
        ownedPoet.claimStatus == ClaimStatus.verified) {
      return const CreatorDashboardScreen();
    }

    return CustomScrollView(
      slivers: [
        // App bar
        const StandardSliverAppBar(
          title: 'Profile',
        ),

        // Profile content
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Become-a-poet entry: show the teaser card when the user has
              // no owned poet, or the in-flight claim banner when a claim is
              // pending/rejected. (Verified poets see the dashboard above.)
              if (ownedPoet == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const BecomePoetCard(),
                )
              else if (ownedPoet.claimStatus == ClaimStatus.pending ||
                  ownedPoet.claimStatus == ClaimStatus.rejected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClaimStatusBanner(poet: ownedPoet),
                ),

              const SizedBox(height: 8),

              // Profile header card with user info
              userProfile.when(
                data: (user) => _buildProfileHeader(context, user),
                loading: () => _buildProfileHeaderSkeleton(context),
                error: (error, stackTrace) => _buildProfileHeaderError(context),
              ),

              const SizedBox(height: 32),

              // Language section
              _buildSection(
                context,
                title: 'Settings',
                items: [
                  _buildLanguageTile(context, ref),
                ],
              ),

              const SizedBox(height: 24),

              _buildAboutSection(context, ref),

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

              _buildDangerZone(context, ref, authState.isLoading),
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

  /// Build the "About" section dynamically from the API
  Widget _buildAboutSection(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(appContentListProvider);

    return contentAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _buildSection(
          context,
          title: 'About',
          items: items
              .map((item) => _buildListTile(
                    context,
                    icon: _iconForContentKey(item.contentKey),
                    title: item.title,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppContentDetailScreen(
                            contentKey: item.contentKey,
                            title: item.title,
                          ),
                        ),
                      );
                    },
                  ))
              .toList(),
        );
      },
      loading: () => _buildSection(
        context,
        title: 'About',
        items: [
          _buildListTile(context, icon: Icons.info_outline, title: 'About App'),
          _buildListTile(context, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
          _buildListTile(context, icon: Icons.description_outlined, title: 'Terms of Service'),
        ],
      ),
      error: (_, __) => _buildSection(
        context,
        title: 'About',
        items: [
          _buildListTile(context, icon: Icons.info_outline, title: 'About App'),
          _buildListTile(context, icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
          _buildListTile(context, icon: Icons.description_outlined, title: 'Terms of Service'),
        ],
      ),
    );
  }

  /// Map content keys to appropriate icons
  IconData _iconForContentKey(String key) {
    switch (key.toUpperCase()) {
      case 'ABOUT_APP':
        return Icons.info_outline;
      case 'PRIVACY_POLICY':
        return Icons.privacy_tip_outlined;
      case 'TERMS_OF_SERVICE':
        return Icons.description_outlined;
      case 'CONTACT_US':
        return Icons.contact_mail_outlined;
      case 'FAQ':
        return Icons.help_outline;
      default:
        return Icons.article_outlined;
    }
  }

  /// Danger Zone — irreversible destructive actions (account deletion).
  /// Required for App Store Guideline 5.1.1(v) compliance.
  Widget _buildDangerZone(
    BuildContext context,
    WidgetRef ref,
    bool isAuthLoading,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: Colors.red.withValues(alpha: 0.04),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Permanently delete your account, poems, bookmarks, follows, '
              'and image collections. This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isAuthLoading
                    ? null
                    : () => _handleDeleteAccount(context, ref),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.red.shade700, width: 1.5),
                  foregroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show "Type DELETE to confirm" dialog and call deleteAccount() on confirm.
  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authProvider.notifier).deleteAccount();
      // GoRouter redirect will send user to /login automatically once
      // isAuthenticated flips to false. Nothing else to do here.
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

/// Confirmation dialog requiring the user to type "DELETE" before the
/// account-deletion request is sent. The literal string "DELETE" is also
/// what the backend expects in the request body.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim() == 'DELETE';
      if (next != _canDelete) {
        setState(() => _canDelete = next);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 8),
          const Text('Delete Account?'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete your account, poems, bookmarks, '
            'follows, and image collections. This cannot be undone.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Type DELETE to confirm:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'DELETE',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
          ),
          child: const Text('Delete Account'),
        ),
      ],
    );
  }
}
