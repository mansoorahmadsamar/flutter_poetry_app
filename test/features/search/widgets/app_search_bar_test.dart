import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/widgets/app_search_bar.dart';

import '../helpers/search_test_harness.dart';

/// T-072 (search screens): icon-only buttons must have spoken labels, or
/// TalkBack/VoiceOver read them as just "button".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final (lang, dir, clearLabel, backLabel) in [
    ('ur', TextDirection.rtl, 'تلاش صاف کریں', 'واپس'),
    ('en', TextDirection.ltr, 'Clear search', 'Back'),
    ('hi', TextDirection.ltr, 'खोज साफ़ करें', 'वापस'),
  ]) {
    testWidgets('$lang: clear and back buttons have labels and work',
        (tester) async {
      final semantics = tester.ensureSemantics();
      var clears = 0;
      var backs = 0;
      final controller = TextEditingController(text: 'دل');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: dir,
            child: Scaffold(
              body: AppSearchBar(
                controller: controller,
                focusNode: focusNode,
                languageCode: lang,
                isLoading: false,
                onChanged: (_) {},
                onSubmitted: (_) {},
                onClear: () => clears++,
                onBack: () => backs++,
              ),
            ),
          ),
        ),
      );

      // IconButton.tooltip is what TalkBack/VoiceOver read for the X.
      final clear = find.byTooltip(clearLabel);
      final back = find.bySemanticsLabel(backLabel);
      expect(clear, findsOneWidget);
      expect(back, findsOneWidget);
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(tooltip: clearLabel, isButton: true, hasTapAction: true),
      );

      expect(
        tester.getSemantics(back),
        isSemantics(label: backLabel, isButton: true, hasTapAction: true),
      );

      await tester.tap(clear);
      await tester.tap(back);
      expect(clears, 1);
      expect(backs, 1);

      // Screen readers can activate the back button too.
      tester.semantics.tap(find.semantics.byLabel(backLabel));
      expect(backs, 2);

      semantics.dispose();
    });
  }

  testWidgets('no clear button (and no label) while the field is empty',
      (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSearchBar(
            controller: controller,
            focusNode: focusNode,
            languageCode: 'ur',
            isLoading: false,
            onChanged: (_) {},
            onSubmitted: (_) {},
            onClear: () {},
          ),
        ),
      ),
    );
    expect(find.byTooltip('تلاش صاف کریں'), findsNothing);
  });

  testWidgets('"Search for" suggestion row reads as one labelled button',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final app = await pumpSearchScreen(
      tester,
      state: const GlobalSearchState(
        mode: SearchMode.autocompleting,
        currentQuery: 'دل',
        autocompleteResults: AutocompleteResponse(),
      ),
    );

    final row = find.bySemanticsLabel('تلاش کریں: "دل"');
    expect(row, findsOneWidget);
    expect(
      tester.getSemantics(row),
      isSemantics(isButton: true, hasTapAction: true),
    );

    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(app.notifier.searches.single.query, 'دل');
    semantics.dispose();
  });
}
