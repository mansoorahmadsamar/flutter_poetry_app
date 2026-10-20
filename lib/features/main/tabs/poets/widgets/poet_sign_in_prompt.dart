import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/auth/auth_provider.dart';
import '../../../../auth/widgets/guest_locked_tab.dart';

/// Poet detail sections served only by authenticated endpoints
/// (`/api/poets/:id/gallery|books|videos` answer 401 for guests).
enum PoetMembersSection {
  gallery('Gallery', 'gallery', Icons.photo_library_outlined),
  books('Books', 'books', Icons.menu_book_outlined),
  videos('Videos', 'videos', Icons.video_library_outlined);

  const PoetMembersSection(this.title, this.noun, this.icon);

  final String title;
  final String noun;
  final IconData icon;
}

/// Whether the current user is signed in. Selects the single field so token
/// refreshes do not rebuild the tab.
bool watchIsSignedIn(WidgetRef ref) =>
    ref.watch(authProvider.select((state) => state.isAuthenticated));

/// Friendly sign-in prompt shown to guests in place of a members-only poet
/// tab, so they see why the tab is empty instead of a 401 error.
class PoetSignInPrompt extends StatelessWidget {
  const PoetSignInPrompt({super.key, required this.section});

  final PoetMembersSection section;

  @override
  Widget build(BuildContext context) {
    return GuestLockedTab(
      title: section.title,
      message: "Sign in to see this poet's ${section.noun}.",
      icon: section.icon,
    );
  }
}
