import 'package:flutter/material.dart';

/// Shown on the login screen after the app signed the user out because their
/// session could no longer be refreshed — so they know why they are here and
/// that browsing as a guest still works.
class SessionExpiredNotice extends StatelessWidget {
  const SessionExpiredNotice({super.key});

  static const title = 'Your session has expired';
  static const message = 'Please sign in again, or continue as a guest.';

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0F2410);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        key: const Key('session-expired-notice'),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4AF37)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_clock_outlined, color: ink, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(fontSize: 13, height: 1.35, color: ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
