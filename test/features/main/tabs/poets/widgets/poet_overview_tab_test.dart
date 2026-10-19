import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_profile_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_tag_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poet_overview_tab.dart';

PoetProfileModel _poet(List<PoetTagModel> tags) => PoetProfileModel(
      publicId: 'p1',
      name: 'Mirza Ghalib',
      shortBio: '-',
      birthYear: 1797,
      isFeatured: false,
      isTrending: false,
      isVerified: false,
      viewCount: 0,
      followerCount: 0,
      poemCount: 0,
      tags: tags,
    );

PoetTagModel _tag(String name, String? color) => PoetTagModel(
      publicId: name,
      name: name,
      slug: name,
      color: color,
      tagType: 'CATEGORY',
    );

Future<void> _pump(WidgetTester tester, PoetProfileModel poet) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [selectedLanguageProvider.overrideWithValue('en')],
      child: MaterialApp(home: Scaffold(body: PoetOverviewTab(poet: poet))),
    ),
  );
}

Color _chipColour(WidgetTester tester, String label) => tester
    .widget<Chip>(find.ancestor(of: find.text(label), matching: find.byType(Chip)))
    .backgroundColor!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('PoetOverviewTab categories', () {
    testWidgets('regression: "-", null and junk tag colours do not throw',
        (tester) async {
      await _pump(
        tester,
        _poet([_tag('Ghazal', '-'), _tag('Nazm', null), _tag('Rubai', '#zz')]),
      );
      expect(tester.takeException(), isNull);
      for (final name in ['Ghazal', 'Nazm', 'Rubai']) {
        expect(find.text(name), findsOneWidget);
        expect(_chipColour(tester, name), Colors.grey.withValues(alpha: 0.3));
      }
    });

    testWidgets('a valid tag colour tints the chip', (tester) async {
      await _pump(tester, _poet([_tag('Ghazal', '#1A2B3C')]));
      expect(_chipColour(tester, 'Ghazal'),
          const Color(0xFF1A2B3C).withValues(alpha: 0.3));
    });
  });
}
