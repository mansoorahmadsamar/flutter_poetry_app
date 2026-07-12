import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import 'sign_in_prompt_sheet.dart';

/// If the user is signed in, returns `true` immediately. Otherwise opens
/// the [SignInPromptSheet] and returns whether the user signed in. Used
/// by every gated action (bookmark, react, follow, save image, etc.) so
/// the call sites all look like:
///
/// ```dart
/// onPressed: () async {
///   if (!await ensureSignedIn(context, ref, 'Sign in to bookmark')) return;
///   _doTheThing();
/// }
/// ```
Future<bool> ensureSignedIn(
  BuildContext context,
  WidgetRef ref,
  String reason,
) async {
  if (ref.read(authProvider).isAuthenticated) return true;
  return SignInPromptSheet.show(context, reason: reason);
}
